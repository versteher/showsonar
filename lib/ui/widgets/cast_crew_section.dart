import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../data/models/media.dart';
import '../../data/models/person.dart';
import '../theme/app_theme.dart';

class CastCrewSection extends StatelessWidget {
  final Media media;

  const CastCrewSection({super.key, required this.media});

  @override
  Widget build(BuildContext context) {
    if (media.cast.isEmpty && media.crew.isEmpty) {
      return const SizedBox.shrink();
    }

    final topCast = media.cast.take(15).toList();
    final topCrew = media.crew
        .where(
          (c) =>
              c.job == 'Director' ||
              c.job == 'Creator' ||
              c.department == 'Directing' ||
              c.department == 'Writing',
        )
        .take(10)
        .toList(); // Important crew

    // We can combine them into one list or show them together
    final List<dynamic> combined = [...topCast, ...topCrew];

    if (combined.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: AppTheme.spacingLg,
            bottom: AppTheme.spacingMd,
          ),
          child: Text(
            'Cast & Crew', // Should be localized if possible but let's stick to simple text
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        SizedBox(
          height: 140, // Height for avatar + names
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
            scrollDirection: Axis.horizontal,
            itemCount: combined.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: AppTheme.spacingMd),
            itemBuilder: (context, index) {
              final item = combined[index];
              int id;
              String name;
              String role;
              String profilePath;

              if (item is CastMember) {
                id = item.id;
                name = item.name;
                role = item.character;
                profilePath = item.fullProfilePath;
              } else if (item is CrewMember) {
                id = item.id;
                name = item.name;
                role = item.job;
                profilePath = item.fullProfilePath;
              } else {
                return const SizedBox.shrink();
              }

              return SizedBox(
                width: 90,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  onTap: () {
                    context.push('/person/$id');
                  },
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.surfaceLight,
                          border: Border.all(
                            color: AppTheme.primary.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: profilePath.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: profilePath,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: Icon(
                                    Icons.person,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Center(
                                      child: Icon(
                                        Icons.person,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                              )
                            : const Center(
                                child: Icon(
                                  Icons.person,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                      ),
                      const SizedBox(height: AppTheme.spacingSm),
                      // Name
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      // Role
                      Text(
                        role,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.textMuted,
                        ),
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ).animate().fadeIn(delay: Duration(milliseconds: 50 * index)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
