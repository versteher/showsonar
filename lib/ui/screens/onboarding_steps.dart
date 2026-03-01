// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_scout/config/providers.dart';
import 'package:stream_scout/data/models/streaming_provider.dart';
import 'package:stream_scout/data/constants/countries.dart';

class OnboardingStepHeader extends StatelessWidget {
  const OnboardingStepHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class OnboardingLocationStep extends StatelessWidget {
  const OnboardingLocationStep({
    super.key,
    required this.selectedCountryCode,
    required this.selectedCountryName,
    required this.onCountrySelected,
  });

  final String selectedCountryCode;
  final String selectedCountryName;
  final void Function(String code, String name) onCountrySelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const OnboardingStepHeader(
            title: 'Welcome to ShowSonar',
            subtitle:
                'Let\'s personalize your experience. Where are you watching from?',
          ),
          Card(
            child: ListTile(
              title: const Text('Country / Region'),
              subtitle: Text(selectedCountryName),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                final selected =
                    await showModalBottomSheet<Map<String, String>>(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (context) => _CountryPickerSheet(
                        selectedCountryCode: selectedCountryCode,
                      ),
                    );
                if (selected != null) {
                  onCountrySelected(selected['code']!, selected['name']!);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Combined step 1: country selection + streaming services on a single scrollable page.
class OnboardingLocationAndStreamingStep extends StatelessWidget {
  const OnboardingLocationAndStreamingStep({
    super.key,
    required this.selectedCountryCode,
    required this.selectedCountryName,
    required this.onCountrySelected,
    required this.selectedProviders,
    required this.onToggleProvider,
  });

  final String selectedCountryCode;
  final String selectedCountryName;
  final void Function(String code, String name) onCountrySelected;
  final List<String> selectedProviders;
  final void Function(String id, bool selected) onToggleProvider;

  @override
  Widget build(BuildContext context) {
    final availableProviders = StreamingProvider.getProvidersForCountry(
      selectedCountryCode,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const OnboardingStepHeader(
            title: 'Welcome to ShowSonar',
            subtitle:
                'Where are you watching from? Pick your streaming services.',
          ),
          // Country selector
          Card(
            child: ListTile(
              title: const Text('Country / Region'),
              subtitle: Text(selectedCountryName),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                final selected =
                    await showModalBottomSheet<Map<String, String>>(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (context) => _CountryPickerSheet(
                        selectedCountryCode: selectedCountryCode,
                      ),
                    );
                if (selected != null) {
                  onCountrySelected(selected['code']!, selected['name']!);
                }
              },
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Your Services',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Select the streaming services you use.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: availableProviders.length,
            itemBuilder: (context, index) {
              final provider = availableProviders[index];
              final isSelected = selectedProviders.contains(provider.id);

              return GestureDetector(
                onTap: () => onToggleProvider(provider.id, !isSelected),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          provider.logoPath,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 64,
                              height: 64,
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              alignment: Alignment.center,
                              child: Text(
                                provider.name.isNotEmpty
                                    ? provider.name
                                          .substring(0, 1)
                                          .toUpperCase()
                                    : '?',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.name,
                      style: Theme.of(context).textTheme.labelSmall,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// Step 3: completion screen shown after the user finishes setup.
class OnboardingDoneStep extends StatelessWidget {
  const OnboardingDoneStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Icon(
              Icons.check_rounded,
              size: 56,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            "You're All Set!",
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Start discovering your next favourite\nmovie or series.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _CountryPickerSheet extends StatelessWidget {
  const _CountryPickerSheet({required this.selectedCountryCode});

  final String selectedCountryCode;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Select Country',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: netflixCountries.length,
              itemBuilder: (context, index) {
                final country = netflixCountries[index];
                final isSelected = country['code'] == selectedCountryCode;

                return ListTile(
                  leading: Text(
                    country['flag']!,
                    style: const TextStyle(fontSize: 28),
                  ),
                  title: Text(
                    country['name']!,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () {
                    context.pop(country);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class OnboardingStreamingStep extends StatelessWidget {
  const OnboardingStreamingStep({
    super.key,
    required this.selectedCountryCode,
    required this.selectedProviders,
    required this.onToggleProvider,
  });

  final String selectedCountryCode;
  final List<String> selectedProviders;
  final void Function(String id, bool selected) onToggleProvider;

  @override
  Widget build(BuildContext context) {
    final availableProviders = StreamingProvider.getProvidersForCountry(
      selectedCountryCode,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const OnboardingStepHeader(
            title: 'Your Services',
            subtitle:
                'Select the streaming services you use to see where to watch.',
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: availableProviders.length,
              itemBuilder: (context, index) {
                final provider = availableProviders[index];
                final isSelected = selectedProviders.contains(provider.id);

                return GestureDetector(
                  onTap: () => onToggleProvider(provider.id, !isSelected),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            provider.logoPath,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 64,
                                height: 64,
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                alignment: Alignment.center,
                                child: Text(
                                  provider.name.isNotEmpty
                                      ? provider.name
                                            .substring(0, 1)
                                            .toUpperCase()
                                      : '?',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        provider.name,
                        style: Theme.of(context).textTheme.labelSmall,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingGenresStep extends StatelessWidget {
  const OnboardingGenresStep({
    super.key,
    required this.selectedGenres,
    required this.onToggleGenre,
  });

  final List<int> selectedGenres;
  final void Function(int id, bool selected) onToggleGenre;

  static const List<Map<String, Object>> _genres = [
    {'id': 28, 'name': 'Action'},
    {'id': 12, 'name': 'Adventure'},
    {'id': 16, 'name': 'Animation'},
    {'id': 35, 'name': 'Comedy'},
    {'id': 80, 'name': 'Crime'},
    {'id': 99, 'name': 'Documentary'},
    {'id': 18, 'name': 'Drama'},
    {'id': 10751, 'name': 'Family'},
    {'id': 14, 'name': 'Fantasy'},
    {'id': 36, 'name': 'History'},
    {'id': 27, 'name': 'Horror'},
    {'id': 10402, 'name': 'Music'},
    {'id': 9648, 'name': 'Mystery'},
    {'id': 10749, 'name': 'Romance'},
    {'id': 878, 'name': 'Sci-Fi'},
    {'id': 53, 'name': 'Thriller'},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const OnboardingStepHeader(
            title: 'Favorite Genres',
            subtitle: 'Pick a few genres you love to help us recommend better.',
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _genres.map((genre) {
                  final isSelected = selectedGenres.contains(genre['id']);
                  return FilterChip(
                    label: Text(genre['name'] as String),
                    selected: isSelected,
                    onSelected: (selected) =>
                        onToggleGenre(genre['id'] as int, selected),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingThemeStep extends ConsumerWidget {
  const OnboardingThemeStep({
    super.key,
    required this.selectedTheme,
    required this.onThemeChanged,
  });

  final ThemeMode selectedTheme;
  final void Function(ThemeMode mode) onThemeChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const OnboardingStepHeader(
            title: 'Choose a Theme',
            subtitle: 'Select how you want ShowSonar to look.',
          ),
          RadioListTile<ThemeMode>(
            title: const Text('System Default'),
            value: ThemeMode.system,
            groupValue: selectedTheme,
            onChanged: (val) {
              onThemeChanged(val!);
              ref.read(themeModeProvider.notifier).state = val;
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Dark Mode'),
            value: ThemeMode.dark,
            groupValue: selectedTheme,
            onChanged: (val) {
              onThemeChanged(val!);
              ref.read(themeModeProvider.notifier).state = val;
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Light Mode'),
            value: ThemeMode.light,
            groupValue: selectedTheme,
            onChanged: (val) {
              onThemeChanged(val!);
              ref.read(themeModeProvider.notifier).state = val;
            },
          ),
        ],
      ),
    );
  }
}
