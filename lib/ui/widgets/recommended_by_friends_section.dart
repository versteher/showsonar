import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:stream_scout/data/models/direct_recommendation.dart';
import 'package:stream_scout/data/models/media.dart';
import 'package:stream_scout/data/repositories/recommendation_repository.dart';
import 'package:stream_scout/ui/theme/app_theme.dart';
import 'package:stream_scout/ui/widgets/media_card.dart';

class RecommendedByFriendsSection extends ConsumerWidget {
  final Function(Media, String) onMediaTap;

  const RecommendedByFriendsSection({super.key, required this.onMediaTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendationsAsync = ref.watch(incomingRecommendationsProvider);

    return recommendationsAsync.when(
      data: (recommendations) {
        if (recommendations.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMd,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.mark_email_unread_rounded,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                  Text(
                    'Recommended by Friends',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMd,
                ),
                itemCount: recommendations.length,
                itemBuilder: (context, index) {
                  final rec = recommendations[index];
                  // Construct a dummy Media object just for the card UI
                  final media = Media(
                    id: rec.mediaId,
                    type: rec.mediaType == 'tv'
                        ? MediaType.tv
                        : MediaType.movie,
                    title: rec.mediaTitle,
                    posterPath: rec.mediaPosterPath,
                    overview: '',
                    voteAverage: 0.0,
                    voteCount: 0,
                    genreIds: [],
                  );

                  return Padding(
                        padding: const EdgeInsets.only(
                          right: AppTheme.spacingMd,
                        ),
                        child: Stack(
                          children: [
                            MediaCard(
                              media: media,
                              heroTagPrefix: 'friend_rec',
                              onTap: () => onMediaTap(media, 'friend_rec'),
                            ),
                            if (rec.senderProfile != null)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppTheme.surface,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.5,
                                        ),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 14,
                                    backgroundColor: AppTheme.primary
                                        .withValues(alpha: 0.2),
                                    backgroundImage:
                                        rec.senderProfile!.photoUrl != null
                                        ? NetworkImage(
                                            rec.senderProfile!.photoUrl!,
                                          )
                                        : null,
                                    child: rec.senderProfile!.photoUrl == null
                                        ? Text(
                                            rec.senderProfile!.displayName
                                                .substring(0, 1)
                                                .toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 10,
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      )
                      .animate(delay: (index * 100).ms)
                      .fadeIn(duration: 400.ms)
                      .slideX(begin: 0.2, end: 0);
                },
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),
          ],
        );
      },
      loading: () =>
          const SizedBox.shrink(), // Better to hide while loading on home screen
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
