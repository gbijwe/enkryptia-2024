import 'dart:async';

import 'package:enkryptia/credentials.dart';
import 'package:enkryptia/router/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final ValueNotifier<int> shiftTimer = ValueNotifier<int>(0);
final Location location = Location();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); 

  // await Permission.notification.request();

  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  }); 

  // await Supabase.initialize(
  //   url: Credentials.SUPABASE_URL,
  //   anonKey: Credentials.SUPABASE_ANON_KEY,
  // );
  await Supabase.initialize(
    url: Credentials.SUPABASE_URL,
    anonKey: Credentials.SUPABASE_ANON_KEY,
  );

  final prefs = await SharedPreferences.getInstance();
  shiftTimer.value = prefs.getInt('shiftTimer') ?? 0;

  runApp(const MainApp());
}

final supabase = Supabase.instance.client;

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    iosConfiguration: IosConfiguration(),
    androidConfiguration: AndroidConfiguration(
      onStart: onStart, 
      autoStart: true,
      autoStartOnBoot: true,
      isForegroundMode: true
    )
  );
  debugPrint("SERVICE CONFIGURED");
  await service.startService();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event){
      service.setAsForegroundService();
      debugPrint("LOCATION: - foreground set");
    });

    service.on('setAsBackgroundService').listen((event){
      service.setAsBackgroundService();
      debugPrint("LOCATION: - background set");
    });
  } 

  service.on('stopService').listen((event){
    debugPrint("LOCATION: - background stoped");
    service.stopSelf();
  }); 

  Timer.periodic(const Duration(seconds: 1), (timer) async {
    shiftTimer.value++;
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('shiftTimer', shiftTimer.value);

    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        service.setForegroundNotificationInfo(
          title: "Shift started!",
          content: "Time on the clock: ${shiftTimer.value ~/ 3600}:${shiftTimer.value ~/ 60}:${(shiftTimer.value % 60).toString().padLeft(2, '0')}",
        );
      }
    }
  });
}

void requestPermissions() async {
  var status = await Permission.location.request();
  if (status.isGranted) {
    debugPrint(status.toString());
  } else {
    // Handle the case when permission is not granted
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}