import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:network_image_mock/network_image_mock.dart';

import 'package:stream_scout/ui/widgets/rating_dialog.dart';
import 'package:stream_scout/ui/theme/app_theme.dart';

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  testGoldens('RatingDialog - Light and Dark Themes', (tester) async {
    final dialog = MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: RepaintBoundary(
            child: Container(
              width: 400,
              height: 600,
              alignment: Alignment.center,
              child: RatingDialog(
                title: 'Inception',
                initialRating: 8.0,
                initialNotes: 'Amazing movie!',
              ),
            ),
          ),
        ),
      ),
    );

    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(Theme(data: AppTheme.darkTheme, child: dialog));

      // Pump an extra frame to allow animations to settle fully
      await tester.pump(const Duration(milliseconds: 500));

      await screenMatchesGolden(tester, 'rating_dialog');
    });
  });
}
