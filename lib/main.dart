import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'services/api_service.dart';
import 'providers/auth_provider.dart';
import 'providers/admin_provider.dart';
import 'providers/student_provider.dart';
import 'providers/staff_provider.dart';
import 'screens/login_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/student_dashboard_screen.dart';
import 'screens/staff_dashboard_screen.dart';

void main() {
  final apiService = ApiService();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(apiService)),
        ChangeNotifierProvider(create: (_) => AdminProvider(apiService)),
        ChangeNotifierProvider(create: (_) => StudentProvider(apiService)),
        ChangeNotifierProvider(create: (_) => StaffProvider(apiService)),
      ],
      child: const SchoolErpApp(),
    ),
  );
}

class SchoolErpApp extends StatelessWidget {
  const SchoolErpApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    final router = GoRouter(
      initialLocation: '/login',
      redirect: (context, state) {
        final loggedIn = authProvider.isAuthenticated;
        final isLoggingIn = state.uri.toString() == '/login';

        if (!loggedIn && !isLoggingIn) return '/login';
        if (loggedIn && isLoggingIn) {
          final user = authProvider.user;
          if (user != null) {
            final role = user['roles'][0]['name'] ?? '';
            if (role == 'student' || role == 'parent') return '/student-dashboard';
            if (role == 'teacher' || role == 'staff') return '/staff-dashboard';
            return '/admin-dashboard';
          }
          return '/admin-dashboard'; // fallback
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/admin-dashboard',
          builder: (context, state) => const AdminDashboardScreen(),
        ),
        GoRoute(
          path: '/student-dashboard',
          builder: (context, state) => const StudentDashboardScreen(),
        ),
        GoRoute(
          path: '/staff-dashboard',
          builder: (context, state) => const StaffDashboardScreen(),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'School ERP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6366F1)),
        useMaterial3: true,
        fontFamily: 'Outfit',
      ),
      routerConfig: router,
    );
  }
}
