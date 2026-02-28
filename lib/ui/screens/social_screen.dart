import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/social_activity_feed_card.dart';
import '../widgets/social_empty_state.dart';
import '../widgets/social_user_tile.dart';

class SocialScreen extends ConsumerStatefulWidget {
  const SocialScreen({super.key});

  @override
  ConsumerState<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends ConsumerState<SocialScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.spacingMd,
                  AppTheme.spacingMd,
                  AppTheme.spacingMd,
                  0,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.people_rounded,
                      color: AppTheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Friends',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms),

              const SizedBox(height: AppTheme.spacingMd),

              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMd,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(color: AppTheme.surfaceBorder),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      ref.read(userSearchQueryProvider.notifier).state = value;
                    },
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search for friends...',
                      hintStyle: const TextStyle(color: AppTheme.textMuted),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppTheme.textMuted,
                      ),
                      suffixIcon: ref.watch(userSearchQueryProvider).isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: AppTheme.textMuted,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                ref
                                        .read(userSearchQueryProvider.notifier)
                                        .state =
                                    '';
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingMd,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 100.ms, duration: 300.ms),

              const SizedBox(height: AppTheme.spacingMd),

              // Tabs or Search results
              Expanded(
                child: Consumer(
                  builder: (context, ref, _) {
                    final query = ref.watch(userSearchQueryProvider);
                    if (query.isNotEmpty) {
                      return _SearchResults();
                    }
                    return _FriendsContent(tabController: _tabController);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FriendsContent extends ConsumerWidget {
  final TabController tabController;
  const _FriendsContent({required this.tabController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        TabBar(
          controller: tabController,
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textMuted,
          tabs: const [
            Tab(text: 'Activity'),
            Tab(text: 'Following'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: const [_ActivityFeedTab(), _FollowingTab()],
          ),
        ),
      ],
    );
  }
}

class _ActivityFeedTab extends ConsumerWidget {
  const _ActivityFeedTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(activityFeedProvider);

    return feedAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return SocialEmptyState(
            icon: Icons.dynamic_feed_rounded,
            title: 'No activity yet',
            subtitle: 'Follow friends to see what they\'re watching',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return SocialActivityFeedCard(item: items[index])
                .animate(delay: (index * 50).ms)
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.1, end: 0);
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      ),
      error: (_, __) => SocialEmptyState(
        icon: Icons.error_outline_rounded,
        title: 'Couldn\'t load feed',
        subtitle: 'Pull to refresh',
      ),
    );
  }
}

class _FollowingTab extends ConsumerWidget {
  const _FollowingTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followingAsync = ref.watch(followingListProvider);

    return followingAsync.when(
      data: (users) {
        if (users.isEmpty) {
          return SocialEmptyState(
            icon: Icons.person_add_rounded,
            title: 'Not following anyone yet',
            subtitle: 'Search above to find and follow friends',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          itemCount: users.length,
          itemBuilder: (context, index) {
            return SocialUserTile(
              profile: users[index],
              showUnfollowButton: true,
            ).animate(delay: (index * 50).ms).fadeIn(duration: 300.ms);
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      ),
      error: (_, __) => SocialEmptyState(
        icon: Icons.error_outline_rounded,
        title: 'Couldn\'t load following list',
        subtitle: 'Check your connection and try again',
      ),
    );
  }
}

class _SearchResults extends ConsumerWidget {
  const _SearchResults();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(userSearchResultsProvider);

    return resultsAsync.when(
      data: (users) {
        if (users.isEmpty) {
          return SocialEmptyState(
            icon: Icons.search_off_rounded,
            title: 'No users found',
            subtitle: 'Try a different name',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          itemCount: users.length,
          itemBuilder: (context, index) {
            return SocialUserTile(
              profile: users[index],
            ).animate(delay: (index * 50).ms).fadeIn(duration: 300.ms);
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      ),
      error: (_, __) => SocialEmptyState(
        icon: Icons.error_outline_rounded,
        title: 'Search failed',
        subtitle: 'Try again later',
      ),
    );
  }
}
