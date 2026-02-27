import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neon_voyager/l10n/app_localizations.dart';
import '../../config/providers.dart';
import '../../data/models/user_preferences.dart';

import '../theme/app_theme.dart';
import '../widgets/app_snack_bar.dart';
import '../widgets/app_page_route.dart';
import 'taste_profile_screen.dart';
import '../widgets/streaming_services_grid.dart';
import '../widgets/country_selector.dart';
import '../widgets/branded_loading_indicator.dart';
import '../widgets/profile_switcher_tile.dart';

/// Settings screen for managing user preferences
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(userPreferencesProvider);
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              pinned: true,
              backgroundColor: AppTheme.background,
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: const Icon(Icons.settings_rounded, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(AppLocalizations.of(context)!.settingsTitle),
                ],
              ),
            ),

            // Content
            SliverToBoxAdapter(
              child: prefsAsync.when(
                data: (prefs) => Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Streaming Services Section
                      _buildSectionTitle(
                        context,
                        AppLocalizations.of(context)!.settingsStreamingTitle,
                      ),
                      const SizedBox(height: AppTheme.spacingSm),
                      Text(
                        AppLocalizations.of(context)!.settingsStreamingSubtitle,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                      StreamingServicesGrid(
                        subscribedIds: prefs.subscribedServiceIds,
                        countryCode: prefs.countryCode,
                      ),

                      const SizedBox(height: AppTheme.spacingXl),

                      // Country Section
                      // Country Section
                      _buildSectionTitle(
                        context,
                        AppLocalizations.of(context)!.settingsCountry,
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                      CountrySelector(
                        code: prefs.countryCode,
                        name: prefs.countryName,
                      ),

                      const SizedBox(height: AppTheme.spacingXl),

                      // Theme Section
                      _buildSectionTitle(context, 'Theme'),
                      const SizedBox(height: AppTheme.spacingMd),
                      _buildThemeSelector(context, ref, prefs),

                      const SizedBox(height: AppTheme.spacingXl),

                      // Profiles Section
                      _buildSectionTitle(context, '👥 Profiles'),
                      const SizedBox(height: AppTheme.spacingMd),
                      const ProfileSwitcherTile(),

                      const SizedBox(height: AppTheme.spacingXl),

                      // Account Section
                      _buildSectionTitle(context, 'Account'),
                      const SizedBox(height: AppTheme.spacingMd),
                      _buildAccountCard(context, ref, authState),

                      const SizedBox(height: AppTheme.spacingXl),

                      // Reset Section
                      // Reset Section
                      _buildSectionTitle(
                        context,
                        AppLocalizations.of(context)!.settingsReset,
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                      _buildResetButton(context, ref),

                      const SizedBox(height: AppTheme.spacingXl),

                      // Taste Profile Section
                      _buildSectionTitle(context, '👤 Taste Profil'),
                      const SizedBox(height: AppTheme.spacingMd),
                      _buildTasteProfileCard(context),

                      const SizedBox(height: AppTheme.spacingXl),

                      // API Info Section
                      // API Info Section
                      _buildSectionTitle(
                        context,
                        AppLocalizations.of(context)!.settingsApi,
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                      _buildApiInfoCard(context),

                      const SizedBox(height: AppTheme.spacingXl),

                      // About Section
                      // About Section
                      _buildSectionTitle(
                        context,
                        AppLocalizations.of(context)!.settingsAbout,
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                      _buildAboutCard(context),

                      const SizedBox(height: AppTheme.spacingXl),
                    ],
                  ),
                ),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(64),
                    child: BrandedLoadingIndicator(),
                  ),
                ),
                error: (error, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppTheme.error,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)!.errorGeneric('$error'),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () =>
                              ref.invalidate(userPreferencesProvider),
                          child: Text(AppLocalizations.of(context)!.errorRetry),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(title, style: Theme.of(context).textTheme.headlineSmall);
  }

  Widget _buildThemeSelector(
    BuildContext context,
    WidgetRef ref,
    UserPreferences prefs,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: SegmentedButton<String>(
        segments: const [
          ButtonSegment<String>(
            value: 'system',
            icon: Icon(Icons.brightness_auto),
            label: Text('System'),
          ),
          ButtonSegment<String>(
            value: 'light',
            icon: Icon(Icons.light_mode),
            label: Text('Light'),
          ),
          ButtonSegment<String>(
            value: 'dark',
            icon: Icon(Icons.dark_mode),
            label: Text('Dark'),
          ),
        ],
        selected: {prefs.themeMode},
        onSelectionChanged: (Set<String> newSelection) async {
          final modeStr = newSelection.first;
          final newMode = ThemeMode.values.firstWhere(
            (e) => e.name == modeStr,
            orElse: () => ThemeMode.system,
          );
          ref.read(themeModeProvider.notifier).state = newMode;
          ref.read(localPreferencesRepositoryProvider).setThemeMode(newMode);

          final repo = ref.read(userPreferencesRepositoryProvider);
          await repo.init();
          await repo.updateThemeMode(modeStr);
          ref.invalidate(userPreferencesProvider);
        },
      ),
    );
  }

  Widget _buildAccountCard(
    BuildContext context,
    WidgetRef ref,
    AsyncValue authState,
  ) {
    final user = authState.valueOrNull;
    final isLoggedIn = user != null;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isLoggedIn ? AppTheme.success : AppTheme.primary)
                  .withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Icon(
              isLoggedIn ? Icons.account_circle : Icons.login,
              color: isLoggedIn ? AppTheme.success : AppTheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLoggedIn ? 'Signed In' : 'Not Signed In',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  isLoggedIn
                      ? (user.email ?? 'Authenticated')
                      : 'Sign in to sync your data',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () async {
              if (isLoggedIn) {
                await ref.read(authServiceProvider).signOut();
              } else {
                context.push('/login');
              }
            },
            child: Text(isLoggedIn ? 'Sign Out' : 'Sign In'),
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.warning.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: const Icon(
              Icons.refresh_rounded,
              color: AppTheme.warning,
              size: 20,
            ),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.settingsResetTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  AppLocalizations.of(context)!.settingsResetSubtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppTheme.surface,
                  title: Text(
                    AppLocalizations.of(context)!.settingsResetConfirm,
                  ),
                  content: Text(
                    AppLocalizations.of(context)!.settingsResetMessage,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => context.pop(false),
                      child: Text(AppLocalizations.of(context)!.detailCancel),
                    ),
                    ElevatedButton(
                      onPressed: () => context.pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.warning,
                      ),
                      child: Text(AppLocalizations.of(context)!.settingsReset),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                final repo = ref.read(userPreferencesRepositoryProvider);
                await repo.init();
                await repo.resetToDefaults();
                ref.invalidate(userPreferencesProvider);

                if (context.mounted) {
                  AppSnackBar.showSuccess(
                    context,
                    AppLocalizations.of(context)!.settingsResetTitle,
                    icon: Icons.refresh_rounded,
                  );
                }
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Widget _buildApiInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppTheme.success,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.settingsApi,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            AppLocalizations.of(context)!.settingsApiInfo,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NeonVoyager',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    AppLocalizations.of(context)!.settingsVersion,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Text(
            AppLocalizations.of(context)!.settingsDescription,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildTasteProfileCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(
        context,
      ).push(AppPageRoute(page: const TasteProfileScreen())),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF7C4DFF).withValues(alpha: 0.15),
              const Color(0xFFE040FB).withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: const Color(0xFF7C4DFF).withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C4DFF), Color(0xFFE040FB)],
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: const Icon(
                Icons.share_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profil teilen & vergleichen',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Exportiere dein Sehprofil oder importiere das eines Freundes',
                    style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}
