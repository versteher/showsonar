import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

const streamingCountries = [
  {'code': 'DE', 'name': 'Deutschland', 'flag': '🇩🇪'},
  {'code': 'AT', 'name': 'Österreich', 'flag': '🇦🇹'},
  {'code': 'CH', 'name': 'Schweiz', 'flag': '🇨🇭'},
  {'code': 'DK', 'name': 'Dänemark', 'flag': '🇩🇰'},
  {'code': 'US', 'name': 'USA', 'flag': '🇺🇸'},
  {'code': 'GB', 'name': 'UK', 'flag': '🇬🇧'},
  {'code': 'FR', 'name': 'Frankreich', 'flag': '🇫🇷'},
  {'code': 'ES', 'name': 'Spanien', 'flag': '🇪🇸'},
  {'code': 'IT', 'name': 'Italien', 'flag': '🇮🇹'},
  {'code': 'NL', 'name': 'Niederlande', 'flag': '🇳🇱'},
  {'code': 'SE', 'name': 'Schweden', 'flag': '🇸🇪'},
  {'code': 'NO', 'name': 'Norwegen', 'flag': '🇳🇴'},
];

class StreamingCountrySelector extends StatelessWidget {
  final String selectedCountry;
  final ValueChanged<String> onCountryChanged;

  const StreamingCountrySelector({
    super.key,
    required this.selectedCountry,
    required this.onCountryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final country = streamingCountries.firstWhere(
      (c) => c['code'] == selectedCountry,
    );

    return PopupMenuButton<String>(
      initialValue: selectedCountry,
      onSelected: onCountryChanged,
      itemBuilder: (context) => streamingCountries
          .map(
            (c) => PopupMenuItem(
              value: c['code'],
              child: Row(
                children: [
                  Text(c['flag']!, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(c['name']!),
                  if (c['code'] == selectedCountry) ...[
                    const Spacer(),
                    const Icon(Icons.check, color: AppTheme.primary, size: 18),
                  ],
                ],
              ),
            ),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.surfaceBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(country['flag']!, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Text(
              country['code']!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 18),
          ],
        ),
      ),
    );
  }
}
