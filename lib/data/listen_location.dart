

import 'dart:async';
import 'package:enkryptia/data/sync_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:enkryptia/data/database_helper.dart';

class ListenLocation {
  final Location location = Location();
  final dbHelper = DatabaseHelper();

  PermissionStatus? _permissionGranted;
  LocationData? _location;
  StreamSubscription<LocationData>? _locationSubscription;
  String? _error;
  
  void _insertLocation(double lat, double long, String timestamp) async {
    try {
      await dbHelper.insertLocation(lat, long, timestamp);
      debugPrint('Location inserted successfully');
    } catch (e) {
      debugPrint('Error inserting location: $e');
    }
  }

  Future<bool> checkPermissions() async {
    
    final permissionGrantedResult = await location.hasPermission();
    _permissionGranted = permissionGrantedResult;
    return permissionGrantedResult == PermissionStatus.granted;
  }

  Future<void> requestPermission() async {
    if (_permissionGranted != PermissionStatus.granted) {
      final permissionRequestedResult = await location.requestPermission();
      _permissionGranted = permissionRequestedResult;
    }
  }

  Future<void> listenLocation() async {
    _locationSubscription =
        location.onLocationChanged.handleError((dynamic err) {
      if (err is PlatformException) {
        _error = err.code;
      }
      _locationSubscription?.cancel();
      _locationSubscription = null;
    }).listen((currentLocation) async {
      _error = null;
      _location = currentLocation;
      var timestamp = DateTime.now().toString();
      var res = await sendDataToCloud(_location!.latitude!, _location!.longitude!, timestamp);
      // print("Location data sent");
      // print(res.toString());

      _insertLocation(
        _location!.latitude!,
        _location!.longitude!,
        DateTime.now().toString()
      );
      
      if (res) {
        await DatabaseHelper().updateLocationSyncStatus(timestamp, 1);
      }

      debugPrint(_location.toString());
      debugPrint(DateTime.now().toString());
    });
  }

  Future<void> stopListen() async {
    await _locationSubscription?.cancel();
    final unsynced = await dbHelper.getUnsyncedLocations();
    for (var loc in unsynced) {
      await dbHelper.updateLocationSyncStatus(loc['datetime'], 1);
    }
    
    await dbHelper.getUnsyncedLocations();
    _locationSubscription = null;
  }

  void dispose() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }
}