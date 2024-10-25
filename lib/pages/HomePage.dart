import 'dart:async';
import 'dart:math';
import 'package:enkryptia/data/enable_in_background.dart';
import 'package:enkryptia/data/listen_location.dart';
import 'package:enkryptia/data/salesman_trip_database_helper.dart';
import 'package:enkryptia/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:location/location.dart' as loc;
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as pmh;
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Timer? _timer;
  int? currentTripId;
  final ListenLocation _listenLocation = ListenLocation();
  final EnableInBackground _enableInBackground = EnableInBackground();
  final TextEditingController _otpController = TextEditingController();
  ValueNotifier<bool> isClockedIn = ValueNotifier<bool>(false);

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      shiftTimer.value++;
      final prefs = await SharedPreferences.getInstance();
      prefs.setInt('shiftTimer', shiftTimer.value);
    });
  }

  void _stopTimer() async {
    _timer?.cancel();
    shiftTimer.value = 0;
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('shiftTimer', shiftTimer.value);
  }

  Future<void> _startTrip() async {
    // Get the current location
    loc.LocationData currentLocation = await location.getLocation();
    String timestamp = DateTime.now().toIso8601String();

    // Insert the start location into the database
    await SalesmanTripDatabaseHelper().insertStateLocation(
      currentLocation.latitude!,
      currentLocation.longitude!,
      timestamp,
    );

    // Get the ID of the inserted trip
    final List<Map<String, dynamic>> trips = await SalesmanTripDatabaseHelper().getSalesmanTripDatabase();
    currentTripId = trips.last['id'];
  }

  Future<void> _endTrip() async {
    if (currentTripId != null) {
      // Get the current location
      loc.LocationData currentLocation = await location.getLocation();
      String endTimestamp = DateTime.now().toIso8601String();

      // Update the end location and calculate the total time spent
      await SalesmanTripDatabaseHelper().updateEndLocationAndCalculateTime(
        currentTripId!,
        currentLocation.latitude!,
        currentLocation.longitude!,
        endTimestamp,
      );

      // Reset the current trip ID
      currentTripId = null;
    }
  }

  Future<void> _startShift() async {
    // Request notification permission
    final status = await pmh.Permission.notification.request();
    if (status.isGranted) {
      // Request location permission
      final permission = await pmh.Permission.location.request();
      if (permission == pmh.PermissionStatus.granted) {
        // Initialize and start the service
        await initializeService();
        FlutterBackgroundService().startService();
        _startTimer();
      } else {
        debugPrint("Location permission not granted");
      }
    } else {
      debugPrint("Notification permission not granted");
    }
  }

  Future<void> _verifyTask(Function onSubmit) async {
    loc.LocationData currentLocation = await location.getLocation();

    // Example task location (latitude and longitude)
    double taskLatitude = 21.164;
    double taskLongitude = 79.083;

    double threshold = 10.0;

    double distance = _calculateDistance(
      currentLocation.latitude!,
      currentLocation.longitude!,
      taskLatitude,
      taskLongitude,
    );

    if (distance <= threshold) {
      onSubmit();
      print(distance);
      print('Task approved');
    } else {
      const AlertDialog(
        title: Text("Alert! You have not verified your tast!"),
      );
      print(distance);
      print('Task rejected');
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371e3; // Earth radius in meters
    double phi1 = lat1 * (3.141592653589793 / 180);
    double phi2 = lat2 * (3.141592653589793 / 180);
    double deltaPhi = (lat2 - lat1) * (3.141592653589793 / 180);
    double deltaLambda = (lon2 - lon1) * (3.141592653589793 / 180);

    double a = (sin(deltaPhi / 2) * sin(deltaPhi / 2)) +
        (cos(phi1) * cos(phi2) * sin(deltaLambda / 2) * sin(deltaLambda / 2));
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    if (await _listenLocation.checkPermissions() == false) {
      await _listenLocation.requestPermission();
    }
    if (await _enableInBackground.checkBackgroundMode()) {
      await _enableInBackground.toggleBackgroundMode();
    }
    FlutterBackgroundService().invoke('setAsBackground');
  }

  void _showOtpDialog(BuildContext context, Function onSubmit) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter task code:'),
          content: TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Enter code'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                onSubmit();
                Navigator.of(context).pop();
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("SalesPath",
                style: TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold, fontSize: 24)),
            IconButton(onPressed: () {
              context.go('/home/history'); // Assuming you're using go_router for navigation
            }, icon: const Icon(Icons.history, color: Colors.black)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 3.0,
        shadowColor: Colors.grey.withOpacity(0.5),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Time working today",
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w400),
                ),
                IconButton(
                  icon: const Icon(Icons.trip_origin, color: Colors.pink),
                  onPressed: () {
                    context.go('/home/my-trips'); // Navigate to the trip history page
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Color-changing circle container
                  ValueListenableBuilder<bool>(
                    valueListenable: isClockedIn,
                    builder: (context, isRunning, child) {
                      return Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: isRunning
                                ? [Colors.greenAccent, Colors.lightGreen]
                                : [Colors.redAccent, Colors.pinkAccent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 15,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  ValueListenableBuilder<int>(
                    builder: (context, value, child) {
                      return Text(
                        "${(value ~/ 3600).toString().padLeft(2, '0')}:${((value ~/ 60) % 60).toString().padLeft(2, '0')}:${(value % 60).toString().padLeft(2, '0')}",
                        style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      );
                    },
                    valueListenable: shiftTimer,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showOtpDialog(context, () {
                  _startShift();
                  _startTrip();
                  isClockedIn.value = true;  // Set the state to "clocked in"
                  FlutterBackgroundService().invoke('setAsForeground');
                  _listenLocation.listenLocation();
                });
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 5,
              ),
              child: const Text("Clock in", style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _showOtpDialog(context, () {
                  _stopTimer();
                  _endTrip();
                  isClockedIn.value = false;  // Set the state to "clocked out"
                  FlutterBackgroundService().invoke('stopService');
                  _listenLocation.stopListen();
                });
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.grey[600],
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 5,
              ),
              child: const Text("Clock out", style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.location_pin,
                  size: 48.0, color: Colors.redAccent),
              title: const Text("Visit 5 locations",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: ElevatedButton(
                onPressed: () {
                  _verifyTask(() {
                    const snackBar = SnackBar(
                      content: Text('Task verified!'),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  });
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.greenAccent[400],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Verify visit"),
              ),
            )
          ],
        ),
      ),
    );
  }
}


// import 'dart:async';

// import 'package:enkryptia/main.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';

// class Homepage extends StatefulWidget {
//   const Homepage({super.key});

//   @override
//   State<Homepage> createState() => _HomepageState();
// }

// class _HomepageState extends State<Homepage> {
//    Timer? _timer;
//   int _seconds = 0;

//   void _startTimer() {
//     _timer?.cancel();
//     _seconds = 0;
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       setState(() {
//         _seconds++;
//       });
//     });
//   }

//   void _stopTimer() {
//     _timer?.cancel();
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Dashboard", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w300),),
//       ),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Center(
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 Container(
//                   width: 200,
//                   height: 200,
//                   decoration: const BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Colors.blue,
//                   ),
//                 ),
//                 Text(
//                   "${_seconds ~/ 60}:${(_seconds % 60).toString().padLeft(2, '0')}",
//                   style: const TextStyle(fontSize: 40, color: Colors.white),
//                 ),
//               ],
//             ),
//           ),
//           ElevatedButton(onPressed: () {
//             FlutterBackgroundService().invoke('setAsForeground');
//           }, child: const Text("Set foreground")),
//           ElevatedButton(
//             onPressed: () {
//               requestPermissions();
//               FlutterBackgroundService().startService();
//               _startTimer();
//             },
//             child: const Text("Start shift!")
//           ),
//           ElevatedButton(
//             onPressed: () {
//               // service.stopService();
//               _stopTimer();
//             },
//             child: const Text("Stop service"))
//         ],
//       ),
//     );
//   }
// }
