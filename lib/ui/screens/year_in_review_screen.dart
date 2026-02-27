import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neon_voyager/config/api_config.dart';

import '../../config/providers/year_in_review_provider.dart';
import '../../data/models/genre.dart';
import '../theme/app_theme.dart';
import '../widgets/branded_loading_indicator.dart';

/// Spotify Wrapped-style animated year-in-review screen.
class YearInReviewScreen extends ConsumerStatefulWidget {
  final int year;

  const YearInReviewScreen({super.key, required this.year});

  @override
  ConsumerState<YearInReviewScreen> createState() => _YearInReviewScreenState();
}

class _YearInReviewScreenState extends ConsumerState<YearInReviewScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;
  late int _selectedYear;

  static const _totalSlides = 5;

  // Neon gradient backgrounds for each slide
  static const _slideGradients = [
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1A003E), Color(0xFF0F0F1A)],
    ),
    LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF001A3E), Color(0xFF0F0F1A)],
    ),
    LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [Color(0xFF1A2800), Color(0xFF0F0F1A)],
    ),
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF3E0A00), Color(0xFF0F0F1A)],
    ),
    LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF001A3E), Color(0xFF3E001A)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.year;
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalSlides - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final reviewAsync = ref.watch(yearInReviewProvider(_selectedYear));
    final availableYearsAsync = ref.watch(reviewableYearsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: availableYearsAsync.when(
          data: (years) {
            if (years.length <= 1) {
              return Text(
                '$_selectedYear in Review',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            }
            return DropdownButton<int>(
              value: _selectedYear,
              dropdownColor: AppTheme.surface,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              underline: const SizedBox.shrink(),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white,
              ),
              items: years
                  .map(
                    (y) =>
                        DropdownMenuItem(value: y, child: Text('$y in Review')),
                  )
                  .toList(),
              onChanged: (y) {
                if (y != null && y != _selectedYear) {
                  setState(() {
                    _selectedYear = y;
                    _currentPage = 0;
                  });
                  _pageController.jumpToPage(0);
                }
              },
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => Text(
            '$_selectedYear in Review',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: reviewAsync.when(
        data: (data) {
          if (!data.hasEnoughData) {
            return _buildInsufficientDataState(context);
          }
          return _buildReviewPages(context, data);
        },
        loading: () => const Center(child: BrandedLoadingIndicator()),
        error: (e, _) => Center(
          child: Text(
            'Could not load review: $e',
            style: const TextStyle(color: AppTheme.error),
          ),
        ),
      ),
    );
  }

  Widget _buildInsufficientDataState(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingXl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.movie_filter_rounded,
                size: 80,
                color: AppTheme.primary,
              ),
              const SizedBox(height: AppTheme.spacingLg),
              Text(
                'Not enough data yet',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingMd),
              Text(
                'Watch at least 3 titles in $_selectedYear to unlock your Year in Review.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewPages(BuildContext context, YearInReviewData data) {
    return Stack(
      children: [
        // Gradient background that transitions with current page
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          decoration: BoxDecoration(gradient: _slideGradients[_currentPage]),
        ),

        // Page content
        PageView(
          controller: _pageController,
          onPageChanged: (page) => setState(() => _currentPage = page),
          children: [
            _Slide1Intro(data: data),
            _Slide2Genres(data: data),
            _Slide3TopPicks(data: data),
            _Slide4Ratings(data: data),
            _Slide5Share(data: data, year: _selectedYear),
          ],
        ),

        // Dot indicator
        Positioned(
          bottom: 32,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _totalSlides,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == i ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == i
                          ? AppTheme.primary
                          : AppTheme.textMuted,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              // Navigation row
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingXl,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentPage > 0)
                      _NavButton(
                        icon: Icons.arrow_back_rounded,
                        label: 'Back',
                        onTap: _prevPage,
                        secondary: true,
                      )
                    else
                      const SizedBox(width: 100),
                    if (_currentPage < _totalSlides - 1)
                      _NavButton(
                        icon: Icons.arrow_forward_rounded,
                        label: 'Next',
                        onTap: _nextPage,
                        secondary: false,
                      )
                    else
                      const SizedBox(width: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// Navigation Button
// ============================================================================

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.secondary,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool secondary;

  @override
  Widget build(BuildContext context) {
    final color = secondary ? AppTheme.textMuted : AppTheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingSm,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: secondary ? 0.1 : 0.2),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: secondary
              ? [
                  Icon(icon, color: color, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(color: color, fontWeight: FontWeight.w600),
                  ),
                ]
              : [
                  Text(
                    label,
                    style: TextStyle(color: color, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 6),
                  Icon(icon, color: color, size: 18),
                ],
        ),
      ),
    );
  }
}

// ============================================================================
// Slide 1 — Intro / Hero
// ============================================================================

class _Slide1Intro extends StatelessWidget {
  const _Slide1Intro({required this.data});
  final YearInReviewData data;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.spacingXl,
          80,
          AppTheme.spacingXl,
          120,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Neon year label
            Text(
              '${data.year}',
              style: TextStyle(
                fontSize: 96,
                fontWeight: FontWeight.w900,
                foreground: Paint()
                  ..shader = const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.secondary],
                  ).createShader(const Rect.fromLTWH(0, 0, 200, 100)),
                height: 1,
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0),

            const SizedBox(height: AppTheme.spacingSm),

            Text(
              'Year in\nReview',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.15,
              ),
            ).animate().fadeIn(delay: 300.ms, duration: 600.ms),

            const SizedBox(height: AppTheme.spacingXl),

            // Stats row
            Row(
              children: [
                _StatPill(
                  label: 'Titles',
                  value: data.totalTitlesWatched.toString(),
                  color: AppTheme.primary,
                ),
                const SizedBox(width: AppTheme.spacingMd),
                _StatPill(
                  label: 'Hours',
                  value: data.totalHoursWatched.toString(),
                  color: AppTheme.secondary,
                ),
              ],
            ).animate().fadeIn(delay: 600.ms, duration: 600.ms),

            const SizedBox(height: AppTheme.spacingMd),

            Row(
              children: [
                _StatPill(
                  label: 'Movies',
                  value: data.totalMovies.toString(),
                  color: AppTheme.accent,
                ),
                const SizedBox(width: AppTheme.spacingMd),
                _StatPill(
                  label: 'Series',
                  value: data.totalSeries.toString(),
                  color: AppTheme.success,
                ),
              ],
            ).animate().fadeIn(delay: 800.ms, duration: 600.ms),

            const SizedBox(height: AppTheme.spacingXl),

            Text(
              'Swipe to see your story →',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 14,
              ),
            ).animate().fadeIn(delay: 1200.ms),
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Slide 2 — Top Genres
// ============================================================================

class _Slide2Genres extends StatelessWidget {
  const _Slide2Genres({required this.data});
  final YearInReviewData data;

  static const _barColors = [
    AppTheme.primary,
    AppTheme.secondary,
    AppTheme.accent,
    AppTheme.success,
    AppTheme.warning,
  ];

  @override
  Widget build(BuildContext context) {
    final genres = data.topGenres;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.spacingXl,
          80,
          AppTheme.spacingXl,
          120,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Your Top\nGenres',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.15,
              ),
            ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.2, end: 0),

            const SizedBox(height: AppTheme.spacingXl),

            if (genres.isEmpty)
              Text(
                'No genre data yet.',
                style: TextStyle(color: AppTheme.textMuted),
              )
            else
              ...genres.asMap().entries.map((mapEntry) {
                final i = mapEntry.key;
                final entry = mapEntry.value;
                final genreName = Genre.getNameById(entry.key);
                final maxVal = genres.first.value.toDouble();
                final fraction = entry.value / maxVal;
                final color = _barColors[i % _barColors.length];

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${i + 1}. $genreName',
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${entry.value} ${entry.value == 1 ? 'title' : 'titles'}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: fraction),
                          duration: Duration(milliseconds: 600 + i * 150),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, _) {
                            return LinearProgressIndicator(
                              value: value,
                              backgroundColor: color.withValues(alpha: 0.15),
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                              minHeight: 12,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(
                  delay: Duration(milliseconds: 200 + i * 100),
                  duration: 400.ms,
                );
              }),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Slide 3 — Top Picks
// ============================================================================

class _Slide3TopPicks extends StatelessWidget {
  const _Slide3TopPicks({required this.data});
  final YearInReviewData data;

  @override
  Widget build(BuildContext context) {
    final entries = data.topRated;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.spacingXl,
          80,
          AppTheme.spacingXl,
          120,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Your Top\nPicks',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.15,
              ),
            ).animate().fadeIn(duration: 500.ms).slideX(begin: 0.2, end: 0),

            const SizedBox(height: AppTheme.spacingXl),

            if (entries.isEmpty)
              Text(
                'Rate some titles to see your favourites here.',
                style: TextStyle(color: AppTheme.textMuted),
              )
            else
              ...entries.asMap().entries.map((mapEntry) {
                final i = mapEntry.key;
                final entry = mapEntry.value;
                final posterUrl = entry.posterPath != null
                    ? '${ApiConfig.tmdbImageBaseUrl}/${ApiConfig.posterSizeMedium}${entry.posterPath}'
                    : null;

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                  child: Row(
                    children: [
                      // Medal / rank
                      SizedBox(
                        width: 32,
                        child: Text(
                          _medal(i),
                          style: const TextStyle(fontSize: 22),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingSm),
                      // Poster
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusSmall,
                        ),
                        child: (posterUrl != null)
                            ? CachedNetworkImage(
                                imageUrl: posterUrl,
                                width: 48,
                                height: 72,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) =>
                                    _PosterPlaceholder(),
                              )
                            : _PosterPlaceholder(),
                      ),
                      const SizedBox(width: AppTheme.spacingMd),
                      // Title + rating
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: AppTheme.warning,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  entry.userRating!.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: AppTheme.warning,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  entry.mediaType.displayName,
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(
                  delay: Duration(milliseconds: 150 + i * 100),
                  duration: 400.ms,
                );
              }),
          ],
        ),
      ),
    );
  }

  String _medal(int index) {
    switch (index) {
      case 0:
        return '🥇';
      case 1:
        return '🥈';
      case 2:
        return '🥉';
      default:
        return '${index + 1}.';
    }
  }
}

class _PosterPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 72,
      color: AppTheme.surface,
      child: const Icon(Icons.movie_rounded, color: AppTheme.textMuted),
    );
  }
}

// ============================================================================
// Slide 4 — Ratings
// ============================================================================

class _Slide4Ratings extends StatelessWidget {
  const _Slide4Ratings({required this.data});
  final YearInReviewData data;

  @override
  Widget build(BuildContext context) {
    final avg = data.averageUserRating;
    final rated = data.ratedCount;
    final totalWatched = data.totalTitlesWatched;
    final ratedPct = totalWatched > 0
        ? (rated / totalWatched * 100).round()
        : 0;

    final sentiment = avg >= 8
        ? ('You loved almost everything! 🌟', AppTheme.success)
        : avg >= 6
        ? ('You had a solid year 👍', AppTheme.primary)
        : avg >= 4
        ? ('Mixed bag — quality was hit-or-miss 🎲', AppTheme.warning)
        : ('Tough crowd — very selective! 🎯', AppTheme.error);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.spacingXl,
          80,
          AppTheme.spacingXl,
          120,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Your Ratings',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.15,
              ),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2, end: 0),

            const SizedBox(height: AppTheme.spacingXl),

            // Big average rating
            if (rated > 0) ...[
              Center(
                child: Column(
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: avg),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return Text(
                          value.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 80,
                            fontWeight: FontWeight.w900,
                            foreground: Paint()
                              ..shader =
                                  const LinearGradient(
                                    colors: [
                                      AppTheme.warning,
                                      AppTheme.secondary,
                                    ],
                                  ).createShader(
                                    const Rect.fromLTWH(0, 0, 120, 80),
                                  ),
                          ),
                        );
                      },
                    ).animate().fadeIn(delay: 200.ms),
                    const Text(
                      'average rating',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spacingXl),

              // Star bar
              _StarBar(rating: avg),

              const SizedBox(height: AppTheme.spacingXl),

              // Sentiment chip
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: sentiment.$2.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: sentiment.$2.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    sentiment.$1,
                    style: TextStyle(
                      color: sentiment.$2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ).animate().fadeIn(delay: 600.ms, duration: 500.ms),
              ),

              const SizedBox(height: AppTheme.spacingLg),

              Center(
                child: Text(
                  'You rated $rated of $totalWatched titles ($ratedPct%)',
                  style: const TextStyle(color: Colors.white60, fontSize: 13),
                ).animate().fadeIn(delay: 800.ms),
              ),
            ] else
              Center(
                child: Text(
                  'No ratings yet for $_selectedYear',
                  style: const TextStyle(color: AppTheme.textMuted),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ignore: unused_field
  int get _selectedYear => data.year;
}

class _StarBar extends StatelessWidget {
  const _StarBar({required this.rating});
  final double rating;

  @override
  Widget build(BuildContext context) {
    final fullStars = (rating / 2).floor(); // convert /10 to /5
    final halfStar = ((rating / 2) - fullStars) >= 0.5;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final isFullStar = i < fullStars;
        final isHalfStar = !isFullStar && i == fullStars && halfStar;
        return Icon(
          isFullStar
              ? Icons.star_rounded
              : isHalfStar
              ? Icons.star_half_rounded
              : Icons.star_outline_rounded,
          color: AppTheme.warning,
          size: 36,
        );
      }),
    );
  }
}

// ============================================================================
// Slide 5 — Share / Summary
// ============================================================================

class _Slide5Share extends StatelessWidget {
  const _Slide5Share({required this.data, required this.year});
  final YearInReviewData data;
  final int year;

  String _buildShareText() {
    final lines = <String>[
      '🎬 My $year in Review',
      '',
      '🍿 ${data.totalTitlesWatched} titles watched (${data.totalMovies} movies, ${data.totalSeries} series)',
      '⏱ ${data.totalHoursWatched} hours of screen time',
      if (data.topGenres.isNotEmpty)
        '🎭 Top genre: ${Genre.getNameById(data.topGenres.first.key)}',
      if (data.ratedCount > 0)
        '⭐ Average rating: ${data.averageUserRating.toStringAsFixed(1)}/10',
      if (data.topRated.isNotEmpty)
        '🏆 Favourite: ${data.topRated.first.title}',
      '',
      '#NeonVoyager #MovieYear$year',
    ];
    return lines.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.spacingXl,
          80,
          AppTheme.spacingXl,
          120,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                  'That\'s a Wrap!',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: [AppTheme.primary, AppTheme.secondary],
                      ).createShader(const Rect.fromLTWH(0, 0, 300, 60)),
                  ),
                  textAlign: TextAlign.center,
                )
                .animate()
                .fadeIn(duration: 600.ms)
                .scale(begin: const Offset(0.8, 0.8)),

            const SizedBox(height: AppTheme.spacingXl),

            // Summary card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A1A3E), Color(0xFF0F0F1A)],
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                children: [
                  _SummaryRow(
                    emoji: '🍿',
                    text: '${data.totalTitlesWatched} titles watched',
                  ),
                  _SummaryRow(
                    emoji: '⏱',
                    text: '${data.totalHoursWatched}h of screen time',
                  ),
                  _SummaryRow(
                    emoji: '🎭',
                    text: 'Top genre: ${data.topGenreName}',
                  ),
                  if (data.ratedCount > 0)
                    _SummaryRow(
                      emoji: '⭐',
                      text:
                          'Avg rating: ${data.averageUserRating.toStringAsFixed(1)}/10',
                    ),
                  if (data.topRated.isNotEmpty)
                    _SummaryRow(
                      emoji: '🏆',
                      text: 'Fave: ${data.topRated.first.title}',
                    ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms, duration: 600.ms),

            const SizedBox(height: AppTheme.spacingXl),

            // Share button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final text = _buildShareText();
                  await Clipboard.setData(ClipboardData(text: text));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: const [
                            Icon(
                              Icons.check_circle_rounded,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8),
                            Text('Copied to clipboard!'),
                          ],
                        ),
                        backgroundColor: AppTheme.success,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMedium,
                          ),
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.copy_rounded),
                label: const Text('Copy Summary'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppTheme.spacingMd,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.emoji, required this.text});
  final String emoji;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
