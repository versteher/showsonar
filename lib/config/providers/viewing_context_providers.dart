import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/viewing_context.dart';
import '../providers.dart';

/// The currently active viewing context. Persisted across sessions via SharedPreferences.
final viewingContextProvider =
    NotifierProvider<ViewingContextNotifier, ViewingContext>(() {
      return ViewingContextNotifier();
    });

class ViewingContextNotifier extends Notifier<ViewingContext> {
  @override
  ViewingContext build() {
    try {
      final repo = ref.read(localPreferencesRepositoryProvider);
      return ViewingContext.values[repo.viewingContextIndex];
    } catch (_) {
      return ViewingContext.all;
    }
  }

  Future<void> updateContext(ViewingContext context) async {
    state = context;
    try {
      final repo = ref.read(localPreferencesRepositoryProvider);
      await repo.setViewingContextIndex(context.index);
    } catch (_) {
      // Ignore errors if preferences repository is not available
    }
  }
}
