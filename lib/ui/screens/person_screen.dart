import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../config/providers.dart';
import '../../data/models/person.dart';
import '../theme/app_theme.dart';
import '../widgets/media_card.dart';

class PersonScreen extends ConsumerWidget {
  final int personId;
  final String? heroTagPrefix;

  const PersonScreen({super.key, required this.personId, this.heroTagPrefix});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(personDetailsProvider(personId));
    final creditsAsync = ref.watch(personCreditsProvider(personId));

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: detailsAsync.when(
          data: (person) => _buildContent(context, person, creditsAsync),
          loading: () => _buildLoadingState(),
          error: (error, _) => _buildErrorState(context, error.toString()),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    Person person,
    AsyncValue<List<PersonCredit>> creditsAsync,
  ) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 400,
          pinned: true,
          backgroundColor: AppTheme.background,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: const Icon(Icons.arrow_back_ios_rounded, size: 18),
            ),
            onPressed: () => context.pop(),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                if (person.fullProfilePath.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: person.fullProfilePath,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  )
                else
                  Container(
                    color: AppTheme.surfaceLight,
                    child: const Icon(
                      Icons.person,
                      size: 100,
                      color: AppTheme.textMuted,
                    ),
                  ),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black54,
                        AppTheme.background,
                      ],
                      stops: [0.0, 0.6, 1.0],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 24,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        person.name,
                        style: Theme.of(context).textTheme.displaySmall,
                      ).animate().fadeIn().slideY(begin: 0.2, end: 0),
                      if (person.knownForDepartment.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          person.knownForDepartment,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: AppTheme.primaryLight),
                        ).animate().fadeIn(delay: 100.ms),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (person.birthday != null) ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.cake,
                        size: 16,
                        color: AppTheme.textMuted,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${person.birthday}${person.deathday != null ? ' - ${person.deathday}' : ''}',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                ],
                if (person.placeOfBirth != null) ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppTheme.textMuted,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(person.placeOfBirth!)),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingLg),
                ],
                if (person.biography != null &&
                    person.biography!.isNotEmpty) ...[
                  Text(
                    'Biography',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  Text(
                    person.biography!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXl),
                ],
                Text(
                  'Known For',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppTheme.spacingMd),
              ],
            ),
          ),
        ),
        creditsAsync.when(
          data: (credits) => _buildCreditsGrid(context, credits),
          loading: () => const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) =>
              SliverToBoxAdapter(child: Center(child: Text('Error: $error'))),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
      ],
    );
  }

  Widget _buildCreditsGrid(BuildContext context, List<PersonCredit> credits) {
    if (credits.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    // Sort credits by popularity or release date
    final sortedCredits = List<PersonCredit>.from(credits)
      ..sort(
        (a, b) => (b.media.popularity ?? 0).compareTo(a.media.popularity ?? 0),
      );

    // Remove duplicates
    final uniqueCredits = <int, PersonCredit>{};
    for (final credit in sortedCredits) {
      if (!uniqueCredits.containsKey(credit.media.id)) {
        uniqueCredits[credit.media.id] = credit;
      }
    }
    final displayCredits = uniqueCredits.values.toList();

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 150,
          mainAxisSpacing: AppTheme.spacingMd,
          crossAxisSpacing: AppTheme.spacingMd,
          childAspectRatio: 0.65,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final credit = displayCredits[index];
          return MediaCard(
            media: credit.media,
            onTap: () {
              context.push('/${credit.media.type.name}/${credit.media.id}');
            },
          ).animate().fadeIn(delay: Duration(milliseconds: 20 * (index % 10)));
        }, childCount: displayCredits.length),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
          const SizedBox(height: AppTheme.spacingMd),
          Text(
            'Error loading person',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppTheme.spacingSm),
          OutlinedButton(
            onPressed: () => context.pop(),
            child: const Text('Back'),
          ),
        ],
      ),
    );
  }
}
