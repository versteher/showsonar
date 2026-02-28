import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_scout/config/providers.dart';
import 'package:stream_scout/ui/theme/app_theme.dart';

/// Card showing sign-in status and sign-in/sign-out action.
class SettingsAccountCard extends ConsumerWidget {
  const SettingsAccountCard({super.key, required this.authState});

  final AsyncValue authState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = authState.valueOrNull;
    final isLoggedIn = user != null;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isLoggedIn ? AppTheme.success : AppTheme.primary)
                  .withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Icon(
              isLoggedIn ? Icons.account_circle : Icons.login,
              color: isLoggedIn ? AppTheme.success : AppTheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLoggedIn ? 'Signed In' : 'Not Signed In',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  isLoggedIn
                      ? (user.email ?? 'Authenticated')
                      : 'Sign in to sync your data',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () async {
              if (isLoggedIn) {
                await ref.read(authServiceProvider).signOut();
              } else {
                context.push('/login');
              }
            },
            child: Text(isLoggedIn ? 'Sign Out' : 'Sign In'),
          ),
        ],
      ),
    );
  }
}
