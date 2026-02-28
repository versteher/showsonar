import 'package:flutter/material.dart';
import 'package:stream_scout/ui/theme/app_theme.dart';

/// A single profile row showing avatar, name, active badge, and actions.
class ProfileTile extends StatelessWidget {
  final String emoji;
  final String name;
  final String subtitle;
  final bool isActive;
  final VoidCallback onSwitch;
  final VoidCallback? onDelete;

  const ProfileTile({
    super.key,
    required this.emoji,
    required this.name,
    required this.subtitle,
    required this.isActive,
    required this.onSwitch,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.primary.withValues(alpha: 0.12)
            : AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: isActive
              ? AppTheme.primary.withValues(alpha: 0.6)
              : AppTheme.surfaceBorder,
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: isActive ? AppTheme.primaryGradient : null,
              color: isActive ? null : AppTheme.surfaceBorder,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: AppTheme.spacingMd),

          // Name + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.normal,
                      ),
                    ),
                    if (isActive) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'ACTIVE',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  subtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppTheme.textMuted),
                ),
              ],
            ),
          ),

          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isActive)
                TextButton(onPressed: onSwitch, child: const Text('Switch')),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppTheme.error,
                    size: 20,
                  ),
                  tooltip: 'Delete profile',
                  onPressed: onDelete,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
