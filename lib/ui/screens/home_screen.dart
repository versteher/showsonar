import 'package:stream_scout/utils/app_haptics.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:stream_scout/l10n/app_localizations.dart';
import '../../config/providers.dart';
import '../../config/providers/curated_providers.dart';
import '../../data/models/media.dart';
import '../theme/app_theme.dart';
import '../widgets/media_section.dart';
import '../widgets/viewing_context_chip_bar.dart';
import '../widgets/continue_watching_section.dart';
import '../widgets/hero_carousel.dart';
import '../widgets/upcoming_card.dart';
import '../widgets/hide_watched_toggle.dart';
import '../widgets/filter_settings_sheet.dart';
import '../widgets/error_retry_widget.dart';

import '../widgets/because_you_watched_section.dart';
import '../widgets/tonights_pick_sheet.dart';
import '../widgets/curated_collections_section.dart';
import '../widgets/long_press_menu_sheet.dart';

/// Home screen showing personalized recommendations and trending content
class HomeScreen extends ConsumerStatefulWidget {
  final VoidCallback? onSettingsTap;
  final VoidCallback? onSearchTap;

  const HomeScreen({super.key, this.onSettingsTap, this.onSearchTap});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  /// Pull-to-refresh: invalidate providers and await actual data (#9 fix)
  Future<void> _onRefresh() async {
    AppHaptics.mediumImpact();
    ref.invalidate(trendingProvider);
    ref.invalidate(upcomingProvider);
    ref.invalidate(becauseYouWatchedProvider);
    ref.invalidate(curatedCollectionProvider);
    ref.invalidate(seasonalProvider);
    await ref.read(trendingProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'tonights_pick',
        onPressed: () {
          AppHaptics.mediumImpact();
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (_) => const TonightsPickSheet(),
          );
        },
        backgroundColor: const Color(0xFFFFD700),
        child: const Icon(
          Icons.auto_fix_high_rounded,
          color: Colors.black87,
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppTheme.primary,
          backgroundColor: AppTheme.surface,
          displacement: 60,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // App Bar
              SliverAppBar(
                floating: true,
                backgroundColor: Colors.transparent,
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusSmall,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.4),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.play_arrow_rounded, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: ShaderMask(
                        shaderCallback: (bounds) =>
                            AppTheme.primaryGradient.createShader(bounds),
                        child: Text(
                          'ShowSonar',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.surface.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.tune_rounded, size: 20),
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (context) => const FilterSettingsSheet(),
                      );
                    },
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.surface.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.search_rounded, size: 20),
                    ),
                    onPressed:
                        widget.onSearchTap ?? () => _navigateToSearch(context),
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.surface.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.settings_rounded, size: 20),
                    ),
                    onPressed: widget.onSettingsTap,
                  ),
                  const SizedBox(width: 8),
                ],
              ),

              // Hero Carousel
              SliverToBoxAdapter(
                child: HeroCarousel(
                  onMediaTap: (media) =>
                      _navigateToDetail(context, media, 'carousel'),
                ),
              ),

              // Continue Watching (only visible when entries exist)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: AppTheme.spacingLg),
                  child: ContinueWatchingSection(),
                ),
              ),

              // Because You Watched (only visible with rated history)
              SliverToBoxAdapter(
                child: BecauseYouWatchedSection(
                  onMediaTap: (media, prefix) =>
                      _navigateToDetail(context, media, prefix),
                  onMediaLongPress: (media) =>
                      showLongPressMenu(context, ref, media),
                ),
              ),

              // Viewing Context Chips + Hide Watched Toggle
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: AppTheme.spacingLg),
                  child: Column(
                    children: const [
                      ViewingContextChipBar(),
                      SizedBox(height: 8),
                      HideWatchedToggle(),
                    ],
                  ),
                ),
              ),

              // Standard Collections Grid
              SliverPadding(
                padding: const EdgeInsets.only(top: AppTheme.spacingLg),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        AppTheme.isTablet(context) ||
                            AppTheme.isDesktop(context)
                        ? 2
                        : 1,
                    mainAxisExtent: 340,
                    crossAxisSpacing: 0,
                    mainAxisSpacing: AppTheme.spacingLg,
                  ),
                  delegate: SliverChildListDelegate([
                    // Seasonal/Contextual
                    _buildSection(
                      ref: ref,
                      context: context,
                      provider: seasonalPaginationProvider,
                      onLoadMore: () => ref.read(seasonalPaginationProvider.notifier).loadMore(),
                      onRetry: () => ref.read(seasonalPaginationProvider.notifier).refresh(),
                      title: ref.watch(seasonalTitleProvider),
                      heroTagPrefix: 'seasonal',
                    ),
                    // 🔥 Trending
                    _buildSection(
                      ref: ref,
                      context: context,
                      provider: trendingPaginationProvider('all_day'),
                      onLoadMore: () => ref.read(trendingPaginationProvider('all_day').notifier).loadMore(),
                      onRetry: () => ref.read(trendingPaginationProvider('all_day').notifier).refresh(),
                      title: AppLocalizations.of(context)!.sectionTrending,
                      skipFirst: true,
                      heroTagPrefix: 'trending',
                    ),
                    // 🆕 Bald Verfügbar (Coming Soon)
                    _buildUpcomingSection(ref, context),
                  ]),
                ),
              ),

              // 📚 Curated Collections
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: AppTheme.spacingXl),
                  child: CuratedCollectionsSection(
                    onMediaTap: (media, prefix) =>
                        _navigateToDetail(context, media, prefix),
                    onMediaLongPress: (media) =>
                        showLongPressMenu(context, ref, media),
                  ),
                ),
              ),

              // Bottom spacing
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required WidgetRef ref,
    required BuildContext context,
    required ProviderListenable<AsyncValue<PaginationState<Media>>> provider,
    required VoidCallback onLoadMore,
    required VoidCallback onRetry,
    required String title,
    bool skipFirst = false,
    String? heroTagPrefix,
  }) {
    final stateAsync = ref.watch(provider);
    final watchedIdsAsync = ref.watch(watchedMediaIdsProvider);
    final watchedIds = watchedIdsAsync.valueOrNull ?? <String>{};
    final hideWatched = ref.watch(hideWatchedProvider);

    return stateAsync.when(
      data: (state) => MediaSection(
        title: title,
        items: skipFirst ? state.items.skip(1).take(20).toList() : state.items,
        onMediaTap: (media, prefix) =>
            _navigateToDetail(context, media, prefix),
        onMediaLongPress: (media) => showLongPressMenu(context, ref, media),
        watchedIds: watchedIds,
        hideWatched: hideWatched,
        heroTagPrefix: heroTagPrefix,
        onLoadMore: onLoadMore,
        isLoadingMore: state.isLoadingMore,
      ),
      loading: () =>
          MediaSection(title: title, items: const [], isLoading: true),
      error: (error, stackTrace) => ErrorRetryWidget(
        compact: true,
        message: AppLocalizations.of(context)!.errorLoadingTitle(title),
        onRetry: onRetry,
      ),
    );
  }

  Widget _buildUpcomingSection(WidgetRef ref, BuildContext context) {
    final upcomingAsync = ref.watch(upcomingProvider);

    return upcomingAsync.when(
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMd,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.upcoming_rounded,
                      size: 18,
                      color: Color(0xFF00E676),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    AppLocalizations.of(context)!.sectionUpcoming,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            SizedBox(
              height: 260,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMd,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final media = items[index];
                  return UpcomingCard(
                    media: media,
                    onTap: () => _navigateToDetail(context, media, 'upcoming'),
                  );
                },
              ),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms);
      },
      loading: () => MediaSection(
        title: AppLocalizations.of(context)!.sectionUpcoming,
        items: const [],
        isLoading: true,
      ),
      error: (error, stackTrace) => ErrorRetryWidget(
        compact: true,
        message: AppLocalizations.of(context)!.errorLoadingUpcoming,
        onRetry: () => ref.invalidate(upcomingProvider),
      ),
    );
  }

  void _navigateToSearch(BuildContext context) {
    context.push("/search");
  }

  void _navigateToDetail(
    BuildContext context,
    Media media, [
    String? heroTagPrefix,
  ]) {
    AppHaptics.lightImpact();
    context.push(
      '/${media.type.name}/${media.id}',
      extra: {'heroTagPrefix': heroTagPrefix},
    );
  }
}
