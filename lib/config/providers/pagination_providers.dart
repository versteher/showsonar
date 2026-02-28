import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/media.dart';
import '../providers.dart';

/// State object representing a paginated list of Media items
class PaginationState<T> {
  final List<T> items;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;
  final String? error;

  const PaginationState({
    this.items = const [],
    this.page = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.error,
  });

  PaginationState<T> copyWith({
    List<T>? items,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    String? error,
  }) {
    return PaginationState<T>(
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
    );
  }
}

/// Abstract notifier for paginated media fetching (non-family)
abstract class PaginationNotifier
    extends AsyncNotifier<PaginationState<Media>> {
  /// The method to implement for fetching a specific page
  Future<List<Media>> fetchPage(int page);

  @override
  Future<PaginationState<Media>> build() async {
    final items = await fetchPage(1);
    return PaginationState(
      items: items,
      page: 1,
      hasMore: items.isNotEmpty,
    );
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.hasError) return;
    final currentState = state.valueOrNull;
    if (currentState == null ||
        !currentState.hasMore ||
        currentState.isLoadingMore) {
      return;
    }

    state = AsyncValue.data(
      currentState.copyWith(isLoadingMore: true, error: null),
    );

    try {
      final nextPage = currentState.page + 1;
      final newItems = await fetchPage(nextPage);

      state = AsyncValue.data(
        currentState.copyWith(
          items: [...currentState.items, ...newItems],
          page: nextPage,
          hasMore: newItems.isNotEmpty,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(isLoadingMore: false, error: e.toString()),
      );
    }
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

// ============================================================================
// Concrete Implementations
// ============================================================================

class TrendingPaginationNotifier
    extends FamilyAsyncNotifier<PaginationState<Media>, String> {
  late MediaType? _type;
  late String _timeWindow;

  @override
  Future<PaginationState<Media>> build(String arg) async {
    final parts = arg.split('_');
    final typeStr = parts[0];
    _timeWindow = parts[1];
    _type = typeStr == 'movie'
        ? MediaType.movie
        : (typeStr == 'tv' ? MediaType.tv : null);
    final items = await fetchPage(1);
    return PaginationState(items: items, page: 1, hasMore: items.isNotEmpty);
  }

  Future<List<Media>> fetchPage(int page) {
    return ref
        .read(tmdbRepositoryProvider)
        .getTrending(type: _type, timeWindow: _timeWindow, page: page);
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.hasError) return;
    final currentState = state.valueOrNull;
    if (currentState == null ||
        !currentState.hasMore ||
        currentState.isLoadingMore) {
      return;
    }

    state = AsyncValue.data(
      currentState.copyWith(isLoadingMore: true, error: null),
    );

    try {
      final nextPage = currentState.page + 1;
      final newItems = await fetchPage(nextPage);

      state = AsyncValue.data(
        currentState.copyWith(
          items: [...currentState.items, ...newItems],
          page: nextPage,
          hasMore: newItems.isNotEmpty,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(isLoadingMore: false, error: e.toString()),
      );
    }
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

class PopularMoviesPaginationNotifier extends PaginationNotifier {
  @override
  Future<List<Media>> fetchPage(int page) {
    return ref.read(tmdbRepositoryProvider).getPopularMovies(page: page);
  }
}

class PopularTvPaginationNotifier extends PaginationNotifier {
  @override
  Future<List<Media>> fetchPage(int page) {
    return ref.read(tmdbRepositoryProvider).getPopularTvSeries(page: page);
  }
}

class TopRatedMoviesPaginationNotifier extends PaginationNotifier {
  @override
  Future<List<Media>> fetchPage(int page) {
    return ref.read(tmdbRepositoryProvider).getTopRatedMovies(page: page);
  }
}

class TopRatedTvPaginationNotifier extends PaginationNotifier {
  @override
  Future<List<Media>> fetchPage(int page) {
    return ref.read(tmdbRepositoryProvider).getTopRatedTvSeries(page: page);
  }
}

// ============================================================================
// Providers
// ============================================================================

final trendingPaginationProvider =
    AsyncNotifierProviderFamily<TrendingPaginationNotifier,
        PaginationState<Media>, String>(
      TrendingPaginationNotifier.new,
    );

final popularMoviesPaginationProvider =
    AsyncNotifierProvider<PopularMoviesPaginationNotifier,
        PaginationState<Media>>(
      PopularMoviesPaginationNotifier.new,
    );

final popularTvPaginationProvider =
    AsyncNotifierProvider<PopularTvPaginationNotifier, PaginationState<Media>>(
      PopularTvPaginationNotifier.new,
    );

final topRatedMoviesPaginationProvider =
    AsyncNotifierProvider<TopRatedMoviesPaginationNotifier,
        PaginationState<Media>>(
      TopRatedMoviesPaginationNotifier.new,
    );

final topRatedTvPaginationProvider =
    AsyncNotifierProvider<TopRatedTvPaginationNotifier, PaginationState<Media>>(
      TopRatedTvPaginationNotifier.new,
    );
