import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_scout/config/providers.dart';
import 'package:stream_scout/domain/viewing_context.dart';
import 'package:stream_scout/ui/widgets/viewing_context_chip_bar.dart';
import '../../utils/test_app_wrapper.dart';

void main() {
  group('ViewingContextChipBar', () {
    testWidgets('renders all 4 context chips', (tester) async {
      await tester.pumpWidget(
        pumpAppScreen(child: const ViewingContextChipBar()),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Kids'), findsOneWidget);
      expect(find.text('Date Night'), findsOneWidget);
      expect(find.text('Solo'), findsOneWidget);
    });

    testWidgets('tapping a chip updates viewingContextProvider', (
      tester,
    ) async {
      late WidgetRef capturedRef;

      await tester.pumpWidget(
        pumpAppScreen(
          child: Consumer(
            builder: (context, ref, _) {
              capturedRef = ref;
              return const ViewingContextChipBar();
            },
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      // Default is "All"
      expect(
        capturedRef.read(viewingContextProvider),
        ViewingContext.all,
      );

      // Tap "Kids"
      await tester.tap(find.text('Kids'));
      await tester.pump();

      expect(
        capturedRef.read(viewingContextProvider),
        ViewingContext.kids,
      );

      // Tap "Date Night"
      await tester.tap(find.text('Date Night'));
      await tester.pump();

      expect(
        capturedRef.read(viewingContextProvider),
        ViewingContext.dateNight,
      );
    });
  });
}
