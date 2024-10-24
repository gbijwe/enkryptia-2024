import 'dart:async';
import 'package:enkryptia/main.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Timer? _timer;

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
        bg.BackgroundGeolocation.start();
      } else {
        debugPrint("Location permission not granted");
      }
    } else {
      debugPrint("Notification permission not granted");
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w300)),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                ),
                ValueListenableBuilder<int>(
                  valueListenable: shiftTimer,
                  builder: (context, value, child) {
                    return Text(
                      "${value ~/ 3600}:${value ~/ 60}:${(value % 60).toString().padLeft(2, '0')}",
                      style: const TextStyle(fontSize: 40, color: Colors.white),
                    );
                  },
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _startShift();
              FlutterBackgroundService().invoke('setAsForeground');
              },
            child: const Text("Start shift"),
          ),
          ElevatedButton(
            onPressed: () {
              _stopTimer();
              FlutterBackgroundService().invoke('stopService');
              },
            child: const Text("Stop shift"),
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