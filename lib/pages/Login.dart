import 'package:enkryptia/router/router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("Login page"),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: SupaEmailAuth(
                // redirectTo: kIsWeb ? null : 'com.enkryptia.enkryptia://login-callback',
                onSignInComplete: (response) {
                  // router.refresh();
                  context.pushReplacement('/home');
                },
                onSignUpComplete: (response) {
                  router.refresh();
                },
                
              ),
            ),
        ],
      ),
    );
  }
}