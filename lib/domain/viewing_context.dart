/// Viewing context for one-tap content filtering.
///
/// Each context applies genre include/exclude lists and an optional
/// age-rating cap to every recommendation section on the home screen.
enum ViewingContext { all, kids, dateNight, solo }

/// Genre + age-rating filter derived from a [ViewingContext].
class ViewingContextFilter {
  /// Genres to include (OR semantics — "any of these").
  final List<int>? includeGenreIds;

  /// Genres to exclude.
  final List<int>? excludeGenreIds;

  /// If set, caps the effective age rating (min with user pref).
  final int? maxAgeRatingOverride;

  const ViewingContextFilter({
    this.includeGenreIds,
    this.excludeGenreIds,
    this.maxAgeRatingOverride,
  });

  static const empty = ViewingContextFilter();

  /// Build a filter for the given [context].
  ///
  /// [favoriteGenreIds] is used for [ViewingContext.solo] — if the user has
  /// chosen favorite genres, Solo mode surfaces those; otherwise it degrades
  /// to "All" (no filter).
  static ViewingContextFilter forContext(
    ViewingContext context, {
    List<int> favoriteGenreIds = const [],
  }) {
    switch (context) {
      case ViewingContext.all:
        return empty;

      case ViewingContext.kids:
        // Animation(16), Family(10751), Adventure(12), Kids(10762)
        // Block Horror(27), Crime(80), Thriller(53)
        return const ViewingContextFilter(
          includeGenreIds: [16, 10751, 12, 10762],
          excludeGenreIds: [27, 80, 53],
          maxAgeRatingOverride: 12,
        );

      case ViewingContext.dateNight:
        // Romance(10749), Thriller(53), Comedy(35), Drama(18)
        // Block Animation(16), Kids(10762), Horror(27)
        return const ViewingContextFilter(
          includeGenreIds: [10749, 53, 35, 18],
          excludeGenreIds: [16, 10762, 27],
        );

      case ViewingContext.solo:
        if (favoriteGenreIds.isEmpty) return empty;
        return ViewingContextFilter(
          includeGenreIds: favoriteGenreIds,
        );
    }
  }
}
