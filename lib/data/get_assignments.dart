import 'package:enkryptia/main.dart';
import 'package:flutter/material.dart';

Future<List<Map<String, dynamic>>> getAssignments() async {
  final res = await supabase.from('goals').select().eq('salesperson_id', supabase.auth.currentUser!.id);
  debugPrint("RESPONSE");
  debugPrint(res.toString());
  return List<Map<String, dynamic>>.from(res);
}