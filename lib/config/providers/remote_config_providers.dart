import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/remote_config_service.dart';

/// Provider for RemoteConfigService.
/// You can watch this provider or its specific properties in the UI to react to feature flags.
final remoteConfigServiceProvider = Provider<RemoteConfigService>((ref) {
  return RemoteConfigService();
});
