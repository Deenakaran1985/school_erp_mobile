import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'services/api_service.dart';
import 'providers/auth_provider.dart';
import 'providers/admin_provider.dart';
import 'providers/student_provider.dart';
import 'providers/staff_provider.dart';
import 'providers/notification_provider.dart';

import 'screens/login_screen.dart';
import 'screens/biometric_lock_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/student_dashboard_screen.dart';
import 'screens/staff_dashboard_screen.dart';
import 'screens/parent_dashboard_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/profile_settings_screen.dart';

import 'screens/student_exams_screen.dart';
import 'screens/student_results_screen.dart';
import 'screens/student_fees_screen.dart';

import 'screens/staff_payslips_screen.dart';
import 'screens/staff_attendance_screen.dart';
import 'screens/staff_students_screen.dart';
import 'screens/mark_attendance_screen.dart';
import 'screens/create_homework_screen.dart';

import 'screens/admin_fee_summary_screen.dart';
import 'screens/admin_payroll_summary_screen.dart';
import 'screens/admin_staff_list_screen.dart';
import 'screens/admin_expenses_screen.dart';
import 'screens/admin_send_notification_screen.dart';

void main() {
  final apiService = ApiService();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(apiService)),
        ChangeNotifierProvider(create: (_) => AdminProvider(apiService)),
        ChangeNotifierProvider(create: (_) => StudentProvider(apiService)),
        ChangeNotifierProvider(create: (_) => StaffProvider(apiService)),
        ChangeNotifierProvider(create: (_) => NotificationProvider(apiService)),
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
      refreshListenable: authProvider,
      initialLocation: '/login',
      redirect: (context, state) {
        final loggedIn = authProvider.isAuthenticated;
        final unlocked = authProvider.isUnlocked;
        final path = state.uri.toString();
        final isLoggingIn = path == '/login';
        final isLocked = path == '/biometric-lock';

        if (!loggedIn) return isLoggingIn ? null : '/login';
        if (!unlocked) return isLocked ? null : '/biometric-lock';

        if (isLoggingIn || isLocked) {
          final user = authProvider.user;
          if (user == null) return null; // still resolving; don't guess a role yet
          final role = user['role'] ?? user['user_type'] ?? '';
          if (role == 'parent') return '/parent-dashboard';
          if (role == 'student') return '/student-dashboard';
          if (role == 'teacher' || role == 'staff') return '/staff-dashboard';
          return '/admin-dashboard';
        }
        return null;
      },
      routes: [
        GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
        GoRoute(path: '/biometric-lock', builder: (context, state) => const BiometricLockScreen()),

        // Dashboards
        GoRoute(path: '/admin-dashboard', builder: (context, state) => AdminDashboardScreen()),
        GoRoute(path: '/student-dashboard', builder: (context, state) => const StudentDashboardScreen()),
        GoRoute(path: '/staff-dashboard', builder: (context, state) => const StaffDashboardScreen()),
        GoRoute(path: '/parent-dashboard', builder: (context, state) => ParentDashboardScreen()),
        
        // Common
        GoRoute(path: '/notifications', builder: (context, state) => NotificationsScreen()),
        GoRoute(path: '/profile', builder: (context, state) => ProfileSettingsScreen()),
        
        // Student/Parent
        GoRoute(path: '/student_exams', builder: (context, state) => StudentExamsScreen()),
        GoRoute(path: '/student_results', builder: (context, state) => StudentResultsScreen()),
        GoRoute(path: '/student_fees', builder: (context, state) => StudentFeesScreen()),
        
        // Staff
        GoRoute(path: '/staff_payslips', builder: (context, state) => StaffPayslipsScreen()),
        GoRoute(path: '/staff_attendance', builder: (context, state) => StaffAttendanceScreen()),
        GoRoute(path: '/staff_students', builder: (context, state) => StaffStudentsScreen()),
        GoRoute(path: '/mark_attendance', builder: (context, state) => MarkAttendanceScreen()),
        GoRoute(path: '/create_homework', builder: (context, state) => CreateHomeworkScreen()),
        
        // Admin
        GoRoute(path: '/admin_fee_summary', builder: (context, state) => AdminFeeSummaryScreen()),
        GoRoute(path: '/admin_payroll_summary', builder: (context, state) => AdminPayrollSummaryScreen()),
        GoRoute(path: '/admin_staff_list', builder: (context, state) => AdminStaffListScreen()),
        GoRoute(path: '/admin_expenses', builder: (context, state) => AdminExpensesScreen()),
        GoRoute(path: '/admin_send_notification', builder: (context, state) => AdminSendNotificationScreen()),
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
