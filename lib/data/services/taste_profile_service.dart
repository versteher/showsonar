import 'dart:convert';
import '../models/watch_history_entry.dart';
import '../repositories/watch_history_repository.dart';

/// Represents a shareable taste profile containing watch history and preferences
class TasteProfile {
  static const int version = 1;

  final String exportedAt;
  final int schemaVersion;
  final List<Map<String, dynamic>> entries;
  final Map<String, dynamic> stats;

  const TasteProfile({
    required this.exportedAt,
    required this.schemaVersion,
    required this.entries,
    required this.stats,
  });

  Map<String, dynamic> toJson() => {
    'version': schemaVersion,
    'exportedAt': exportedAt,
    'entries': entries,
    'stats': stats,
  };

  factory TasteProfile.fromJson(Map<String, dynamic> json) {
    return TasteProfile(
      schemaVersion: (json['version'] as num?)?.toInt() ?? 1,
      exportedAt: json['exportedAt'] as String? ?? '',
      entries:
          (json['entries'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
          [],
      stats: (json['stats'] as Map<String, dynamic>?) ?? {},
    );
  }
}

/// Service to export and import watch history as a shareable taste profile
class TasteProfileService {
  final WatchHistoryRepository _repo;

  TasteProfileService(this._repo);

  /// Export watch history as a JSON string for sharing
  Future<String> export() async {
    final entries = await _repo.getAllEntries();
    final jsonEntries = entries.map((e) => e.toJson()).toList();

    // Compute stats
    final ratedEntries = entries.where((e) => e.isRated).toList();
    final avgRating = ratedEntries.isEmpty
        ? 0.0
        : ratedEntries.map((e) => e.userRating!).reduce((a, b) => a + b) /
              ratedEntries.length;

    // Top genres
    final genreFreq = <int, int>{};
    for (final e in entries) {
      for (final g in e.genreIds) {
        genreFreq[g] = (genreFreq[g] ?? 0) + 1;
      }
    }
    final topGenres =
        (genreFreq.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
            .take(5)
            .map((e) => e.key)
            .toList();

    final profile = TasteProfile(
      exportedAt: DateTime.now().toIso8601String(),
      schemaVersion: TasteProfile.version,
      entries: jsonEntries,
      stats: {
        'totalWatched': entries.length,
        'totalRated': ratedEntries.length,
        'averageRating': double.parse(avgRating.toStringAsFixed(2)),
        'topGenreIds': topGenres,
      },
    );

    return const JsonEncoder.withIndent('  ').convert(profile.toJson());
  }

  /// Import a taste profile JSON string. Returns the number of new entries added
  /// and the number of entries that were already in history (skipped).
  Future<({int imported, int skipped})> import(String jsonString) async {
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    final profile = TasteProfile.fromJson(data);

    int imported = 0;
    int skipped = 0;

    for (final entryJson in profile.entries) {
      try {
        final entry = WatchHistoryEntry.fromJson(entryJson);
        final existing = await _repo.getEntry(entry.mediaId, entry.mediaType);
        if (existing != null) {
          skipped++;
        } else {
          _repo.addToHistory(entry);
          imported++;
        }
      } catch (_) {
        // Invalid entry, skip
        skipped++;
      }
    }

    return (imported: imported, skipped: skipped);
  }

  /// Parse a profile JSON string without importing — for preview before confirmation
  TasteProfile? preview(String jsonString) {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      return TasteProfile.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  /// Compute taste overlap score (0.0-1.0) between current history and an imported profile
  Future<double> computeOverlap(TasteProfile other) async {
    final myEntries = await _repo.getAllEntries();
    final myKeys = myEntries
        .map((e) => '${e.mediaType.name}_${e.mediaId}')
        .toSet();

    if (myKeys.isEmpty || other.entries.isEmpty) return 0.0;

    final theirKeys = other.entries
        .map((e) => '${e['mediaType']}_${e['mediaId']}')
        .toSet();

    final overlap = myKeys.intersection(theirKeys).length;
    final union = myKeys.union(theirKeys).length;

    return union > 0 ? overlap / union : 0.0;
  }
}
