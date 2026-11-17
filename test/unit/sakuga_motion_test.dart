import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skavia/shared/motion/sakuga_motion.dart';
import 'package:skavia/shared/widgets/app_button.dart';
import 'package:skavia/shared/widgets/app_text_field.dart';

void main() {
  group('SKAVIA Sakuga Motion Components', () {
    testWidgets('SakugaPressable & AppButton fire onPressed and respect disabled',
        (tester) async {
      int taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AppButton(
                  text: 'Confirm Booking',
                  onPressed: () => taps++,
                ),
                const AppButton(
                  text: 'Disabled Action',
                  onPressed: null,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Confirm Booking'));
      await tester.pumpAndSettle();
      expect(taps, 1);

      await tester.tap(find.text('Disabled Action'));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });

    testWidgets('SakugaToggle, SakugaCheckbox, and SakugaRadio update state',
        (tester) async {
      bool toggled = false;
      bool checked = false;
      String selected = 'a';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => Column(
                children: [
                  SakugaToggle(
                    value: toggled,
                    semanticLabel: 'Alerts',
                    onChanged: (v) => setState(() => toggled = v),
                  ),
                  SakugaCheckbox(
                    value: checked,
                    semanticLabel: 'Accept Terms',
                    onChanged: (v) => setState(() => checked = v),
                  ),
                  SakugaRadio<String>(
                    value: 'b',
                    groupValue: selected,
                    semanticLabel: 'Option B',
                    onChanged: (v) => setState(() => selected = v),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(SakugaToggle));
      await tester.pumpAndSettle();
      expect(toggled, isTrue);

      await tester.tap(find.byType(SakugaCheckbox));
      await tester.pumpAndSettle();
      expect(checked, isTrue);

      await tester.tap(find.byType(SakugaRadio<String>));
      await tester.pumpAndSettle();
      expect(selected, 'b');
    });

    testWidgets('SakugaTabs, SakugaProgress, SakugaRating, SakugaSlider, SakugaTooltip work',
        (tester) async {
      int tabIndex = 0;
      int rating = 3;
      double sliderVal = 0.5;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => Column(
                children: [
                  SakugaTabs(
                    tabs: const ['Overview', 'Bookings', 'History'],
                    selectedIndex: tabIndex,
                    onChanged: (i) => setState(() => tabIndex = i),
                  ),
                  const SakugaProgress(
                    value: 0.75,
                    label: 'Profile Completion',
                  ),
                  SakugaRating(
                    rating: rating,
                    onChanged: (r) => setState(() => rating = r),
                  ),
                  SakugaSlider(
                    value: sliderVal,
                    onChanged: (v) => setState(() => sliderVal = v),
                  ),
                  const SakugaTooltip(
                    message: 'Verified Info',
                    child: Icon(Icons.info_outline),
                  ),
                  const AppTextField(
                    label: 'Full Name',
                    hint: 'Enter your name',
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Bookings'));
      await tester.pumpAndSettle();
      expect(tabIndex, 1);

      expect(find.text('75%'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.star_outline_rounded).last);
      await tester.pumpAndSettle();
      expect(rating, 5);

      await tester.enterText(find.byType(TextFormField), 'Rahim');
      await tester.pumpAndSettle();
      expect(find.text('Rahim'), findsOneWidget);
    });

    testWidgets('SakugaMotion respects MediaQuery disableAnimations (reduced motion)',
        (tester) async {
      bool reducedDetected = false;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                reducedDetected = SakugaMotion.isReduced(context);
                return SakugaPressable(
                  onTap: () {},
                  child: const Text('Reduced Motion Safe'),
                );
              },
            ),
          ),
        ),
      );

      expect(reducedDetected, isTrue);
      await tester.tap(find.text('Reduced Motion Safe'));
      await tester.pumpAndSettle();
    });
  });
}
