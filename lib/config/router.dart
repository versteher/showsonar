import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_scout/config/providers.dart';
import 'package:stream_scout/ui/screens/main_navigation_screen.dart';
import 'package:stream_scout/ui/screens/search_screen.dart';
import 'package:stream_scout/ui/screens/login_screen.dart';
import 'package:stream_scout/ui/screens/detail_screen.dart';
import 'package:stream_scout/ui/screens/person_screen.dart';
import 'package:stream_scout/ui/screens/taste_profile_screen.dart';
import 'package:stream_scout/ui/screens/watch_history_screen.dart';
import 'package:stream_scout/ui/screens/watchlist_screen.dart';
import 'package:stream_scout/ui/screens/onboarding_screen.dart';
import 'package:stream_scout/ui/screens/social_screen.dart';
import 'package:stream_scout/ui/screens/profile_management_screen.dart';
import 'package:stream_scout/ui/screens/year_in_review_screen.dart';
import 'package:stream_scout/ui/screens/episode_tracking_screen.dart';
import '../data/models/media.dart';

Page<dynamic> _buildPageWithTransition(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final platform = Theme.of(context).platform;

      if (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS) {
        // iOS: slide right-to-left
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;
        final tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        final offsetAnimation = animation.drive(tween);

        return SlideTransition(position: offsetAnimation, child: child);
      } else {
        // Android/Other: Fade-through (Material Motion style)
        const curve = Curves.easeIn;
        final tween = Tween(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: curve));

        return FadeTransition(opacity: animation.drive(tween), child: child);
      }
    },
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final localPrefs = ref.read(localPreferencesRepositoryProvider);
      final hasSeenOnboarding = localPrefs.hasSeenOnboarding;

      final isOnboarding = state.matchedLocation == '/onboarding';
      final isTasteProfile = state.matchedLocation == '/taste-profile';

      if (!hasSeenOnboarding) {
        if (isOnboarding || isTasteProfile) return null;
        return '/onboarding';
      }

      if (isOnboarding && hasSeenOnboarding) {
        return '/';
      }

      // Check auth state from riverpod provider stream dynamically
      final authState = ref.read(authStateProvider);
      final isLoggedIn = authState.valueOrNull != null;
      final isLoggingIn = state.matchedLocation == '/login';
      final isSigningUp = state.matchedLocation == '/signup';

      if (!isLoggedIn && !isLoggingIn && !isSigningUp && !isTasteProfile) {
        return '/login';
      }

      if (isLoggedIn && (isLoggingIn || isSigningUp)) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) =>
            _buildPageWithTransition(context, state, const OnboardingScreen()),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) =>
            _buildPageWithTransition(context, state, const LoginScreen()),
      ),
      GoRoute(
        path: '/signup',
        pageBuilder: (context, state) =>
            _buildPageWithTransition(context, state, const SignupScreen()),
      ),
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context,
          state,
          MainNavigationScreen(
            analyticsService: ref.watch(analyticsServiceProvider),
          ),
        ),
        routes: [
          GoRoute(
            path: 'movie/:id',
            pageBuilder: (context, state) {
              final mediaId = state.pathParameters['id']!;
              final mediaTypeStr = state.pathParameters['type'] ?? 'movie';
              final mediaType = MediaType.values.firstWhere(
                (e) => e.name == mediaTypeStr,
                orElse: () => MediaType.movie,
              );
              final extra = state.extra as Map<String, dynamic>?;
              final heroTagPrefix = extra?['heroTagPrefix'] as String?;
              return _buildPageWithTransition(
                context,
                state,
                DetailScreen(
                  mediaId: int.parse(mediaId),
                  mediaType: mediaType,
                  heroTagPrefix: heroTagPrefix,
                ),
              );
            },
          ),
          GoRoute(
            path: 'tv/:id',
            pageBuilder: (context, state) {
              final mediaId = state.pathParameters['id']!;
              final mediaTypeStr = state.pathParameters['type'] ?? 'tv';
              final mediaType = MediaType.values.firstWhere(
                (e) => e.name == mediaTypeStr,
                orElse: () => MediaType.tv,
              );
              final extra = state.extra as Map<String, dynamic>?;
              final heroTagPrefix = extra?['heroTagPrefix'] as String?;
              return _buildPageWithTransition(
                context,
                state,
                DetailScreen(
                  mediaId: int.parse(mediaId),
                  mediaType: mediaType,
                  heroTagPrefix: heroTagPrefix,
                ),
              );
            },
            routes: [
              GoRoute(
                path: 'episodes',
                pageBuilder: (context, state) {
                  final tvId = int.parse(state.pathParameters['id']!);
                  final extra = state.extra as Map<String, dynamic>?;
                  final seriesTitle =
                      extra?['seriesTitle'] as String? ?? 'TV Series';
                  final numberOfSeasons =
                      extra?['numberOfSeasons'] as int? ?? 1;
                  final posterPath = extra?['posterPath'] as String?;
                  return _buildPageWithTransition(
                    context,
                    state,
                    EpisodeTrackingScreen(
                      tvId: tvId,
                      seriesTitle: seriesTitle,
                      numberOfSeasons: numberOfSeasons,
                      posterPath: posterPath,
                    ),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: 'person/:id',
            pageBuilder: (context, state) {
              final personId = state.pathParameters['id']!;
              final extra = state.extra as Map<String, dynamic>?;
              final heroTagPrefix = extra?['heroTagPrefix'] as String?;
              return _buildPageWithTransition(
                context,
                state,
                PersonScreen(
                  personId: int.parse(personId),
                  heroTagPrefix: heroTagPrefix,
                ),
              );
            },
          ),
          GoRoute(
            path: 'taste-profile',
            pageBuilder: (context, state) => _buildPageWithTransition(
              context,
              state,
              const TasteProfileScreen(),
            ),
          ),
          GoRoute(
            path: 'watch-history',
            pageBuilder: (context, state) => _buildPageWithTransition(
              context,
              state,
              const WatchHistoryScreen(),
            ),
          ),
          GoRoute(
            path: 'watchlist',
            pageBuilder: (context, state) => _buildPageWithTransition(
              context,
              state,
              const WatchlistScreen(),
            ),
          ),
          GoRoute(
            path: 'search',
            pageBuilder: (context, state) =>
                _buildPageWithTransition(context, state, const SearchScreen()),
          ),
          GoRoute(
            path: 'social',
            pageBuilder: (context, state) =>
                _buildPageWithTransition(context, state, const SocialScreen()),
          ),
          GoRoute(
            path: 'profiles',
            pageBuilder: (context, state) => _buildPageWithTransition(
              context,
              state,
              const ProfileManagementScreen(),
            ),
          ),
          GoRoute(
            path: 'year-in-review',
            pageBuilder: (context, state) {
              final yearParam = state.uri.queryParameters['year'];
              final year = int.tryParse(yearParam ?? '') ?? DateTime.now().year;
              return _buildPageWithTransition(
                context,
                state,
                YearInReviewScreen(year: year),
              );
            },
          ),
        ],
      ),
    ],
  );

  ref.listen(authStateProvider, (previous, next) {
    if (previous?.valueOrNull != next.valueOrNull) {
      router.refresh();
    }
  });

  return router;
});
