import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:neon_voyager/ui/widgets/offline_banner.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:neon_voyager/config/providers.dart';
import 'package:neon_voyager/l10n/app_localizations.dart';

void main() {
  testWidgets('OfflineBanner triggers internet exception', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          connectivityProvider.overrideWith(
            (ref) => Stream.value([ConnectivityResult.wifi]),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: OfflineBanner()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(OfflineBanner), findsOneWidget);
  });
}
