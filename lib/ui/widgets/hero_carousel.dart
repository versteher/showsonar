import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:neon_voyager/ui/widgets/branded_loading_indicator.dart';
import '../../config/providers.dart';
import '../../data/models/media.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import 'error_retry_widget.dart';

/// Hero carousel showing top trending items with auto-scroll
class HeroCarousel extends ConsumerStatefulWidget {
  final Function(Media) onMediaTap;

  const HeroCarousel({super.key, required this.onMediaTap});

  @override
  ConsumerState<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends ConsumerState<HeroCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.92);
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        final trendingAsync = ref.read(trendingProvider);
        final maxPage = trendingAsync.valueOrNull?.length.clamp(0, 5) ?? 5;
        if (maxPage > 0) {
          final nextPage = (_currentPage + 1) % maxPage;
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutCubic,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trendingAsync = ref.watch(trendingProvider);

    return trendingAsync.when(
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        final heroItems = items.take(5).toList();

        return Column(
          children: [
            SizedBox(
              height: 300,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                itemCount: heroItems.length,
                itemBuilder: (context, index) {
                  final media = heroItems[index];
                  return _buildHeroCard(context, media);
                },
              ),
            ),
            const SizedBox(height: 12),
            // Page dots — each announces its position for screen readers
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(heroItems.length, (index) {
                final isActive = index == _currentPage;
                final l10n = AppLocalizations.of(context)!;
                return Semantics(
                  label: l10n.semanticPageDot(index + 1, heroItems.length),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppTheme.primary
                          : AppTheme.textMuted.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: AppTheme.primary.withValues(alpha: 0.5),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
                    ),
                  ),
                );
              }),
            ),
          ],
        ).animate().fadeIn(duration: 600.ms);
      },
      loading: () => SizedBox(
        height: 300,
        child: Center(child: BrandedLoadingIndicator(width: 80, height: 80)),
      ),
      error: (error, stackTrace) => ErrorRetryWidget(
        compact: true,
        message: 'Trends konnten nicht geladen werden',
        onRetry: () => ref.invalidate(trendingProvider),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, Media media) {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      button: true,
      label: l10n.semanticTrendingCard(media.title),
      child: GestureDetector(
        onTap: () => widget.onMediaTap(media),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.15),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          // All content inside the card is decorative — the Semantics node above
          // (label: "Trending: {title}") provides the accessible description.
          child: ExcludeSemantics(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background Image
                Hero(
                  tag: 'carousel_poster_${media.type.name}_${media.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    child: media.backdropPath != null
                        ? CachedNetworkImage(
                            imageUrl: media.fullBackdropPath,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                Container(color: AppTheme.surface),
                            errorWidget: (context, url, error) =>
                                Container(color: AppTheme.surface),
                          )
                        : Container(color: AppTheme.surface),
                  ),
                ),

                // Gradient Overlay
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.3),
                        Colors.black.withValues(alpha: 0.85),
                      ],
                      stops: const [0.3, 0.6, 1.0],
                    ),
                  ),
                ),

                // Content
                Positioned(
                  left: AppTheme.spacingMd,
                  right: AppTheme.spacingMd,
                  bottom: AppTheme.spacingMd,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Trending badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withValues(alpha: 0.4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.trending_up_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Trending',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppTheme.spacingSm),

                      // Title
                      Hero(
                        tag: 'carousel_title_${media.type.name}_${media.id}',
                        child: Material(
                          type: MaterialType.transparency,
                          child: Text(
                            media.title,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 10,
                                      color: Colors.black.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Info Row
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
                        ],
                      ),

                      // Provider Icons
                      if (media.providerData.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 28,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount: media.providerData.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final logoUrl = media.providerData[index].logoUrl;
                              return Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: logoUrl.startsWith('assets/')
                                      ? Image.asset(
                                          logoUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stack) =>
                                                  const Icon(
                                                    Icons.movie,
                                                    size: 14,
                                                    color: Colors.white54,
                                                  ),
                                        )
                                      : CachedNetworkImage(
                                          imageUrl: logoUrl,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              Container(
                                                color: Colors.white10,
                                                child: const Center(
                                                  child: SizedBox(
                                                    width: 10,
                                                    height: 10,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 1.5,
                                                          color: Colors.white54,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                          errorWidget: (context, url, error) =>
                                              const Icon(
                                                Icons.movie,
                                                size: 14,
                                                color: Colors.white54,
                                              ),
                                        ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
