import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/providers.dart';

import '../../utils/age_rating_mapper.dart';
import '../theme/app_theme.dart';
import 'streaming_filter_bar.dart';

/// Modal bottom sheet for filter settings (Age Rating, Minimum Rating)
class FilterSettingsSheet extends ConsumerWidget {
  const FilterSettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(userPreferencesProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppTheme.textMuted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title
              Row(
                children: [
                  const Icon(Icons.tune_rounded, color: AppTheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Inhaltsfilter',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Spacer(),
                  // Close button
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingLg),

              prefsAsync.when(
                data: (prefs) => Column(
                  children: [
                    // Streaming Filters Section
                    _buildSectionTitle(context, 'Streaming-Dienste'),
                    const SizedBox(height: AppTheme.spacingSm),
                    const StreamingFilterBar(),
                    const SizedBox(height: AppTheme.spacingXl),

                    // Age Rating Section
                    _buildSectionTitle(context, 'Altersfreigabe / Age Limit'),
                    const SizedBox(height: AppTheme.spacingMd),
                    _AgeRatingSlider(
                      maxAgeRating: prefs.maxAgeRating,
                      countryCode: prefs.countryCode,
                    ),

                    const SizedBox(height: AppTheme.spacingXl),

                    // Minimum Rating Section
                    _buildSectionTitle(context, 'Minimale Bewertung'),
                    const SizedBox(height: AppTheme.spacingMd),
                    _RatingSlider(currentRating: prefs.minimumRating),
                  ],
                ),
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppTheme.primary),
                ),
                error: (error, _) => Center(
                  child: Text(
                    'Fehler: $error',
                    style: const TextStyle(color: AppTheme.error),
                  ),
                ),
              ),

              const SizedBox(height: AppTheme.spacingXl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

/// Rating slider with functional updates
class _RatingSlider extends ConsumerStatefulWidget {
  final double currentRating;

  const _RatingSlider({required this.currentRating});

  @override
  ConsumerState<_RatingSlider> createState() => _RatingSliderState();
}

class _RatingSliderState extends ConsumerState<_RatingSlider> {
  late double _localRating;

  @override
  void initState() {
    super.initState();
    _localRating = widget.currentRating;
  }

  @override
  void didUpdateWidget(_RatingSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentRating != widget.currentRating) {
      _localRating = widget.currentRating;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.background, // Slightly different/darker bg
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Zeige nur Inhalte mit Rating ≥',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingSm,
                  vertical: AppTheme.spacingXs,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.getRatingColor(
                    _localRating,
                  ).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  border: Border.all(
                    color: AppTheme.getRatingColor(
                      _localRating,
                    ).withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: AppTheme.getRatingColor(_localRating),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _localRating.toStringAsFixed(1),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.getRatingColor(_localRating),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppTheme.getRatingColor(_localRating),
              inactiveTrackColor: AppTheme.surfaceLight,
              thumbColor: AppTheme.getRatingColor(_localRating),
              overlayColor: AppTheme.getRatingColor(
                _localRating,
              ).withValues(alpha: 0.2),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: _localRating,
              min: 0,
              max: 10,
              divisions: 20,
              onChanged: (value) {
                setState(() => _localRating = value);
              },
              onChangeEnd: (value) async {
                final repo = ref.read(userPreferencesRepositoryProvider);
                await repo.init();
                await repo.updateMinimumRating(value);
                ref.invalidate(userPreferencesProvider);

                // Invalidate content providers to refresh lists
                ref.invalidate(trendingProvider);
                ref.invalidate(popularMoviesProvider);
                ref.invalidate(popularTvSeriesProvider);
                ref.invalidate(topRatedMoviesProvider);
                ref.invalidate(upcomingProvider);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0', style: Theme.of(context).textTheme.bodySmall),
                Text('5', style: Theme.of(context).textTheme.bodySmall),
                Text('10', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Age Rating (FSK) slider
class _AgeRatingSlider extends ConsumerStatefulWidget {
  final int? maxAgeRating;
  final String countryCode;

  const _AgeRatingSlider({
    required this.maxAgeRating,
    required this.countryCode,
  });

  @override
  ConsumerState<_AgeRatingSlider> createState() => _AgeRatingSliderState();
}

class _AgeRatingSliderState extends ConsumerState<_AgeRatingSlider> {
  late double _localValue;
  // Map index to FSK values: 0 -> 0, 1 -> 6, 2 -> 12, 3 -> 16, 4 -> 18, 5 -> 21 (Adult), 6 -> No Limit
  final List<int> _fskLevels = [0, 6, 12, 16, 18, 21];

  @override
  void initState() {
    super.initState();
    _localValue = _ageToSliderValue(widget.maxAgeRating);
  }

  @override
  void didUpdateWidget(_AgeRatingSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.maxAgeRating != widget.maxAgeRating) {
      _localValue = _ageToSliderValue(widget.maxAgeRating);
    }
  }

  double _ageToSliderValue(int? age) {
    if (age == null || age > 21) return 6.0; // No limit
    if (age >= 21) return 5.0;
    if (age >= 18) return 4.0;
    if (age >= 16) return 3.0;
    if (age >= 12) return 2.0;
    if (age >= 6) return 1.0;
    return 0.0;
  }

  int? _sliderValueToAge(double value) {
    if (value >= 6) return null; // No limit
    return _fskLevels[value.round()];
  }

  String _getLabel(double value) {
    if (value >= 6) return 'Kein Limit';

    final age = _fskLevels[value.round()];
    if (age >= 21) return 'Adult (21+)';

    final cert = AgeRatingMapper.getCertification(widget.countryCode, age);

    if (cert == null) return 'Bis $age Jahre';

    // For DE, explicitly add "FSK" for clarity if cert is numeric
    if (widget.countryCode == 'DE' && int.tryParse(cert) != null) {
      return 'Bis FSK $cert';
    }

    return 'Bis $cert';
  }

  Color _getColor(double value) {
    if (value >= 6) return AppTheme.textMuted;
    final age = _fskLevels[value.round()];
    switch (age) {
      case 0:
        return Colors.white;
      case 6:
        return Colors.yellow;
      case 12:
        return Colors.green;
      case 16:
        return Colors.blue;
      case 18:
        return Colors.red;
      case 21:
        return Colors.purple;
      default:
        return AppTheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.background, // Slightly different/darker bg
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Maximales Alter / Rating',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingSm,
                  vertical: AppTheme.spacingXs,
                ),
                decoration: BoxDecoration(
                  color: _getColor(_localValue).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  border: Border.all(
                    color: _getColor(_localValue).withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  _getLabel(_localValue),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getColor(_localValue),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: _getColor(_localValue),
              inactiveTrackColor: AppTheme.surfaceLight,
              thumbColor: _getColor(_localValue),
              overlayColor: _getColor(_localValue).withValues(alpha: 0.2),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: _localValue,
              min: 0,
              max: 6,
              divisions: 6,
              onChanged: (value) {
                setState(() => _localValue = value);
              },
              onChangeEnd: (value) async {
                final repo = ref.read(userPreferencesRepositoryProvider);
                await repo.init();
                final age = _sliderValueToAge(value);
                await repo.updateMaxAgeRating(age);
                ref.invalidate(userPreferencesProvider);

                // Invalidate content providers to refresh lists
                ref.invalidate(trendingProvider);
                ref.invalidate(popularMoviesProvider);
                ref.invalidate(popularTvSeriesProvider);
                ref.invalidate(topRatedMoviesProvider);
                ref.invalidate(upcomingProvider);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0', style: Theme.of(context).textTheme.bodySmall),
                Text('6', style: Theme.of(context).textTheme.bodySmall),
                Text('12', style: Theme.of(context).textTheme.bodySmall),
                Text('16', style: Theme.of(context).textTheme.bodySmall),
                Text('18', style: Theme.of(context).textTheme.bodySmall),
                Text('21+', style: Theme.of(context).textTheme.bodySmall),
                Text('Alle', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
