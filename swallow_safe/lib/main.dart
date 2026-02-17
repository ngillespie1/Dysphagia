import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/services/service_locator.dart';

Future<void> main() async {
  // Wrap in error zone for better web debugging
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (kDebugMode) {
      debugPrint('Flutter Error: ${details.exception}');
      debugPrint('Stack: ${details.stack}');
    }
  };

  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Lock orientation to portrait for accessibility (skip on web)
    if (!kIsWeb) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
    
    // Initialize Hive for local storage
    await Hive.initFlutter();
    
    // Initialize service locator (dependency injection)
    await setupServiceLocator();
    
    // Set system UI overlay style for accessibility (skip on web)
    if (!kIsWeb) {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Color(0xFFF8F6F3),
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );
    }
    
    runApp(const SwallowSafeApp());
  } catch (e, stack) {
    debugPrint('App initialization error: $e');
    debugPrint('Stack: $stack');
    // Show error app
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Error initializing: $e'),
        ),
      ),
    ));
  }
}
