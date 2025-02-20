import 'package:enkryptia/main.dart';
import 'package:enkryptia/pages/HomePage.dart';
import 'package:enkryptia/pages/Login.dart';
import 'package:enkryptia/pages/location_history.dart';
import 'package:enkryptia/pages/trip_history_page.dart';
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
      routes: [
        GoRoute(
          path: 'history',
          builder: (context, state) => const LocationHistory(),
        ),
        GoRoute(
          path: 'my-trips',
          builder: (context, state) => TripHistoryPage(),
        ),
      ]
    ),
    
  ] 
);