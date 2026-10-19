import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skavia/core/services/notification_service.dart';
import 'package:skavia/shared/dialogs/notification_permission_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationService Architecture & Channels Test', () {
    test('NotificationService singleton instance is maintained', () {
      final s1 = NotificationService.instance;
      final s2 = NotificationService.instance;
      expect(identical(s1, s2), isTrue);
    });

    test('Urgent and General Channel IDs adhere to on-demand specifications', () {
      expect(NotificationService.urgentChannelId, equals('skavia_urgent_channel'));
      expect(NotificationService.generalChannelId, equals('skavia_general_channel'));
      expect(NotificationService.customSoundResource, equals('notification_sound'));
      expect(NotificationService.urgentChannelName, contains('Urgent'));
    });

    test('Notification payload tap stream is accessible and non-null', () {
      expect(NotificationService.instance.onNotificationTapped, isNotNull);
    });
  });

  group('NotificationPermissionSheet Widget Test', () {
    testWidgets('Renders prompt title, benefit items, and CTA buttons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NotificationPermissionSheet(),
          ),
        ),
      );

      // Verify header and description
      expect(find.text('Stay Updated in Real Time'), findsOneWidget);
      expect(find.textContaining('Enable notifications to receive urgent job offers'), findsOneWidget);

      // Verify benefits list
      expect(find.text('Instant Job Bids & Match Alerts'), findsOneWidget);
      expect(find.text('Direct Client & Worker Chat'), findsOneWidget);
      expect(find.text('Secure OTPs & Completion Alerts'), findsOneWidget);

      // Verify actions
      expect(find.text('Turn on Sound & Alerts'), findsOneWidget);
      expect(find.text('Maybe Later'), findsOneWidget);
    });
  });
}

