import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/pos_page.dart';
import 'pages/inventory_page.dart';
import 'pages/reports_page.dart';
import 'pages/settings_page.dart';
import 'pages/user_management_page.dart';
import 'pages/category_management_page.dart';
import 'pages/expense_tracking_page.dart';
import 'pages/return_management_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DataCom Jember - POS System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/pos': (context) => const PosPage(),
        '/inventory': (context) => const InventoryPage(),
        '/reports': (context) => const ReportsPage(),
        '/settings': (context) => const SettingsPage(),
        '/users': (context) => const UserManagementPage(),
        '/categories': (context) => const CategoryManagementPage(),
        '/expenses': (context) => const ExpenseTrackingPage(),
        '/returns': (context) => const ReturnManagementPage(),
      },
    );
  }
}