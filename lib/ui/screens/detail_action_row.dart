import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_scout/l10n/app_localizations.dart';

import '../../config/providers.dart';
import '../../data/models/media.dart';
import '../../data/models/watch_history_entry.dart';
import '../theme/app_theme.dart';
import '../widgets/app_snack_bar.dart';
import '../widgets/watchlist_button.dart';

class DetailActionRow extends ConsumerWidget {
  const DetailActionRow({
    super.key,
    required this.media,
    required this.watchEntry,
    required this.onShowRating,
    required this.onConfirmRemove,
  });

  final Media media;
  final WatchHistoryEntry? watchEntry;
  final VoidCallback onShowRating;
  final VoidCallback onConfirmRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWatched = watchEntry != null;
    final isOnWatchlist =
        ref
            .watch(isOnWatchlistProvider((id: media.id, type: media.type)))
            .valueOrNull ??
        false;

    return Column(
      children: [
        Row(
          children: [
            WatchlistButton(
              isOnWatchlist: isOnWatchlist,
              mediaTitle: media.title,
              onToggle: () async {
                final repo = ref.read(watchlistRepositoryProvider);
                await repo.init();
                if (isOnWatchlist) {
                  await repo.removeFromWatchlist(media.id, media.type);
                } else {
                  await repo.addMedia(media);
                }
                ref.invalidate(
                  isOnWatchlistProvider((id: media.id, type: media.type)),
                );
                ref.invalidate(watchlistEntriesProvider);
                if (context.mounted) {
                  AppSnackBar.showAccent(
                    context,
                    isOnWatchlist
                        ? AppLocalizations.of(
                            context,
                          )!.detailWatchlistRemoved(media.title)
                        : AppLocalizations.of(
                            context,
                          )!.detailWatchlistAdded(media.title),
                    icon: isOnWatchlist
                        ? Icons.bookmark_remove_rounded
                        : Icons.bookmark_added_rounded,
                  );
                }
              },
            ),

            const SizedBox(width: AppTheme.spacingSm),

            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: onShowRating,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isWatched ? AppTheme.success : AppTheme.primary,
                ),
                icon: Icon(
                  isWatched
                      ? Icons.edit_rounded
                      : Icons.check_circle_outline_rounded,
                ),
                label: Text(
                  isWatched
                      ? AppLocalizations.of(context)!.detailChangeRating
                      : AppLocalizations.of(context)!.detailMarkWatched,
                ),
              ),
            ),

            if (isWatched) ...[
              const SizedBox(width: AppTheme.spacingSm),
              Semantics(
                button: true,
                label: AppLocalizations.of(
                  context,
                )!.semanticDeleteFromHistory(media.title),
                child: OutlinedButton(
                  onPressed: onConfirmRemove,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.error,
                    side: const BorderSide(color: AppTheme.error),
                  ),
                  child: const Icon(Icons.delete_outline_rounded),
                ),
              ),
            ],
          ],
        ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

        if (media.type == MediaType.tv && (media.numberOfSeasons ?? 0) > 0)
          _TrackEpisodesButton(media: media),
      ],
    );
  }
}

class _TrackEpisodesButton extends StatelessWidget {
  const _TrackEpisodesButton({required this.media});
  final Media media;

  @override
  Widget build(BuildContext context) {
    final seasons = media.numberOfSeasons!;
    return Padding(
      padding: const EdgeInsets.only(top: AppTheme.spacingSm),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {
            HapticFeedback.lightImpact();
            context.push(
              '/tv/${media.id}/episodes',
              extra: {
                'seriesTitle': media.title,
                'numberOfSeasons': seasons,
                'posterPath': media.posterPath,
              },
            );
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.accent,
            side: BorderSide(color: AppTheme.accent.withValues(alpha: 0.6)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          icon: const Icon(Icons.format_list_numbered_rounded),
          label: Text(
            'Track Episodes  •  $seasons season${seasons == 1 ? '' : 's'}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 250.ms, duration: 400.ms);
  }
}
