import 'package:stream_scout/utils/app_haptics.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/providers.dart';
import '../../data/models/media.dart';
import '../theme/app_theme.dart';
import '../../utils/home_widget_helper.dart';

/// "Tonight's Pick" — intelligent single recommendation with
/// weighted scoring that factors rating, genre match, and freshness.
class TonightsPickSheet extends ConsumerStatefulWidget {
  const TonightsPickSheet({super.key});

  @override
  ConsumerState<TonightsPickSheet> createState() => _TonightsPickSheetState();
}

class _TonightsPickSheetState extends ConsumerState<TonightsPickSheet> {
  Media? _currentPick;
  List<Media> _candidates = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  String? _aiPitch;

  @override
  void initState() {
    super.initState();
    _loadCandidates();
  }

  Future<void> _loadCandidates() async {
    setState(() => _isLoading = true);

    try {
      final tmdb = ref.read(tmdbRepositoryProvider);
      final prefs = await ref.read(userPreferencesProvider.future);
      final providerIds = prefs.tmdbProviderIds;
      final watchHistoryRepo = ref.read(watchHistoryRepositoryProvider);
      await watchHistoryRepo.init();
      final entries = await watchHistoryRepo.getAllEntries();
      final watchedIds = entries
          .map((e) => '${e.mediaType.name}_${e.mediaId}')
          .toSet();

      if (providerIds.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      // Fetch quality content from user's services
      final results = await Future.wait([
        tmdb.discoverMovies(
          withProviders: providerIds,
          watchRegion: prefs.countryCode,
          sortBy: 'vote_average.desc',
          minRating: max(7.0, prefs.minimumRating),
          maxAgeRating: prefs.maxAgeRating,
        ),
        tmdb.discoverTvSeries(
          withProviders: providerIds,
          watchRegion: prefs.countryCode,
          sortBy: 'vote_average.desc',
          minRating: max(7.0, prefs.minimumRating),
          maxAgeRating: prefs.maxAgeRating,
        ),
      ]);

      final combined = [...results[0], ...results[1]];

      // Filter out watched items
      final unseen = combined
          .where((m) => !watchedIds.contains('${m.type.name}_${m.id}'))
          .where((m) => m.voteCount >= 200)
          .toList();

      // Score and sort
      final topGenres = entries.isEmpty
          ? <int>{}
          : _getTopGenres(entries.expand((e) => e.genreIds).toList());

      unseen.sort((a, b) {
        final scoreA = _score(a, topGenres);
        final scoreB = _score(b, topGenres);
        return scoreB.compareTo(scoreA);
      });

      // Shuffle top 20 slightly for variety
      final top = unseen.take(20).toList()..shuffle(Random());

      setState(() {
        _candidates = top;
        _currentIndex = 0;
        _currentPick = top.isNotEmpty ? top[0] : null;
        _isLoading = false;
      });

      if (_currentPick != null) {
        _loadAiPitch();
        HomeWidgetHelper.updateWidget(
          title: _currentPick!.title,
          description: _currentPick!.overview.isNotEmpty
              ? _currentPick!.overview
              : "No description available",
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Set<int> _getTopGenres(List<int> allGenreIds) {
    final freq = <int, int>{};
    for (final g in allGenreIds) {
      freq[g] = (freq[g] ?? 0) + 1;
    }
    final sorted = freq.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(5).map((e) => e.key).toSet();
  }

  double _score(Media m, Set<int> topGenres) {
    double score = 0;
    // Rating weight (most important)
    score += m.voteAverage * 1.3;
    // Genre match
    final genreMatch = m.genreIds.where((g) => topGenres.contains(g)).length;
    score += genreMatch * 2.0;
    // Vote confidence
    if (m.voteCount >= 5000) {
      score += 1.5;
    } else if (m.voteCount >= 1000) {
      score += 0.8;
    }
    // Freshness bonus
    if (m.releaseDate != null) {
      final yearsOld = DateTime.now().difference(m.releaseDate!).inDays / 365;
      if (yearsOld < 2) {
        score += 1.0;
      } else if (yearsOld < 5) {
        score += 0.5;
      }
    }
    return score;
  }

  Future<void> _loadAiPitch() async {
    if (_currentPick == null) return;
    setState(() => _aiPitch = null);
    try {
      final gemini = ref.read(geminiServiceProvider);
      final pitch = await gemini.getWhyWatch(
        _currentPick!.title,
        _currentPick!.overview,
      );
      if (mounted && _currentPick != null) {
        setState(() => _aiPitch = pitch);
      }
    } catch (_) {
      // AI pitch is optional
    }
  }

  void _nextPick() {
    AppHaptics.mediumImpact();
    if (_candidates.isEmpty) return;
    setState(() {
      _currentIndex = (_currentIndex + 1) % _candidates.length;
      _currentPick = _candidates[_currentIndex];
      _aiPitch = null;
    });
    _loadAiPitch();
  }

  void _watchThis() async {
    if (_currentPick == null) return;
    AppHaptics.heavyImpact();
    context.pop(_currentPick);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: AppTheme.textMuted.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMd,
              vertical: 8,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.auto_fix_high_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Tonight's Pick",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFFD700)),
                  )
                : _currentPick == null
                ? _buildEmptyState()
                : _buildPickCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.movie_filter_outlined,
            size: 64,
            color: AppTheme.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            'Keine Empfehlungen verfügbar',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Bitte Streaming-Dienste in den Einstellungen auswählen',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildPickCard() {
    final media = _currentPick!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        children: [
          // Hero poster
          ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 2 / 3,
                      child: media.posterPath != null
                          ? CachedNetworkImage(
                              imageUrl: media.fullPosterPath,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: AppTheme.surface,
                              child: const Icon(
                                Icons.movie_outlined,
                                size: 80,
                                color: AppTheme.textMuted,
                              ),
                            ),
                    ),
                    // Gradient overlay at bottom
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 160,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.9),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Info overlay
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            media.title,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildInfoChip(
                                Icons.star_rounded,
                                media.voteAverage.toStringAsFixed(1),
                                AppTheme.getRatingColor(media.voteAverage),
                              ),
                              const SizedBox(width: 8),
                              _buildInfoChip(
                                Icons.calendar_today_rounded,
                                media.year,
                                AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              _buildInfoChip(
                                media.type == MediaType.movie
                                    ? Icons.movie_rounded
                                    : Icons.tv_rounded,
                                media.type.displayName,
                                AppTheme.primaryLight,
                              ),
                              if (media.runtime != null &&
                                  media.runtime! > 0) ...[
                                const SizedBox(width: 8),
                                _buildInfoChip(
                                  Icons.schedule_rounded,
                                  '${media.runtime! ~/ 60}h ${media.runtime! % 60}m',
                                  AppTheme.textSecondary,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 300.ms)
              .scale(
                begin: const Offset(0.95, 0.95),
                end: const Offset(1, 1),
                duration: 300.ms,
              ),

          const SizedBox(height: 16),

          // AI Pitch
          if (_aiPitch != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    size: 18,
                    color: Color(0xFFFFD700),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _aiPitch!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 300.ms),

          if (_aiPitch == null && _currentPick != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFFFD700).withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'AI überlegt...',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Overview
          if (media.overview.isNotEmpty)
            Text(
              media.overview,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              // "Not this one"
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _nextPick,
                  icon: const Icon(Icons.skip_next_rounded),
                  label: const Text('Nächster'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                    side: const BorderSide(color: AppTheme.surfaceBorder),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // "I'm watching this!"
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _watchThis,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Das schaue ich!'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
