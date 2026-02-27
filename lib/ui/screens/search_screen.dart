import 'package:neon_voyager/utils/app_haptics.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:lottie/lottie.dart';

import 'package:neon_voyager/l10n/app_localizations.dart';

import '../../config/providers.dart';
import '../../data/models/media.dart';
import '../theme/app_theme.dart';
import '../widgets/media_card.dart';
import '../widgets/filter_settings_sheet.dart';

/// Search screen with debounced search and results grid
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _speech.stop();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(searchQueryProvider.notifier).state = query;
    });
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }

    try {
      print('Initializing speech recognition...');
      final available = await _speech.initialize(
        onError: (error) {
          print('Speech initialization error: $error');
          setState(() => _isListening = false);
        },
        debugLogging: true,
      );
      print('Speech initialization result: $available');

      if (available) {
        setState(() => _isListening = true);
        await _speech.listen(
          localeId:
              'en_US', // Changed to en_US for broader compatibility testing
          onResult: (result) {
            _searchController.text = result.recognizedWords;
            if (result.finalResult) {
              setState(() => _isListening = false);
              _onSearchChanged(result.recognizedWords);
            }
          },
          listenFor: const Duration(seconds: 10),
          pauseFor: const Duration(seconds: 3),
        );
      } else {
        print('Speech recognition not available on this device');
      }
    } catch (e, stack) {
      print('Error initializing speech recognition: $e');
      print(stack);
      setState(() => _isListening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchResultsProvider);
    final currentQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Search Header
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                child: Row(
                  children: [
                    // Back Button
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded),
                      onPressed: () => context.pop(),
                    ),

                    // Search Field
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: _isListening
                              ? AppLocalizations.of(context)!.searchListening
                              : AppLocalizations.of(context)!.searchHint,
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: AppTheme.textMuted,
                          ),
                          suffixIcon: currentQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded),
                                  onPressed: () {
                                    _searchController.clear();
                                    ref
                                            .read(searchQueryProvider.notifier)
                                            .state =
                                        '';
                                  },
                                )
                              : null,
                        ),
                        style: const TextStyle(color: AppTheme.textPrimary),
                      ),
                    ),

                    // Voice search button
                    const SizedBox(width: 4),
                    Semantics(
                      button: true,
                      toggled: _isListening,
                      label: _isListening
                          ? AppLocalizations.of(
                              context,
                            )!.semanticVoiceSearchActive
                          : AppLocalizations.of(context)!.semanticVoiceSearch,
                      child: GestureDetector(
                        onTap: _toggleListening,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: _isListening
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFFFF0000),
                                      Color(0xFFFF4444),
                                    ],
                                  )
                                : null,
                            color: _isListening ? null : AppTheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: _isListening
                                ? [
                                    BoxShadow(
                                      color: const Color(
                                        0xFFFF0000,
                                      ).withOpacity(0.4),
                                      blurRadius: 12,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Icon(
                            _isListening ? Icons.mic : Icons.mic_none_rounded,
                            color: _isListening
                                ? Colors.white
                                : AppTheme.textMuted,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Filter Button
                    Semantics(
                      button: true,
                      label: AppLocalizations.of(context)!.semanticFilterButton,
                      child: GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            builder: (context) => const FilterSettingsSheet(),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.surfaceBorder),
                          ),
                          child: const Icon(
                            Icons.tune_rounded,
                            color: AppTheme.textMuted,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Results
              Expanded(child: _buildContent(searchResults, currentQuery)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(AsyncValue<List<Media>> results, String query) {
    if (query.isEmpty || query.length < 2) {
      return _buildEmptyState();
    }

    return results.when(
      data: (items) {
        if (items.isEmpty) {
          return _buildNoResultsState();
        }
        return _buildResultsGrid(items);
      },
      loading: () => _buildLoadingState(),
      error: (error, _) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/empty_search.json',
            width: 200,
            height: 200,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Text(
            'Keep typing to find movies & series',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/empty_search.json',
            width: 200,
            height: 200,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Text(
            'No results found for "${_searchController.text}"',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppTheme.textMuted),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          const Text(
            'Try checking for typos or using different keywords',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: AppTheme.surface,
      highlightColor: AppTheme.surfaceLight,
      child: GridView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _getCrossAxisCount(context),
          childAspectRatio: AppTheme.posterAspectRatio * 0.85,
          mainAxisSpacing: AppTheme.spacingMd,
          crossAxisSpacing: AppTheme.spacingMd,
        ),
        itemCount: 9,
        itemBuilder: (context, index) {
          return Container(
            constraints: const BoxConstraints(minHeight: 100),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String error) {
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
              size: 40,
              color: AppTheme.error,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Text(
            AppLocalizations.of(context)!.searchErrorTitle,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppTheme.textPrimary),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          ElevatedButton.icon(
            onPressed: () {
              ref.invalidate(searchResultsProvider);
            },
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: Text(AppLocalizations.of(context)!.searchRetry),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsGrid(List<Media> items) {
    return GridView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getCrossAxisCount(context),
        childAspectRatio: AppTheme.posterAspectRatio * 0.82,
        mainAxisSpacing: AppTheme.spacingMd,
        crossAxisSpacing: AppTheme.spacingMd,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final media = items[index];
        return LayoutBuilder(
          builder: (context, constraints) {
            return MediaCard(
              media: media,
              width: constraints.maxWidth,
              heroTagPrefix: 'search',
              onTap: () => _navigateToDetail(media),
            );
          },
        );
      },
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    if (AppTheme.isDesktop(context)) return 6;
    if (AppTheme.isTablet(context)) return 4;
    return 3;
  }

  void _navigateToDetail(Media media) {
    AppHaptics.lightImpact();
    context.push(
      '/${media.type.name}/${media.id}',
      extra: {'heroTagPrefix': 'search'},
    );
  }
}
