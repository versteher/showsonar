import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:neon_voyager/config/providers/remote_config_providers.dart';
import 'package:neon_voyager/utils/remote_config_service.dart';

class MockRemoteConfigService extends Mock implements RemoteConfigService {}

void main() {
  group('Remote Config Providers', () {
    test('remoteConfigServiceProvider provisions a RemoteConfigService', () {
      final mockService = MockRemoteConfigService();
      final container = ProviderContainer(
        overrides: [remoteConfigServiceProvider.overrideWithValue(mockService)],
      );
      addTearDown(container.dispose);

      final service = container.read(remoteConfigServiceProvider);
      expect(service, isA<RemoteConfigService>());
    });
  });
}
