import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/config/environment_config.dart';
import 'core/date/date_time.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeAppDateAndTime();

  final environment = EnvironmentConfig.fromDartDefines();

  runApp(
    ProviderScope(
      overrides: [environmentConfigProvider.overrideWithValue(environment)],
      child: const WashroomOpsApp(),
    ),
  );
}
