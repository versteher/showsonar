import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/providers.dart';
import '../../data/models/user_profile.dart';
import '../../utils/app_haptics.dart';
import '../theme/app_theme.dart';

class SocialUserTile extends ConsumerWidget {
  final UserProfile profile;
  final bool showUnfollowButton;

  const SocialUserTile({
    super.key,
    required this.profile,
    this.showUnfollowButton = false,
  });

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
                          SocialInitials(profile.displayName),
                    ),
                  )
                : SocialInitials(profile.displayName),
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
            data: (isFollowing) => SocialFollowButton(
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

class SocialFollowButton extends StatelessWidget {
  final bool isFollowing;
  final VoidCallback onTap;

  const SocialFollowButton({
    super.key,
    required this.isFollowing,
    required this.onTap,
  });

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

class SocialInitials extends StatelessWidget {
  final String name;
  const SocialInitials(this.name, {super.key});

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
