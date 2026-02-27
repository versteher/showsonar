import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neon_voyager/l10n/app_localizations.dart';

/// A wrapper to easily test individual screens.
/// It provides [ProviderScope] for State overrides and a [MaterialApp.router]
/// via [GoRouter] so `context.go()` calls don't crash the widget tests.
Widget pumpAppScreen({
  required Widget child,
  List<Override> overrides = const [],
  GoRouter? router,
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    ),
  );
}
