import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'app.dart';
import 'services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 WAJIB sebelum pakai sqflite di desktop
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  await DatabaseService.init();

  runApp(const MyApp());
}