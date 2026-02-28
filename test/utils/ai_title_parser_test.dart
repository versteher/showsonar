import 'package:flutter_test/flutter_test.dart';
import 'package:stream_scout/utils/ai_title_parser.dart';

void main() {
  group('AiTitleParser.extractTitles', () {
    test('extracts bold titles wrapped in double asterisks', () {
      const text =
          'Ich empfehle dir **Breaking Bad** und **Dark**. Beide sind großartig!';
      final titles = AiTitleParser.extractTitles(text);
      expect(titles, containsAll(['Breaking Bad', 'Dark']));
    });

    test('extracts quoted titles wrapped in double quotes', () {
      const text = 'Schau dir "The Shawshank Redemption" an oder "Inception".';
      final titles = AiTitleParser.extractTitles(text);
      expect(titles, containsAll(['The Shawshank Redemption', 'Inception']));
    });

    test('extracts both bold and quoted titles from mixed text', () {
      const text = '**Stranger Things** ist super, und "Interstellar" auch!';
      final titles = AiTitleParser.extractTitles(text);
      expect(titles, containsAll(['Stranger Things', 'Interstellar']));
    });

    test('returns empty list for text with no titles', () {
      const text = 'Hier sind keine besonderen Empfehlungen drin.';
      final titles = AiTitleParser.extractTitles(text);
      expect(titles, isEmpty);
    });

    test('returns empty list for empty string', () {
      final titles = AiTitleParser.extractTitles('');
      expect(titles, isEmpty);
    });

    test('deduplicates titles that appear multiple times', () {
      const text = '**Dark** ist toll. Schau dir **Dark** an!';
      final titles = AiTitleParser.extractTitles(text);
      expect(titles.where((t) => t == 'Dark').length, 1);
    });

    test('ignores very short bold text (single words like emphasis)', () {
      const text =
          '**ja** und **nein** sind keine Titel, aber **The Matrix** schon.';
      final titles = AiTitleParser.extractTitles(text);
      expect(titles, contains('The Matrix'));
      expect(titles, isNot(contains('ja')));
      expect(titles, isNot(contains('nein')));
    });

    test('trims whitespace around extracted titles', () {
      const text = '** Breaking Bad ** und " Inception "';
      final titles = AiTitleParser.extractTitles(text);
      expect(titles, containsAll(['Breaking Bad', 'Inception']));
    });
  });
}
