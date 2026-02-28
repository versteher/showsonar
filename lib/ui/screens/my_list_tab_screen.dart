import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_scout/l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import 'watch_history_screen.dart';
import 'watchlist_screen.dart';
import 'shared_watchlists_screen.dart';
import '../widgets/statistics/watch_statistics_view.dart';
import 'package:go_router/go_router.dart';
import '../../config/providers.dart';

/// Tabbed screen combining Watchlist, Watch History, Statistics, and Shared Lists
class MyListTabScreen extends ConsumerWidget {
  const MyListTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isLoggedIn = authState.valueOrNull != null;
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: AppTheme.background,
          elevation: 0,
          title: Text(
            AppLocalizations.of(context)!.navMyList,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            indicatorColor: const Color(0xFFE040FB),
            indicatorWeight: 3,
            labelColor: const Color(0xFFE040FB),
            unselectedLabelColor: AppTheme.textMuted,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            isScrollable: false,
            tabs: [
              Tab(
                icon: const Icon(Icons.bookmark_rounded, size: 20),
                text: AppLocalizations.of(context)!.tabWatchlist,
              ),
              Tab(
                icon: const Icon(Icons.history_rounded, size: 20),
                text: AppLocalizations.of(context)!.tabHistory,
              ),
              const Tab(
                icon: Icon(Icons.bar_chart_rounded, size: 20),
                text: 'Stats',
              ),
              const Tab(
                icon: Icon(Icons.group_rounded, size: 20),
                text: 'Shared',
              ),
            ],
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.backgroundGradient,
          ),
          child: isLoggedIn
              ? const TabBarView(
                  children: [
                    WatchlistScreen(),
                    WatchHistoryScreen(),
                    WatchStatisticsView(),
                    SharedWatchlistsScreen(),
                  ],
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_off,
                        size: 64,
                        color: AppTheme.textMuted,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Sign in to access your synchronized lists',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          context.push('/login');
                        },
                        child: const Text('Sign In'),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
