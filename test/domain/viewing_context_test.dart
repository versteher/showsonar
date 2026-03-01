import 'package:flutter_test/flutter_test.dart';
import 'package:stream_scout/domain/viewing_context.dart';

void main() {
  group('ViewingContextFilter', () {
    test('all context returns empty filter', () {
      final filter = ViewingContextFilter.forContext(ViewingContext.all);
      expect(filter.includeGenreIds, isNull);
      expect(filter.excludeGenreIds, isNull);
      expect(filter.maxAgeRatingOverride, isNull);
    });

    test('kids context includes family genres and excludes horror/crime', () {
      final filter = ViewingContextFilter.forContext(ViewingContext.kids);
      expect(filter.includeGenreIds, containsAll([16, 10751, 12, 10762]));
      expect(filter.excludeGenreIds, containsAll([27, 80, 53]));
      expect(filter.maxAgeRatingOverride, 12);
    });

    test('dateNight context includes romance genres and excludes kids/horror', () {
      final filter = ViewingContextFilter.forContext(ViewingContext.dateNight);
      expect(filter.includeGenreIds, containsAll([10749, 53, 35, 18]));
      expect(filter.excludeGenreIds, containsAll([16, 10762, 27]));
      expect(filter.maxAgeRatingOverride, isNull);
    });

    test('solo context uses favorite genres when available', () {
      final filter = ViewingContextFilter.forContext(
        ViewingContext.solo,
        favoriteGenreIds: [28, 878],
      );
      expect(filter.includeGenreIds, [28, 878]);
      expect(filter.excludeGenreIds, isNull);
      expect(filter.maxAgeRatingOverride, isNull);
    });

    test('solo context degrades to empty when no favorites', () {
      final filter = ViewingContextFilter.forContext(ViewingContext.solo);
      expect(filter.includeGenreIds, isNull);
      expect(filter.excludeGenreIds, isNull);
      expect(filter.maxAgeRatingOverride, isNull);
    });
  });
}
