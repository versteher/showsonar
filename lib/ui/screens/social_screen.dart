import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/providers.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/activity_feed_item.dart';
import '../theme/app_theme.dart';
import '../../utils/app_haptics.dart';

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
          return _EmptySocialState(
            icon: Icons.dynamic_feed_rounded,
            title: 'No activity yet',
            subtitle: 'Follow friends to see what they\'re watching',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return _ActivityFeedCard(item: items[index])
                .animate(delay: (index * 50).ms)
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.1, end: 0);
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      ),
      error: (_, __) => _EmptySocialState(
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
          return _EmptySocialState(
            icon: Icons.person_add_rounded,
            title: 'Not following anyone yet',
            subtitle: 'Search above to find and follow friends',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          itemCount: users.length,
          itemBuilder: (context, index) {
            return _UserTile(
              profile: users[index],
              showUnfollowButton: true,
            ).animate(delay: (index * 50).ms).fadeIn(duration: 300.ms);
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      ),
      error: (_, __) => _EmptySocialState(
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
          return _EmptySocialState(
            icon: Icons.search_off_rounded,
            title: 'No users found',
            subtitle: 'Try a different name',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          itemCount: users.length,
          itemBuilder: (context, index) {
            return _UserTile(
              profile: users[index],
            ).animate(delay: (index * 50).ms).fadeIn(duration: 300.ms);
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      ),
      error: (_, __) => _EmptySocialState(
        icon: Icons.error_outline_rounded,
        title: 'Search failed',
        subtitle: 'Try again later',
      ),
    );
  }
}

class _UserTile extends ConsumerWidget {
  final UserProfile profile;
  final bool showUnfollowButton;

  const _UserTile({required this.profile, this.showUnfollowButton = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFollowingAsync = ref.watch(isFollowingProvider(profile.uid));
    final repo = ref.read(socialRepositoryProvider);

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.primaryGradient,
            ),
            child: profile.photoUrl != null
                ? ClipOval(
                    child: Image.network(
                      profile.photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _Initials(profile.displayName),
                    ),
                  )
                : _Initials(profile.displayName),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.displayName,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${profile.followersCount} followers · ${profile.followingCount} following',
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.spacingSm),
          isFollowingAsync.when(
            data: (isFollowing) => _FollowButton(
              isFollowing: isFollowing,
              onTap: () async {
                AppHaptics.mediumImpact();
                if (isFollowing) {
                  await repo.unfollowUser(profile.uid);
                  ref.invalidate(followingListProvider);
                } else {
                  await repo.followUser(profile.uid);
                  ref.invalidate(followingListProvider);
                }
              },
            ),
            loading: () => const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.primary,
              ),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _FollowButton extends StatelessWidget {
  final bool isFollowing;
  final VoidCallback onTap;

  const _FollowButton({required this.isFollowing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isFollowing ? Colors.transparent : AppTheme.primary,
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          border: Border.all(
            color: isFollowing ? AppTheme.surfaceBorder : AppTheme.primary,
          ),
        ),
        child: Text(
          isFollowing ? 'Following' : 'Follow',
          style: TextStyle(
            color: isFollowing ? AppTheme.textMuted : Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _ActivityFeedCard extends StatelessWidget {
  final ActivityFeedItem item;

  const _ActivityFeedCard({required this.item});

  String _actionText() {
    switch (item.actionType) {
      case 'rated':
        return 'rated ${item.mediaTitle} ${item.rating?.toStringAsFixed(1)}★';
      case 'watched':
        return 'watched ${item.mediaTitle}';
      case 'added_to_watchlist':
        return 'added ${item.mediaTitle} to watchlist';
      default:
        return 'interacted with ${item.mediaTitle}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeAgo = _formatTimeAgo(item.timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.primaryGradient,
            ),
            child: item.userPhotoUrl != null
                ? ClipOval(
                    child: Image.network(
                      item.userPhotoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _Initials(item.userDisplayName),
                    ),
                  )
                : _Initials(item.userDisplayName),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: item.userDisplayName,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const TextSpan(text: ' '),
                      TextSpan(
                        text: _actionText(),
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeAgo,
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (item.mediaPosterPath != null)
            Padding(
              padding: const EdgeInsets.only(left: AppTheme.spacingSm),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                child: Image.network(
                  'https://image.tmdb.org/t/p/w92${item.mediaPosterPath}',
                  width: 44,
                  height: 66,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 44,
                    height: 66,
                    color: AppTheme.surfaceLight,
                    child: const Icon(Icons.movie, color: AppTheme.textMuted),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${diff.inDays ~/ 7}w ago';
  }
}

class _Initials extends StatelessWidget {
  final String name;
  const _Initials(this.name);

  @override
  Widget build(BuildContext context) {
    final initials = name.isNotEmpty
        ? name.trim().split(' ').map((w) => w[0].toUpperCase()).take(2).join()
        : '?';
    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    );
  }
}

class _EmptySocialState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptySocialState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppTheme.textMuted,
            ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              subtitle,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
