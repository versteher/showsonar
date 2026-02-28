import 'dart:async';

import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:stream_scout/ui/theme/app_theme.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // Load fonts so golden tests don't render Ahem squares
  await loadAppFonts();

  // Disable all `flutter_animate` globally resolving Invalid Matrix frame bounds overflows natively
  Animate.restartOnHotReload = false;

  // Disable HTTP fetching for Google Fonts in tests
  GoogleFonts.config.allowRuntimeFetching = false;
  AppTheme.disableGoogleFonts = true;

  // Return the main test runner
  return testMain();
}
