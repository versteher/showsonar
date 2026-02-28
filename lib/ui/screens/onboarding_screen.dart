import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neon_voyager/config/providers.dart';
import 'package:neon_voyager/data/models/streaming_provider.dart';
import 'package:neon_voyager/ui/screens/onboarding_steps.dart';
import 'package:neon_voyager/ui/screens/onboarding_taste_step.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late final List<String> _selectedProviders;
  final List<int> _selectedGenres = [];
  String _selectedCountryCode = 'DE';
  String _selectedCountryName = 'Deutschland';
  ThemeMode _selectedTheme = ThemeMode.dark;

  @override
  void initState() {
    super.initState();
    _selectedProviders = List.from(
      StreamingProvider.getDefaultServiceIds(_selectedCountryCode),
    );
  }

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
                  OnboardingLocationStep(
                    selectedCountryCode: _selectedCountryCode,
                    selectedCountryName: _selectedCountryName,
                    onCountrySelected: (code, name) {
                      setState(() {
                        _selectedCountryCode = code;
                        _selectedCountryName = name;
                        _selectedProviders.clear();
                        _selectedProviders.addAll(
                          StreamingProvider.getDefaultServiceIds(code),
                        );
                      });
                    },
                  ),
                  OnboardingStreamingStep(
                    selectedCountryCode: _selectedCountryCode,
                    selectedProviders: _selectedProviders,
                    onToggleProvider: (id, selected) {
                      setState(() {
                        if (selected) {
                          _selectedProviders.add(id);
                        } else {
                          _selectedProviders.remove(id);
                        }
                      });
                    },
                  ),
                  OnboardingGenresStep(
                    selectedGenres: _selectedGenres,
                    onToggleGenre: (id, selected) {
                      setState(() {
                        if (selected) {
                          _selectedGenres.add(id);
                        } else {
                          _selectedGenres.remove(id);
                        }
                      });
                    },
                  ),
                  OnboardingThemeStep(
                    selectedTheme: _selectedTheme,
                    onThemeChanged: (mode) {
                      setState(() {
                        _selectedTheme = mode;
                      });
                    },
                  ),
                  const OnboardingTasteStep(),
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
}
