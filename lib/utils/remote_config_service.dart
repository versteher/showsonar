import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Wraps Firebase Remote Config to provide a typed, simple interface for feature flags.
class RemoteConfigService {
  final FirebaseRemoteConfig? _remoteConfig;

  RemoteConfigService({FirebaseRemoteConfig? remoteConfig})
    : _remoteConfig =
          remoteConfig ??
          ((Firebase.apps.isNotEmpty &&
                  Firebase.app().options.projectId != 'dummy-project-id')
              ? FirebaseRemoteConfig.instance
              : null);

  /// Initializes the service, sets defaults, and fetches latest values.
  Future<void> initialize() async {
    try {
      if (_remoteConfig == null) return;

      // Set default values before fetching
      await _remoteConfig.setDefaults({
        'enable_social': false,
        'enable_widgets': false,
      });

      // Configure fetch settings. In development, we use a very short minimumFetchInterval
      // so changes reflect almost instantly. In production, this should be higher (e.g. 12 hours).
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: kDebugMode
              ? const Duration(minutes: 1)
              : const Duration(hours: 12),
        ),
      );

      // Fetch and activate the latest values from the cloud
      await _remoteConfig.fetchAndActivate();

      // Listen for realtime config updates if supported
      _remoteConfig.onConfigUpdated.listen((event) async {
        await _remoteConfig.activate();
        debugPrint('Remote Config updated: ${event.updatedKeys}');
      });
    } catch (e) {
      debugPrint('Error initializing Firebase Remote Config: $e');
    }
  }

  /// True if social features are enabled via Remote Config
  bool get enableSocial => _remoteConfig?.getBool('enable_social') ?? false;

  /// True if widget integrations are enabled via Remote Config
  bool get enableWidgets => _remoteConfig?.getBool('enable_widgets') ?? false;
}
