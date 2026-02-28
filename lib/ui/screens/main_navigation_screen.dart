import 'package:stream_scout/utils/app_haptics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_scout/l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../../utils/analytics_service.dart';
import '../widgets/offline_banner.dart';
import 'ai_chat_screen.dart';
import 'home_screen.dart';
import 'my_list_tab_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

/// Main screen with bottom navigation (mobile) or split view (tablet/desktop)
class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({
    super.key,
    AnalyticsService? analyticsService,
    this.testScreens,
  }) : _analyticsService = analyticsService;

  final AnalyticsService? _analyticsService;
  final List<Widget>? testScreens;

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;
  late final AnalyticsService _analytics;

  @override
  void initState() {
    super.initState();
    _analytics = widget._analyticsService ?? AnalyticsService();
    // Log the initial screen (home tab is shown first).
    _analytics.logScreenView(AnalyticsService.screenHome);
  }

  void _goToSettings() {
    final idx = 4;
    setState(() => _currentIndex = idx);
    _analytics.logScreenView(AnalyticsService.screenNameForTab(idx));
  }

  void _goToSearch() {
    final idx = 1;
    setState(() => _currentIndex = idx);
    _analytics.logScreenView(AnalyticsService.screenNameForTab(idx));
  }

  @override
  Widget build(BuildContext context) {
    final screens =
        widget.testScreens ??
        [
          HomeScreen(onSettingsTap: _goToSettings, onSearchTap: _goToSearch),
          const SearchScreen(),
          const AiChatScreen(),
          const MyListTabScreen(),
          const SettingsScreen(),
        ];

    final isWide = AppTheme.isTablet(context) || AppTheme.isDesktop(context);

    if (isWide) {
      return Scaffold(
        body: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: Row(
                children: [
                  _buildNavigationRail(context),
                  const VerticalDivider(
                    thickness: 1,
                    width: 1,
                    color: AppTheme.surfaceBorder,
                  ),
                  // Full-width content
                  Expanded(
                    child: IndexedStack(
                      index: _currentIndex,
                      children: screens,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: IndexedStack(index: _currentIndex, children: screens),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingXs,
              vertical: AppTheme.spacingSm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home_rounded,
                  label: AppLocalizations.of(context)!.navHome,
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.search_rounded,
                  label: AppLocalizations.of(context)!.navSearch,
                  index: 1,
                ),
                _buildNavItem(
                  icon: Icons.auto_awesome,
                  label: AppLocalizations.of(context)!.navAi,
                  index: 2,
                  isSpecial: true,
                ),
                _buildNavItem(
                  icon: Icons.history_rounded,
                  label: AppLocalizations.of(context)!.navMyList,
                  index: 3,
                ),
                _buildNavItem(
                  icon: Icons.settings_rounded,
                  label: AppLocalizations.of(context)!.navMore,
                  index: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationRail(BuildContext context) {
    return NavigationRail(
      selectedIndex: _currentIndex,
      onDestinationSelected: (index) {
        AppHaptics.selectionClick();
        setState(() => _currentIndex = index);
        _analytics.logScreenView(AnalyticsService.screenNameForTab(index));
      },
      backgroundColor: AppTheme.surface,
      selectedIconTheme: const IconThemeData(color: AppTheme.primary),
      unselectedIconTheme: const IconThemeData(color: AppTheme.textMuted),
      selectedLabelTextStyle: const TextStyle(
        color: AppTheme.primary,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      unselectedLabelTextStyle: const TextStyle(
        color: AppTheme.textMuted,
        fontSize: 12,
      ),
      labelType: NavigationRailLabelType.all,
      // Minimal leading space
      leading: const SizedBox(height: AppTheme.spacingMd),
      destinations: [
        NavigationRailDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home_rounded),
          label: Text(AppLocalizations.of(context)!.navHome),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.search_outlined),
          selectedIcon: const Icon(Icons.search_rounded),
          label: Text(AppLocalizations.of(context)!.navSearch),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.auto_awesome_outlined),
          selectedIcon: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF7C4DFF), Color(0xFFE040FB)],
            ).createShader(bounds),
            child: const Icon(Icons.auto_awesome, color: Colors.white),
          ),
          label: Text(
            AppLocalizations.of(context)!.navAi,
            style: const TextStyle(color: Color(0xFF7C4DFF)),
          ),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.history_outlined),
          selectedIcon: const Icon(Icons.history_rounded),
          label: Text(AppLocalizations.of(context)!.navMyList),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.settings_outlined),
          selectedIcon: const Icon(Icons.settings_rounded),
          label: Text(AppLocalizations.of(context)!.navMore),
        ),
      ],
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    bool isSpecial = false,
  }) {
    final isSelected = _currentIndex == index;

    return Semantics(
      button: true,
      selected: isSelected,
      label: isSelected
          ? AppLocalizations.of(context)!.semanticNavSelected(label)
          : label,
      excludeSemantics: true,
      child: GestureDetector(
        key: ValueKey('nav_item_$index'),
        behavior: HitTestBehavior.opaque,
        onTap: () {
          AppHaptics.selectionClick();
          setState(() => _currentIndex = index);
          _analytics.logScreenView(AnalyticsService.screenNameForTab(index));
        },
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: AppTheme.minTouchTarget,
            minHeight: AppTheme.minTouchTarget,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingSm,
              vertical: AppTheme.spacingSm,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isSpecial
                        ? const Color(0xFF7C4DFF).withValues(alpha: 0.2)
                        : AppTheme.primary.withValues(alpha: 0.2))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                isSpecial && isSelected
                    ? ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFF7C4DFF), Color(0xFFE040FB)],
                        ).createShader(bounds),
                        child: Icon(icon, color: Colors.white, size: 22),
                      )
                    : Icon(
                        icon,
                        color: isSelected
                            ? (isSpecial
                                  ? const Color(0xFF7C4DFF)
                                  : AppTheme.primary)
                            : AppTheme.textMuted,
                        size: 22,
                      ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? (isSpecial
                              ? const Color(0xFF7C4DFF)
                              : AppTheme.primary)
                        : AppTheme.textMuted,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
