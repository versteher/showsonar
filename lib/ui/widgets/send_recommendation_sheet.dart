import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_scout/config/providers/social_providers.dart';
import 'package:stream_scout/data/models/media.dart';
import 'package:stream_scout/data/repositories/recommendation_repository.dart';
import 'package:stream_scout/ui/theme/app_theme.dart';
import 'package:stream_scout/ui/widgets/app_snack_bar.dart';

class SendRecommendationSheet extends ConsumerWidget {
  final Media media;

  const SendRecommendationSheet({super.key, required this.media});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followingAsync = ref.watch(followingListProvider);

    return Container(
      padding: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.surfaceBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            Text(
              'Send to a Friend',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              'Recommend ${media.title}',
              style: const TextStyle(color: AppTheme.textMuted),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            Expanded(
              child: followingAsync.when(
                data: (users) {
                  if (users.isEmpty) {
                    return const Center(
                      child: Text(
                        'Follow friends on the Social tab to send recommendations.',
                        style: TextStyle(color: AppTheme.textMuted),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primary.withValues(
                            alpha: 0.2,
                          ),
                          backgroundImage: user.photoUrl != null
                              ? NetworkImage(user.photoUrl!)
                              : null,
                          child: user.photoUrl == null
                              ? Text(
                                  user.displayName
                                      .substring(0, 1)
                                      .toUpperCase(),
                                )
                              : null,
                        ),
                        title: Text(
                          user.displayName,
                          style: const TextStyle(color: AppTheme.textPrimary),
                        ),
                        trailing: OutlinedButton(
                          onPressed: () async {
                            final repo = ref.read(
                              recommendationRepositoryProvider,
                            );
                            await repo.sendRecommendation(user.uid, media);
                            if (context.mounted) {
                              Navigator.of(context).pop();
                              AppSnackBar.showSuccess(
                                context,
                                'Sent recommendation to ${user.displayName}!',
                              );
                            }
                          },
                          child: const Text('Send'),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
