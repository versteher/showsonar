import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neon_voyager/l10n/app_localizations.dart';
import '../../config/providers.dart';
import '../../data/constants/countries.dart';
import '../theme/app_theme.dart';
import 'app_snack_bar.dart';

class CountrySelector extends ConsumerWidget {
  final String code;
  final String name;

  const CountrySelector({super.key, required this.code, required this.name});

  String _getFlagEmoji(String countryCode) {
    final country = netflixCountries.firstWhere(
      (c) => c['code'] == countryCode.toUpperCase(),
      orElse: () => {'flag': '🌍'},
    );
    return country['flag']!;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showCountryPicker(context, ref),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: AppTheme.surfaceBorder),
        ),
        child: Row(
          children: [
            Text(_getFlagEmoji(code), style: const TextStyle(fontSize: 32)),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: Theme.of(context).textTheme.titleMedium),
                  Text(
                    AppLocalizations.of(context)!.settingsChangeCountry,
                    style: Theme.of(context).textTheme.bodySmall,
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

  void _showCountryPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                AppLocalizations.of(context)!.settingsSelectCountry,
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
                  final isSelected = country['code'] == code;

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
                            ? AppTheme.primary
                            : AppTheme.textPrimary,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle,
                            color: AppTheme.primary,
                          )
                        : null,
                    onTap: () async {
                      final repo = ref.read(userPreferencesRepositoryProvider);
                      await repo.init();
                      await repo.updateCountry(
                        country['code']!,
                        country['name']!,
                      );
                      ref.invalidate(userPreferencesProvider);

                      if (ctx.mounted) context.pop();

                      if (context.mounted) {
                        AppSnackBar.showSuccess(
                          context,
                          AppLocalizations.of(
                            context,
                          )!.settingsCountryChanged(country['name']!),
                        );
                      }
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
