import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_scout/l10n/app_localizations.dart';
import '../../config/providers.dart';
import '../../data/models/media.dart';
import '../../data/models/watch_history_entry.dart';

import '../theme/app_theme.dart';

/// Section showing in-progress TV series for easy resume
class ContinueWatchingSection extends ConsumerWidget {
  const ContinueWatchingSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final continueAsync = ref.watch(continueWatchingProvider);

    return continueAsync.when(
      data: (entries) {
        if (entries.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMd,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00B0FF).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      size: 18,
                      color: Color(0xFF00B0FF),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    AppLocalizations.of(context)!.continueWatchingTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingSm),

            // Horizontal list
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMd,
                ),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  return _ContinueCard(entry: entries[index]);
                },
              ),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms);
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  final WatchHistoryEntry entry;

  const _ContinueCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final typePath = entry.mediaType == MediaType.movie ? 'movie' : 'tv';
        context.push('/$typePath/${entry.mediaId}');
      },
      child: Container(
        width: 240,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: const Color(0xFF00B0FF).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            // Poster
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(AppTheme.radiusMedium),
              ),
              child: entry.posterPath != null
                  ? CachedNetworkImage(
                      imageUrl:
                          'https://image.tmdb.org/t/p/w200${entry.posterPath}',
                      width: 85,
                      height: 140,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 85,
                      height: 140,
                      color: AppTheme.surfaceLight,
                      child: const Icon(
                        Icons.tv_rounded,
                        color: AppTheme.textMuted,
                      ),
                    ),
            ),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      entry.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (entry.currentSeason != null ||
                        entry.currentEpisode != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF00B0FF,
                          ).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _progressText(context),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF00B0FF),
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      entry.watchedAgo,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00B0FF), Color(0xFF2979FF)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF00B0FF,
                              ).withValues(alpha: 0.3),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _progressText(BuildContext context) {
    if (entry.currentSeason != null && entry.currentEpisode != null) {
      return AppLocalizations.of(
        context,
      )!.continueSeasonEpisode(entry.currentSeason!, entry.currentEpisode!);
    } else if (entry.currentSeason != null) {
      return AppLocalizations.of(context)!.continueSeason(entry.currentSeason!);
    } else if (entry.currentEpisode != null) {
      return AppLocalizations.of(
        context,
      )!.continueEpisode(entry.currentEpisode!);
    }
    return AppLocalizations.of(context)!.continueInProgress;
  }
}
