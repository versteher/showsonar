import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/viewing_context.dart';

/// The currently active viewing context. Session-level — resets to [ViewingContext.all] on app restart.
final viewingContextProvider =
    StateProvider<ViewingContext>((_) => ViewingContext.all);
