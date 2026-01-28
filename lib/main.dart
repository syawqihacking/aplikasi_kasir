import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'app.dart';
import 'services/database_service.dart';
import 'services/user_service.dart';
import 'services/payment_method_service.dart';
import 'models/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 WAJIB sebelum pakai sqflite di desktop
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  await DatabaseService.init();

  // Initialize default admin user
  final adminExists = await UserService.getByEmail('admin@example.com');
  if (adminExists == null) {
    await UserService.create(
      User(
        name: 'Admin',
        email: 'admin@example.com',
        password: 'admin123',
        role: 'admin',
        createdAt: DateTime.now(),
      ),
    );
  }

  // Initialize default payment methods
  await PaymentMethodService.initDefaults();

  runApp(const MyApp());
}