import 'package:enkryptia/credentials.dart';
import 'package:enkryptia/router/router.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: Credentials.SUPABASE_URL,
    anonKey: Credentials.SUPABASE_ANON_KEY,
  );

  runApp(const MainApp());
}

final supabase = Supabase.instance.client;


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
