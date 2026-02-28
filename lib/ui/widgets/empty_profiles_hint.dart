import 'package:flutter/material.dart';
import 'package:stream_scout/ui/theme/app_theme.dart';

/// Empty-state widget shown when no family profiles have been created yet.
class EmptyProfilesHint extends StatelessWidget {
  final VoidCallback onAdd;

  const EmptyProfilesHint({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAdd,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            style: BorderStyle.solid,
            color: AppTheme.surfaceBorder,
          ),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.person_add_alt_1_rounded,
              size: 48,
              color: AppTheme.textMuted,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              'Add a Family Profile',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Create separate profiles for family members.\nEach profile has its own independent watchlist.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.textMuted),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
