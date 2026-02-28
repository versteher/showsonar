import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/providers/year_in_review_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/branded_loading_indicator.dart';
import 'year_review_genres_slide.dart';
import 'year_review_intro_slide.dart';
import 'year_review_ratings_slide.dart';
import 'year_review_share_slide.dart';
import 'year_review_top_picks_slide.dart';

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
          onPressed: () => context.pop(),
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
            Slide1Intro(data: data),
            Slide2Genres(data: data),
            Slide3TopPicks(data: data),
            Slide4Ratings(data: data),
            Slide5Share(data: data, year: _selectedYear),
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
