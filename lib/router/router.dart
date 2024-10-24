import 'package:enkryptia/main.dart';
import 'package:enkryptia/pages/HomePage.dart';
import 'package:enkryptia/pages/Login.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    if (supabase.auth.currentSession == null) {
      return '/';
    } else {
      if (state.fullPath! == '/') {
        return '/home';
      }
      return null;
    }
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const Loginpage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => HomePage(),
    ),
  ] 
);