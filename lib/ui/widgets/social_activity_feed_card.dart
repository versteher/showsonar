import 'package:flutter/material.dart';
import '../../data/models/activity_feed_item.dart';
import '../theme/app_theme.dart';
import 'social_user_tile.dart';

class SocialActivityFeedCard extends StatelessWidget {
  final ActivityFeedItem item;

  const SocialActivityFeedCard({super.key, required this.item});

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

  String _formatTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${diff.inDays ~/ 7}w ago';
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
                      errorBuilder: (_, _, _) =>
                          SocialInitials(item.userDisplayName),
                    ),
                  )
                : SocialInitials(item.userDisplayName),
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
                  errorBuilder: (_, _, _) => Container(
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
}
