import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'app.dart';
import 'flavors.dart';
import 'config/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize flavor
  F.appFlavor = Flavor.values.firstWhere(
    (element) => element.name == appFlavor,
    orElse: () => Flavor.dev,
  );

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint(
      'Firebase native initialization failed or skipped. Falling back to offline/local mocks.',
    );
    // We do NOT use a dummy app here because native Firebase iOS/macOS
    // SDKs like Analytics, Crashlytics, Messaging will crash on invalid
    // credentials when trying to bootstrap.
    // Instead we gracefully provide nulls and FakeCloudFirestore where needed.
  }

  if (Firebase.apps.isNotEmpty) {
    // Setup Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  // Initialize Repositories and Hive
  try {
    await initializeRepositories();
    runApp(const ProviderScope(child: App()));
  } catch (e, stack) {
    debugPrint('Initialization error: $e\n$stack');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Initialization Error:\n$e\n\n$stack',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
