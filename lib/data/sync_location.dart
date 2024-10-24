import 'package:enkryptia/main.dart';
import 'package:flutter/material.dart';

Future<bool> sendDataToCloud(double latitude, double longitude, String timestamp) async {
  final res = await supabase.from('location_tracker').insert(
    {
      'lat': latitude,
      'long': longitude,
      'datetime': timestamp
    }
  ).select();
  debugPrint("RESPONSE");
  debugPrint(res.toString());
  if (res != null) {
    return true;
  } else {
    return false;
  }
}