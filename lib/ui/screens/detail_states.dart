import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/media.dart';
import '../theme/app_theme.dart';

class DetailLoadingState extends StatelessWidget {
  const DetailLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 300,
          backgroundColor: AppTheme.background,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(color: AppTheme.surface),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 28,
                  width: 200,
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 16,
                  width: 150,
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 24),
                ...List.generate(
                  4,
                  (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class DetailErrorState extends StatelessWidget {
  const DetailErrorState({
    super.key,
    required this.mediaId,
    required this.mediaType,
  });

  final int mediaId;
  final MediaType mediaType;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppTheme.error,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Text(
            'Fehler beim Laden',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            'Details konnten nicht geladen werden',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textMuted),
          ),
          const SizedBox(height: AppTheme.spacingLg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('Zurück'),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => context.replace('/$mediaType/$mediaId'),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Erneut versuchen'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
