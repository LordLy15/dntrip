import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/storage/hive_storage.dart';
import 'app.dart';
import 'features/auth/domain/auth_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  final storage = HiveStorage();
  await storage.init();

  runApp(
    ProviderScope(
      overrides: [
        hiveStorageProvider.overrideWithValue(storage),
      ],
      child: const DNTripApp(),
    ),
  );
}
