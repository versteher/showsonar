
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Service that initialises Firebase and wires up Crashlytics error handlers.
///
/// Extracted into its own class so that the initialisation logic can be unit-
/// tested without spinning up a full widget tree, and so that it can be swapped
/// for a no-op implementation in tests via dependency injection.
class CrashlyticsService {
  /// Initialises Firebase and installs global error hooks.
  ///
  /// Must be called after [WidgetsFlutterBinding.ensureInitialized].
  /// In debug builds Crashlytics collection is disabled so crashes are only
  /// printed to the console — not uploaded.
  static Future<void> initialize({FirebaseOptions? options}) async {
    await Firebase.initializeApp(options: options);

    final crashlytics = FirebaseCrashlytics.instance;

    // Disable collection in debug — data is logged to the console only.
    await crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);

    // Catch framework-level errors (e.g. rendering exceptions).
    FlutterError.onError = crashlytics.recordFlutterFatalError;

    // Catch async errors that Flutter didn't catch (Dart isolate errors,
    // unhandled Future rejections, etc.).
    PlatformDispatcher.instance.onError = (error, stack) {
      crashlytics.recordError(error, stack, fatal: true);
      return true;
    };
  }
}
