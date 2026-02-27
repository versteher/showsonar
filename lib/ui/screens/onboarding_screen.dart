import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neon_voyager/config/providers.dart';
import 'package:neon_voyager/data/models/streaming_provider.dart';
import 'package:neon_voyager/data/constants/countries.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> _selectedProviders = [];
  final List<int> _selectedGenres = [];
  String _selectedCountryCode = 'DE';
  String _selectedCountryName = 'Deutschland';
  ThemeMode _selectedTheme = ThemeMode.dark;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finishOnboarding() async {
    final userPrefsRepo = ref.read(userPreferencesRepositoryProvider);
    final localPrefsRepo = ref.read(localPreferencesRepositoryProvider);

    // Save preferences
    var prefs = await userPrefsRepo.getPreferences();
    prefs = prefs.copyWith(
      countryCode: _selectedCountryCode,
      countryName: _selectedCountryName,
      subscribedServiceIds: _selectedProviders,
      favoriteGenreIds: _selectedGenres,
    );
    await userPrefsRepo.savePreferences(prefs);

    await localPrefsRepo.setThemeMode(_selectedTheme);
    await localPrefsRepo.setHasSeenOnboarding(true);

    ref.read(themeModeProvider.notifier).state = _selectedTheme;

    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildLocationPage(),
                  _buildStreamingProvidersPage(),
                  _buildGenresPage(),
                  _buildThemePage(),
                  _buildTasteProfilePage(),
                ],
              ),
            ),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            TextButton(onPressed: _previousPage, child: const Text('Back'))
          else
            const SizedBox(width: 64),
          Row(
            children: List.generate(
              5,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_currentPage == 1 && _selectedProviders.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please select at least one provider.'),
                  ),
                );
                return;
              }
              _nextPage();
            },
            child: Text(_currentPage == 4 ? 'Get Started' : 'Next'),
          ),
        ],
      ),
    );
  }

  Widget _buildStepHeader(String title, String subtitle) {
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

  Widget _buildLocationPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          _buildStepHeader(
            'Welcome to NeonVoyager',
            'Let\'s personalize your experience. Where are you watching from?',
          ),
          Card(
            child: ListTile(
              title: const Text('Country / Region'),
              subtitle: Text(_selectedCountryName),
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
                      builder: (context) => _buildCountryPickerSheet(context),
                    );
                if (selected != null) {
                  setState(() {
                    _selectedCountryCode = selected['code']!;
                    _selectedCountryName = selected['name']!;
                    // Reset providers if country changes
                    _selectedProviders.clear();
                    _selectedProviders.addAll(
                      StreamingProvider.getDefaultServiceIds(selected['code']!),
                    );
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountryPickerSheet(BuildContext context) {
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
                final isSelected = country['code'] == _selectedCountryCode;

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
                    Navigator.pop(context, country);
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

  Widget _buildStreamingProvidersPage() {
    final availableProviders = StreamingProvider.getProvidersForCountry(
      _selectedCountryCode,
    );

    // Auto-select defaults if empty during first initialization
    if (_selectedProviders.isEmpty && availableProviders.isNotEmpty) {
      _selectedProviders.addAll(
        StreamingProvider.getDefaultServiceIds(_selectedCountryCode),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          _buildStepHeader(
            'Your Services',
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
                final isSelected = _selectedProviders.contains(provider.id);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedProviders.remove(provider.id);
                      } else {
                        _selectedProviders.add(provider.id);
                      }
                    });
                  },
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
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
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

  Widget _buildGenresPage() {
    // Top TMDB Genres for onboarding
    final genres = [
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          _buildStepHeader(
            'Favorite Genres',
            'Pick a few genres you love to help us recommend better.',
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: genres.map((genre) {
                  final isSelected = _selectedGenres.contains(genre['id']);
                  return FilterChip(
                    label: Text(genre['name'] as String),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedGenres.add(genre['id'] as int);
                        } else {
                          _selectedGenres.remove(genre['id'] as int);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemePage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          _buildStepHeader(
            'Choose a Theme',
            'Select how you want NeonVoyager to look.',
          ),
          RadioListTile<ThemeMode>(
            title: const Text('System Default'),
            value: ThemeMode.system,
            groupValue: _selectedTheme,
            onChanged: (val) => setState(() {
              _selectedTheme = val!;
              ref.read(themeModeProvider.notifier).state = val;
            }),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Dark Mode'),
            value: ThemeMode.dark,
            groupValue: _selectedTheme,
            onChanged: (val) => setState(() {
              _selectedTheme = val!;
              ref.read(themeModeProvider.notifier).state = val;
            }),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Light Mode'),
            value: ThemeMode.light,
            groupValue: _selectedTheme,
            onChanged: (val) => setState(() {
              _selectedTheme = val!;
              ref.read(themeModeProvider.notifier).state = val;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTasteProfilePage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          _buildStepHeader(
            'You\'re All Set!',
            'You can also import an existing taste profile if you exported one from another device.',
          ),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.5),
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: const Icon(Icons.import_export, size: 32),
              title: const Text('Import Taste Profile'),
              subtitle: const Text(
                'Import your watch history and lists from a JSON file.',
              ),
              onTap: () async {
                final success = await context.push<bool>('/taste-profile');
                if (success == true && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile imported successfully!'),
                    ),
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Or simply skip this step and start discovering!',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
