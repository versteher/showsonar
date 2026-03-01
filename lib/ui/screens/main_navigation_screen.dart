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

/// Main screen with bottom navigation (mobile) or split view (tablet/desktop).
///
/// Layout: 4 tabs (Home, Search, Library, Profile) with a centre AI chat
/// button that opens the chat as a modal sheet — not as a permanent tab.
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
    _analytics.logScreenView(AnalyticsService.screenHome);
  }

  void _goToSettings() {
    const idx = 3; // Profile tab
    setState(() => _currentIndex = idx);
    _analytics.logScreenView(AnalyticsService.screenNameForTab(idx));
  }

  void _goToSearch() {
    const idx = 1;
    setState(() => _currentIndex = idx);
    _analytics.logScreenView(AnalyticsService.screenNameForTab(idx));
  }

  void _openAiChat(BuildContext context) {
    AppHaptics.mediumImpact();
    _analytics.logScreenView(AnalyticsService.screenAiChat);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => const _AiChatSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens =
        widget.testScreens ??
        [
          HomeScreen(onSettingsTap: _goToSettings, onSearchTap: _goToSearch),
          const SearchScreen(),
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
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTabSelected: (index) {
          AppHaptics.selectionClick();
          setState(() => _currentIndex = index);
          _analytics.logScreenView(AnalyticsService.screenNameForTab(index));
        },
        onAiTap: () => _openAiChat(context),
      ),
    );
  }

  Widget _buildNavigationRail(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
      leading: Column(
        children: [
          const SizedBox(height: AppTheme.spacingMd),
          // AI chat button in rail
          Tooltip(
            message: l10n.navAi,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              onTap: () => _openAiChat(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF7C4DFF), Color(0xFFE040FB)],
                      ).createShader(bounds),
                      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 22),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.navAi,
                      style: const TextStyle(color: Color(0xFF7C4DFF), fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
        ],
      ),
      destinations: [
        NavigationRailDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home_rounded),
          label: Text(l10n.navHome),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.search_outlined),
          selectedIcon: const Icon(Icons.search_rounded),
          label: Text(l10n.navSearch),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.video_library_outlined),
          selectedIcon: const Icon(Icons.video_library_rounded),
          label: Text(l10n.navLibrary),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.person_outline_rounded),
          selectedIcon: const Icon(Icons.person_rounded),
          label: Text(l10n.navProfile),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom nav bar — 4 tabs + centre AI chat action button
// ---------------------------------------------------------------------------
class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.currentIndex,
    required this.onTabSelected,
    required this.onAiTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onAiTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
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
              _NavItem(
                icon: Icons.home_rounded,
                label: l10n.navHome,
                index: 0,
                currentIndex: currentIndex,
                onTap: onTabSelected,
              ),
              _NavItem(
                icon: Icons.search_rounded,
                label: l10n.navSearch,
                index: 1,
                currentIndex: currentIndex,
                onTap: onTabSelected,
              ),
              // Centre AI chat button — opens modal, not a tab
              _AiChatButton(onTap: onAiTap),
              _NavItem(
                icon: Icons.video_library_rounded,
                label: l10n.navLibrary,
                index: 2,
                currentIndex: currentIndex,
                onTap: onTabSelected,
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: l10n.navProfile,
                index: 3,
                currentIndex: currentIndex,
                onTap: onTabSelected,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = currentIndex == index;
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
        onTap: () => onTap(index),
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
                  ? AppTheme.primary.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isSelected ? AppTheme.primary : AppTheme.textMuted,
                  size: 22,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? AppTheme.primary : AppTheme.textMuted,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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

/// Centre AI chat action button — gradient pill, not a tab destination.
class _AiChatButton extends StatelessWidget {
  const _AiChatButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7C4DFF), Color(0xFFE040FB)],
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C4DFF).withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.auto_awesome, color: Colors.white, size: 22),
      ),
    );
  }
}

/// Full-height modal sheet wrapping the AI chat screen.
class _AiChatSheet extends StatelessWidget {
  const _AiChatSheet();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: const AiChatScreen(),
      ),
    );
  }
}
