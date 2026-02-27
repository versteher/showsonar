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

/// Abstract notifier for paginated media fetching
abstract class PaginationNotifier
    extends StateNotifier<AsyncValue<PaginationState<Media>>> {
  PaginationNotifier() : super(const AsyncValue.loading()) {
    _initialLoad();
  }

  /// The method to implement for fetching a specific page
  Future<List<Media>> fetchPage(int page);

  Future<void> _initialLoad() async {
    try {
      final items = await fetchPage(1);
      if (mounted) {
        state = AsyncValue.data(
          PaginationState(
            items: items,
            page: 1,
            hasMore: items.isNotEmpty, // Assuming empty means no more pages
          ),
        );
      }
    } catch (e, st) {
      if (mounted) {
        state = AsyncValue.error(e, st);
      }
    }
  }

  Future<void> loadMore() async {
    // Prevent concurrent loads or loading more when there's no more data
    if (state.isLoading || state.hasError) return;
    final currentState = state.value;
    if (currentState == null ||
        !currentState.hasMore ||
        currentState.isLoadingMore) {
      return;
    }

    // Set loading more state
    state = AsyncValue.data(
      currentState.copyWith(isLoadingMore: true, error: null),
    );

    try {
      final nextPage = currentState.page + 1;
      final newItems = await fetchPage(nextPage);

      if (mounted) {
        state = AsyncValue.data(
          currentState.copyWith(
            items: [...currentState.items, ...newItems],
            page: nextPage,
            hasMore: newItems.isNotEmpty,
            isLoadingMore: false,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        state = AsyncValue.data(
          currentState.copyWith(isLoadingMore: false, error: e.toString()),
        );
      }
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _initialLoad();
  }
}

// ============================================================================
// Concrete Implementations
// ============================================================================

class TrendingPaginationNotifier extends PaginationNotifier {
  final Ref ref;
  final MediaType? type;
  final String timeWindow;

  TrendingPaginationNotifier(this.ref, {this.type, this.timeWindow = 'week'});

  @override
  Future<List<Media>> fetchPage(int page) {
    return ref
        .read(tmdbRepositoryProvider)
        .getTrending(type: type, timeWindow: timeWindow, page: page);
  }
}

class PopularMoviesPaginationNotifier extends PaginationNotifier {
  final Ref ref;
  PopularMoviesPaginationNotifier(this.ref);

  @override
  Future<List<Media>> fetchPage(int page) {
    return ref.read(tmdbRepositoryProvider).getPopularMovies(page: page);
  }
}

class PopularTvPaginationNotifier extends PaginationNotifier {
  final Ref ref;
  PopularTvPaginationNotifier(this.ref);

  @override
  Future<List<Media>> fetchPage(int page) {
    return ref.read(tmdbRepositoryProvider).getPopularTvSeries(page: page);
  }
}

class TopRatedMoviesPaginationNotifier extends PaginationNotifier {
  final Ref ref;
  TopRatedMoviesPaginationNotifier(this.ref);

  @override
  Future<List<Media>> fetchPage(int page) {
    return ref.read(tmdbRepositoryProvider).getTopRatedMovies(page: page);
  }
}

class TopRatedTvPaginationNotifier extends PaginationNotifier {
  final Ref ref;
  TopRatedTvPaginationNotifier(this.ref);

  @override
  Future<List<Media>> fetchPage(int page) {
    return ref.read(tmdbRepositoryProvider).getTopRatedTvSeries(page: page);
  }
}

// ============================================================================
// Providers
// ============================================================================

final trendingPaginationProvider =
    StateNotifierProvider.family<
      TrendingPaginationNotifier,
      AsyncValue<PaginationState<Media>>,
      String
    >((ref, params) {
      // params format: 'type_timeWindow' e.g. 'movie_week' or 'all_day'
      final parts = params.split('_');
      final typeStr = parts[0];
      final timeWindow = parts[1];

      MediaType? type;
      if (typeStr == 'movie') type = MediaType.movie;
      if (typeStr == 'tv') type = MediaType.tv;

      return TrendingPaginationNotifier(
        ref,
        type: type,
        timeWindow: timeWindow,
      );
    });

final popularMoviesPaginationProvider =
    StateNotifierProvider<
      PopularMoviesPaginationNotifier,
      AsyncValue<PaginationState<Media>>
    >((ref) => PopularMoviesPaginationNotifier(ref));

final popularTvPaginationProvider =
    StateNotifierProvider<
      PopularTvPaginationNotifier,
      AsyncValue<PaginationState<Media>>
    >((ref) => PopularTvPaginationNotifier(ref));

final topRatedMoviesPaginationProvider =
    StateNotifierProvider<
      TopRatedMoviesPaginationNotifier,
      AsyncValue<PaginationState<Media>>
    >((ref) => TopRatedMoviesPaginationNotifier(ref));

final topRatedTvPaginationProvider =
    StateNotifierProvider<
      TopRatedTvPaginationNotifier,
      AsyncValue<PaginationState<Media>>
    >((ref) => TopRatedTvPaginationNotifier(ref));
