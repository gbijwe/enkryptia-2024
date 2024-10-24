import 'dart:async';
import 'dart:math';
import 'package:enkryptia/data/enable_in_background.dart';
import 'package:enkryptia/data/listen_location.dart';
import 'package:enkryptia/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Timer? _timer;
  final ListenLocation _listenLocation = ListenLocation();
  final EnableInBackground _enableInBackground = EnableInBackground();
  final TextEditingController _otpController = TextEditingController();

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

  Future<void> _startShift() async {
    // Request notification permission
    final status = await Permission.notification.request();
    if (status.isGranted) {
      // Request location permission
      final permission = await Permission.location.request();
      if (permission == PermissionStatus.granted) {
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
    // Get the current location
    loc.LocationData currentLocation = await location.getLocation();

    // Example task location (latitude and longitude)
    double taskLatitude = 21.164;
    double taskLongitude = 79.083;

    // Define the acceptable range in meters
    double acceptableRange = 10.0;

    // Calculate the distance between the current location and the task location
    double distance = _calculateDistance(
      currentLocation.latitude!,
      currentLocation.longitude!,
      taskLatitude,
      taskLongitude,
    );

    // Check if the distance is within the acceptable range
    if (distance <= acceptableRange) {
      // Approve the task
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
  Widget build(BuildContext context)  {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("SalesPath", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w300)), 
            IconButton(onPressed: () {context.go('/home/history');}, icon: const Icon(Icons.history))],),
        elevation: 3.0,
        shadowColor: Colors.red,
        backgroundColor: Colors.white,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 18.0, left: 8.0),
            child: Text(
              "Time working today"
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.red, width: 3.0)
                    ),
                  ),
                  ValueListenableBuilder<int>(
                    builder: (context, value, child) {
                      return Text(
                        "${(value ~/ 3600).toString().padLeft(2, '0')}:${((value ~/ 60) % 60).toString().padLeft(2, '0')}:${(value % 60).toString().padLeft(2, '0')}",
                        style: const TextStyle(fontSize: 34, color: Colors.black),
                      );
                    },
                    valueListenable: shiftTimer,
                  ),
                ],
              ),
            ),
          ),
          ElevatedButton(
            // onPressed: () {
            //   _startShift();
            //   FlutterBackgroundService().invoke('setAsForeground');
            //   _listenLocation.listenLocation();
            //   },
            onPressed:() {
              _showOtpDialog(context, () {
                _startShift();
                FlutterBackgroundService().invoke('setAsForeground');
                _listenLocation.listenLocation();
              });
            },
            child: const Text("Clock in"),
          ),
          ElevatedButton(
            onPressed: () {
              _stopTimer();
              FlutterBackgroundService().invoke('stopService');
              _listenLocation.stopListen();
              },
            child: const Text("Clock out"),
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Text("Assignment:", style: TextStyle(fontSize: 28),),
              ),
              ListTile(
                leading: const Icon(Icons.location_pin, size: 48.0, color: Colors.red,),
                title: const Text("Visit 5 locations"),
                subtitle: Row(
                  children: [
                    ElevatedButton(onPressed: () {
                      _verifyTask(() {
                        const snackBar = SnackBar(
                          content: Text('Task verified!'),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      });
                    }, child: const Text("Verify visit"))
                  ],
                ),
              )
            ],
          ),
        ],
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
