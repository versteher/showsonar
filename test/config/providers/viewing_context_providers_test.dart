import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_scout/config/providers.dart';
import 'package:stream_scout/domain/viewing_context.dart';

void main() {
  group('viewingContextProvider', () {
    test('defaults to ViewingContext.all', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(viewingContextProvider), ViewingContext.all);
    });

    test('can be updated to kids', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(viewingContextProvider.notifier).state =
          ViewingContext.kids;
      expect(container.read(viewingContextProvider), ViewingContext.kids);
    });

    test('can cycle through all contexts', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      for (final ctx in ViewingContext.values) {
        container.read(viewingContextProvider.notifier).state = ctx;
        expect(container.read(viewingContextProvider), ctx);
      }
    });
  });
}
