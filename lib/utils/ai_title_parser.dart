/// Parses AI chat responses to extract movie/series titles.
///
/// Detects titles wrapped in **bold** markers or "double quotes".
class AiTitleParser {
  AiTitleParser._();

  // Pattern: **Title Here**
  static final RegExp _boldPattern = RegExp(r'\*\*(.+?)\*\*');

  // Pattern: "Title Here"
  static final RegExp _quotedPattern = RegExp(r'"(.+?)"');

  /// Extract a deduplicated list of titles from AI-generated [text].
  static List<String> extractTitles(String text) {
    if (text.isEmpty) return [];

    final seen = <String>{};
    final titles = <String>[];

    // Extract bold titles (min length filter)
    for (final match in _boldPattern.allMatches(text)) {
      final title = match.group(1)?.trim();
      if (title != null && _isTitleLikelyMediaName(title) && seen.add(title)) {
        titles.add(title);
      }
    }

    // Extract quoted titles
    for (final match in _quotedPattern.allMatches(text)) {
      final title = match.group(1)?.trim();
      if (title != null && title.isNotEmpty && seen.add(title)) {
        titles.add(title);
      }
    }

    return titles;
  }

  /// Return true if the bold text is likely a media title, not just emphasis.
  ///
  /// Single words must start with an uppercase letter (filters out
  /// German emphasis like **ja**, **nein**, **gut** while keeping
  /// titles like **Dark**, **Inception**).
  static bool _isTitleLikelyMediaName(String text) {
    if (text.isEmpty) return false;
    final words = text.split(RegExp(r'\s+'));
    // Multi-word → likely a title
    if (words.length >= 2) return true;
    // Single word → must start with uppercase letter and be > 2 chars
    return text.length > 2 &&
        text[0] == text[0].toUpperCase() &&
        text[0] != text[0].toLowerCase();
  }
}
