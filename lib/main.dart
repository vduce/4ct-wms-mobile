import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/config/environment_config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final environment = EnvironmentConfig.fromDartDefines();

  runApp(
    ProviderScope(
      overrides: [environmentConfigProvider.overrideWithValue(environment)],
      child: const WashroomOpsApp(),
    ),
  );
}
