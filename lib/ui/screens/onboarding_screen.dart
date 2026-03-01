import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_scout/config/providers.dart';
import 'package:stream_scout/data/constants/countries.dart';
import 'package:stream_scout/data/models/streaming_provider.dart';
import 'package:stream_scout/ui/screens/onboarding_steps.dart';

/// 3-step onboarding flow:
///   Step 0 — Country + Streaming providers (combined, scrollable)
///   Step 1 — Genre preferences
///   Step 2 — Done / "You're all set!"
///
/// A "Skip" button on steps 0 and 1 lets users finish immediately.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const int _totalPages = 3;

  final PageController _pageController = PageController();
  int _currentPage = 0;

  late String _selectedCountryCode;
  late String _selectedCountryName;
  late final List<String> _selectedProviders;
  final List<int> _selectedGenres = [];

  @override
  void initState() {
    super.initState();
    // Auto-detect country from device locale; fall back to 'US'
    final localeCountry =
        WidgetsBinding.instance.platformDispatcher.locale.countryCode ?? 'US';
    final match = netflixCountries.firstWhere(
      (c) => c['code'] == localeCountry,
      orElse: () =>
          netflixCountries.firstWhere((c) => c['code'] == 'US',
          orElse: () => netflixCountries.first),
    );
    _selectedCountryCode = match['code']!;
    _selectedCountryName = match['name']!;
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
    if (_currentPage < _totalPages - 1) {
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

    var prefs = await userPrefsRepo.getPreferences();
    prefs = prefs.copyWith(
      countryCode: _selectedCountryCode,
      countryName: _selectedCountryName,
      subscribedServiceIds: _selectedProviders,
      favoriteGenreIds: _selectedGenres,
    );
    await userPrefsRepo.savePreferences(prefs);
    await localPrefsRepo.setHasSeenOnboarding(true);

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
                  setState(() => _currentPage = index);
                },
                children: [
                  OnboardingLocationAndStreamingStep(
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
                  const OnboardingDoneStep(),
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
    final isLastPage = _currentPage == _totalPages - 1;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back or empty placeholder
          if (_currentPage > 0)
            TextButton(onPressed: _previousPage, child: const Text('Back'))
          else
            const SizedBox(width: 64),

          // Page dots
          Row(
            children: List.generate(
              _totalPages,
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

          // Skip (non-final steps) + Next / Get Started
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isLastPage)
                TextButton(
                  onPressed: _finishOnboarding,
                  child: const Text('Skip'),
                ),
              const SizedBox(width: 4),
              ElevatedButton(
                onPressed: _nextPage,
                child: Text(isLastPage ? 'Get Started' : 'Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
