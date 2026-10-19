import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'core/theme/app_theme.dart';
import 'screens/main_screen.dart';

import 'core/localization/app_language.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await AppLanguage.instance.init();

  runApp(const FinlixApp());
}

class FinlixApp extends StatelessWidget {
  const FinlixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLanguage.instance.localeNotifier,
      builder: (context, localeCode, child) {
        return MaterialApp(
          key: ValueKey('finlix_app_$localeCode'),
          title: 'FinLix',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: const MainScreen(),
        );
      },
    );
  }
}
