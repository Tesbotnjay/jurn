import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/attendance/attendance_screen.dart';
import 'screens/assignments/assignments_screen.dart';
import 'screens/drive_links/drive_links_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/broadcasts/broadcasts_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  redirect: (BuildContext context, GoRouterState state) async {
    final supabase = Supabase.instance.client;
    final session = supabase.auth.currentSession;

    // If not logged in, go to login
    if (session == null) {
      return state.matchedLocation == '/register' ? '/register' : '/login';
    }

    // Root path has no screen: send to dashboard.
    if (state.matchedLocation == '/') {
      return '/dashboard';
    }

    // If logged in and trying to access auth pages, go to dashboard
    if (state.matchedLocation == '/login' || state.matchedLocation == '/register') {
      return '/dashboard';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/attendance',
      builder: (context, state) => const AttendanceScreen(),
    ),
    GoRoute(
      path: '/assignments',
      builder: (context, state) => const AssignmentsScreen(),
    ),
    GoRoute(
      path: '/drive-links',
      builder: (context, state) => const DriveLinksScreen(),
    ),
    GoRoute(
      path: '/broadcasts',
      builder: (context, state) => const BroadcastsScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);
