import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skavia/app/config/app_config.dart';
import 'package:skavia/app/router/app_router.dart';
import 'package:skavia/app/router/route_guards.dart';
import 'package:skavia/app/theme/app_theme.dart';
import 'package:skavia/core/network/network_connectivity_service.dart';
import 'package:skavia/core/services/app_language_service.dart';
import 'package:skavia/core/services/app_theme_service.dart';
import 'package:skavia/core/services/sound_haptic_preferences.dart';
import 'package:skavia/core/storage/local_cache_service.dart';
import 'package:skavia/core/storage/secure_storage_service.dart';
import 'package:skavia/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:skavia/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:skavia/features/admin/presentation/screens/dispute_resolution_screen.dart';
import 'package:skavia/features/admin/presentation/screens/team_assembly_screen.dart';
import 'package:skavia/features/admin/presentation/screens/verification_queue_screen.dart';
import 'package:skavia/features/billing/presentation/controllers/payment_controller.dart';
import 'package:skavia/features/billing/presentation/screens/invoice_screen.dart';
import 'package:skavia/features/billing/presentation/screens/payment_success_screen.dart';
import 'package:skavia/features/billing/presentation/screens/simulated_checkout_screen.dart';
import 'package:skavia/features/billing/presentation/screens/transaction_history_screen.dart';
import 'package:skavia/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:skavia/features/chat/data/models/chat_message_model.dart';
import 'package:skavia/features/chat/presentation/screens/chat_list_screen.dart';
import 'package:skavia/features/chat/presentation/screens/chat_room_screen.dart';
import 'package:skavia/features/chat/presentation/widgets/conversation_tile.dart';
import 'package:skavia/features/reviews/data/datasources/review_remote_datasource.dart';
import 'package:skavia/features/reviews/data/models/review_model.dart';
import 'package:skavia/features/reviews/presentation/screens/submit_complaint_screen.dart';
import 'package:skavia/features/reviews/presentation/screens/submit_review_screen.dart';
import 'package:skavia/features/reviews/presentation/screens/worker_reputation_screen.dart';
import 'package:skavia/features/reviews/presentation/widgets/review_item_card.dart';
import 'package:skavia/features/team_project/presentation/screens/assign_task_screen.dart';
import 'package:skavia/features/team_project/presentation/screens/project_dashboard_screen.dart';
import 'package:skavia/features/team_project/presentation/screens/project_showcase_screen.dart';
import 'package:skavia/features/team_project/presentation/screens/task_board_screen.dart';
import 'package:skavia/features/team_project/presentation/screens/team_discovery_screen.dart';
import 'package:skavia/features/team_project/presentation/screens/team_roster_screen.dart';
import 'package:skavia/features/worker/presentation/screens/active_job_screen.dart';
import 'package:skavia/features/worker/presentation/screens/availability_calendar_screen.dart';
import 'package:skavia/features/worker/presentation/screens/incoming_requests_screen.dart';
import 'package:skavia/features/worker/presentation/screens/portfolio_management_screen.dart';
import 'package:skavia/features/worker/presentation/screens/worker_earnings_screen.dart';
import 'package:skavia/features/worker/presentation/screens/worker_edit_profile_screen.dart';
import 'package:skavia/features/worker/presentation/screens/worker_profile_detail_screen.dart';
import 'package:skavia/features/worker/presentation/widgets/incoming_request_card.dart';
import 'package:skavia/features/worker/presentation/widgets/worker_dashboard_view.dart';
import 'package:skavia/features/worker/presentation/widgets/worker_job_otp_sheet.dart';
import 'package:skavia/features/worker/presentation/widgets/worker_withdrawal_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await AppThemeService.init(prefs: prefs);
    await AppLanguageService.init(prefs: prefs);
    await SoundHapticPreferences.instance.init(prefs: prefs);
    await LocalCacheService.instance.init(prefs: prefs);
    await SecureStorageService().init(prefs: prefs);
    AppThemeService.setThemeMode(ThemeMode.light);
    AppLanguageService.setLanguage('en');
    NetworkConnectivityService.instance.setManualState(
      NetworkQualityState.online,
    );
  });

  Widget wrapScreen(
    Widget screen,
    ThemeMode mode, {
    Size size = const Size(320, 568),
    double textScale = 2.0,
  }) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: mode,
      onGenerateRoute: AppRouter.onGenerateRoute,
      home: MediaQuery(
        data: MediaQueryData(
          size: size,
          textScaler: TextScaler.linear(textScale),
        ),
        child: screen,
      ),
    );
  }

  group('Stage E — Security, Offline Safety & Financial Integrity', () {
    test('RouteGuards handles uninitialized Firebase/Supabase safely', () async {
      final isAdmin = await RouteGuards.hasAnyAdminRole();
      expect(isAdmin, isFalse);
    });

    test('AdminRemoteDataSource returns honest zero metrics when offline', () async {
      final ds = AdminRemoteDataSource();
      final metrics = await ds.getPlatformMetrics();
      expect(metrics['totalUsers'], 0);
      expect(metrics['activeRequests'], 0);
      expect(metrics['totalVolume'], 0.0);
      expect(metrics['isLive'], isFalse);
      expect(await ds.getPendingVerifications(), isEmpty);
      expect(await ds.getOpenDisputes(), isEmpty);
    });

    test('ChatRemoteDataSource supports offline optimistic streaming cleanly', () async {
      final ds = ChatRemoteDataSource();
      final conv = await ds.getOrCreateConversation(
        currentUserId: 'u_1',
        otherUserId: 'u_2',
      );
      expect(conv.conversationId, isNotEmpty);

      final received = <List<ChatMessageModel>>[];
      final sub = ds.getMessagesStream(conv.conversationId).listen(received.add);
      await ds.sendMessage(
        conversationId: conv.conversationId,
        senderId: 'u_1',
        text: 'Confirmed site arrival at 10 AM.',
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await sub.cancel();

      expect(received, isNotEmpty);
      expect(
        received.last.any((m) => m.messageText.contains('Confirmed site arrival')),
        isTrue,
      );
    });

    test('ReviewRemoteDataSource handles uninitialized Supabase safely', () async {
      final ds = ReviewRemoteDataSource();
      expect(await ds.getWorkerReviews('wp_test'), isEmpty);
      expect(await ds.getWorkerReputation('wp_test'), isNull);
      expect(
        () => ds.submitReview(
          workerProfileId: 'wp_test',
          clientId: 'c_test',
          rating: 5,
        ),
        throwsException,
      );
    });

    test('PaymentController computes transparent 15% platform fee split', () {
      final controller = PaymentController();
      expect(controller.platformFeePercentage, AppConfig.skaviaPlatformFeePercent);
      final split = controller.calculateFeeSplit(2000.0);
      expect(split['totalAmount'], 2000.0);
      expect(split['skaviaFee'], 300.0);
      expect(split['workerAmount'], 1700.0);
    });
  });

  group('Stage E — Interactive Security & Persistence Controls', () {
    testWidgets('WorkerJobOtpSheet rejects incorrect 4-digit OTP and accepts exact OTP', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      bool verified = false;
      await tester.pumpWidget(
        wrapScreen(
          Scaffold(
            body: Builder(
              builder: (context) => WorkerJobOtpSheet(
                expectedOtp: '4829',
                onOtpVerified: () => verified = true,
              ),
            ),
          ),
          ThemeMode.light,
          size: const Size(360, 640),
          textScale: 1.0,
        ),
      );

      // Enter wrong 4-digit OTP
      await tester.enterText(find.byType(TextField), '1234');
      await tester.ensureVisible(find.text('Verify & Release Earnings ৳'));
      await tester.tap(find.text('Verify & Release Earnings ৳'));
      await tester.pumpAndSettle();

      expect(verified, isFalse);
      expect(find.textContaining('Invalid'), findsAtLeastNWidgets(1));

      // Enter exact OTP
      await tester.enterText(find.byType(TextField), '4829');
      await tester.ensureVisible(find.text('Verify & Release Earnings ৳'));
      await tester.tap(find.text('Verify & Release Earnings ৳'));
      await tester.pumpAndSettle();

      expect(verified, isTrue);
    });

    testWidgets('WorkerWithdrawalSheet blocks over-balance withdrawals cleanly', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      double? submittedAmount;
      String? submittedMethod;

      await tester.pumpWidget(
        wrapScreen(
          Scaffold(
            body: WorkerWithdrawalSheet(
              availableBalance: 2500.0,
              onConfirmWithdrawal: (amt, method) {
                submittedAmount = amt;
                submittedMethod = method;
              },
            ),
          ),
          ThemeMode.dark,
          size: const Size(360, 640),
          textScale: 1.0,
        ),
      );

      await tester.enterText(find.byType(TextField), '5000');
      await tester.ensureVisible(find.text('Confirm Withdrawal'));
      await tester.tap(find.text('Confirm Withdrawal'));
      await tester.pumpAndSettle();

      expect(submittedAmount, isNull);
      expect(find.textContaining('exceed available balance'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '1500');
      await tester.ensureVisible(find.text('Confirm Withdrawal'));
      await tester.tap(find.text('Confirm Withdrawal'));
      await tester.pumpAndSettle();

      expect(submittedAmount, 1500.0);
      expect(submittedMethod, 'bKash');
    });

    testWidgets('TeamDiscoveryScreen filters teams & persists bookmarks', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        wrapScreen(
          const TeamDiscoveryScreen(),
          ThemeMode.light,
          size: const Size(360, 800),
          textScale: 1.0,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('TechCraft Team'), findsOneWidget);
      expect(find.text('Dream Builders'), findsOneWidget);

      // Tap Skills filter to cycle from All Skills -> Flutter
      await tester.tap(find.text('Skills'));
      await tester.pumpAndSettle();

      expect(find.text('TechCraft Team'), findsOneWidget);
      expect(find.text('Dream Builders'), findsNothing);

      // Toggle bookmark on first team and verify LocalCacheService persistence
      await tester.tap(find.byIcon(Icons.bookmark_border_rounded).first);
      await tester.pumpAndSettle();

      final cached = LocalCacheService.instance.get('team_discovery_saved_ids');
      expect(cached, isA<List>());
      expect((cached as List), contains('team_01'));
    });

    testWidgets('AdminDashboardScreen displays honest zero counts when offline', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        wrapScreen(const AdminDashboardScreen(), ThemeMode.dark),
      );
      await tester.pumpAndSettle();

      expect(find.text('128'), findsNothing);
      expect(find.text('36'), findsNothing);
      expect(find.textContaining('285'), findsNothing);
      expect(find.text('0'), findsAtLeastNWidgets(2));
    });
  });

  group('Stage E — Light/Dark @ 320x568 + 2.0x TextScale Zero-Overflow Audit', () {
    Future<void> verifyScreenNoOverflow(
      WidgetTester tester,
      Widget widget,
      ThemeMode mode,
    ) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(wrapScreen(widget, mode));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      final exception = tester.takeException();
      expect(exception, isNull, reason: 'Unexpected overflow/error on ${widget.runtimeType} ($mode)');
    }

    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('Worker screens & key widgets render cleanly ($mode, 320dp 2.0x)', (
        tester,
      ) async {
        await verifyScreenNoOverflow(
          tester,
          Scaffold(
            body: SingleChildScrollView(
              child: WorkerDashboardView(
                workerEarnings: 42500.0,
                workerCompletedJobs: 18,
                workerRating: 4.9,
                isWorkerAvailable: true,
                locationZone: 'Gulshan & Banani, Dhaka',
                liveJobRequests: const [],
                onToggleAvailability: (_) {},
              ),
            ),
          ),
          mode,
        );
        await verifyScreenNoOverflow(tester, const IncomingRequestsScreen(), mode);
        await verifyScreenNoOverflow(
          tester,
          Scaffold(
            body: SingleChildScrollView(
              child: IncomingRequestCard(
                request: const {
                  'service_request_id': 'req_01',
                  'title': 'Emergency Main Circuit Breaker Replacement',
                  'agreed_price': 2500,
                  'location_zone': 'Dhanmondi 27',
                  'client_name': 'Sadia Rahman',
                },
                onAccept: () {},
                onDecline: () {},
              ),
            ),
          ),
          mode,
        );
        await verifyScreenNoOverflow(
          tester,
          const ActiveJobScreen(
            requestId: 'sr-demo-1234',
            jobTitle: 'Industrial HVAC Filter & Coolant Tune-up',
            clientName: 'Delta Apparels Ltd',
            location: 'Tejgaon Industrial Area, Dhaka',
            agreedPrice: 4500.0,
            expectedOtp: '4829',
            scheduledTime: 'Today, 03:30 PM',
            serviceNotes: 'Bring manifold gauge set and refrigerant cylinder.',
          ),
          mode,
        );
        await verifyScreenNoOverflow(tester, const WorkerEarningsScreen(), mode);
        await verifyScreenNoOverflow(tester, const AvailabilityCalendarScreen(), mode);
        await verifyScreenNoOverflow(tester, const PortfolioManagementScreen(), mode);
        await verifyScreenNoOverflow(tester, const WorkerEditProfileScreen(), mode);
        await verifyScreenNoOverflow(tester, const WorkerProfileDetailScreen(), mode);
      });

      testWidgets('Team Project screens render cleanly ($mode, 320dp 2.0x)', (
        tester,
      ) async {
        await verifyScreenNoOverflow(
          tester,
          const ProjectDashboardScreen(projectId: 'proj_001'),
          mode,
        );
        await verifyScreenNoOverflow(tester, const TeamDiscoveryScreen(), mode);
        await verifyScreenNoOverflow(tester, const ProjectShowcaseScreen(), mode);
        await verifyScreenNoOverflow(
          tester,
          const TaskBoardScreen(projectId: 'proj_001'),
          mode,
        );
        await verifyScreenNoOverflow(
          tester,
          const TeamRosterScreen(projectId: 'proj_001'),
          mode,
        );
        await verifyScreenNoOverflow(
          tester,
          const AssignTaskScreen(projectId: 'proj_001'),
          mode,
        );
      });

      testWidgets('Chat screens & tiles render cleanly ($mode, 320dp 2.0x)', (
        tester,
      ) async {
        await verifyScreenNoOverflow(tester, const ChatListScreen(), mode);
        await verifyScreenNoOverflow(
          tester,
          const ChatRoomScreen(
            conversationId: 'conv_demo_1',
            otherParticipantName: 'Engr. Tariqul Islam (HVAC Lead)',
            otherParticipantId: 'u_worker_1',
          ),
          mode,
        );
        await verifyScreenNoOverflow(
          tester,
          Scaffold(
            body: ConversationTile(
              conversation: ConversationModel(
                conversationId: 'conv_demo_1',
                participantOne: 'u_client',
                participantTwo: 'u_worker_1',
                otherParticipantName: 'Rahul Ahmed • Master Electrician',
                lastMessageText: 'Inspection checklist uploaded for your review.',
                unreadCount: 2,
                lastMessageAt: DateTime.now(),
                createdAt: DateTime.now(),
              ),
              currentUserId: 'u_client',
              onReturn: () {},
            ),
          ),
          mode,
        );
      });

      testWidgets('Billing screens render cleanly ($mode, 320dp 2.0x)', (
        tester,
      ) async {
        await verifyScreenNoOverflow(
          tester,
          const SimulatedCheckoutScreen(
            title: '3-Phase Industrial DB Panel Servicing',
            amount: 5500.0,
          ),
          mode,
        );
        await verifyScreenNoOverflow(
          tester,
          InvoiceScreen(
            invoiceNumber: 'INV-2026-0091',
            serviceTitle: '3-Phase Industrial DB Panel Servicing',
            clientName: 'Fazle Rabbi',
            clientPhone: '01711223344',
            specialistName: 'Rahul Ahmed',
            baseAmount: 5500.0,
            platformFee: 825.0,
            totalAmount: 6325.0,
            paymentMethod: 'bKash',
            transactionId: 'TRX-894210',
            paidAt: DateTime(2026, 11, 12),
          ),
          mode,
        );
        await verifyScreenNoOverflow(
          tester,
          PaymentSuccessScreen(
            amount: 6325.0,
            transactionId: 'TRX-894210',
            paymentMethod: 'Cash',
            jobTitle: '3-Phase Industrial DB Panel Servicing',
            specialistName: 'Rahul Ahmed',
            onViewInvoice: () {},
          ),
          mode,
        );
        await verifyScreenNoOverflow(
          tester,
          const TransactionHistoryScreen(),
          mode,
        );
      });

      testWidgets('Review & Complaint screens render cleanly ($mode, 320dp 2.0x)', (
        tester,
      ) async {
        await verifyScreenNoOverflow(
          tester,
          const SubmitReviewScreen(
            workerProfileId: 'wp_demo_1',
            workerName: 'Kamal Hossain',
          ),
          mode,
        );
        await verifyScreenNoOverflow(tester, const SubmitComplaintScreen(), mode);
        await verifyScreenNoOverflow(tester, const WorkerReputationScreen(), mode);
        await verifyScreenNoOverflow(
          tester,
          Scaffold(
            body: SingleChildScrollView(
              child: ReviewItemCard(
                review: ReviewModel(
                  reviewId: 'rev_1',
                  workerProfileId: 'wp_1',
                  clientId: 'c_1',
                  clientName: 'Sadia Chowdhury (Banani Zone)',
                  rating: 5,
                  comment: 'Completed wiring neatly and tested every breaker.',
                  createdAt: DateTime(2026, 11, 10),
                ),
                dateFormat: DateFormat('dd MMM yyyy'),
              ),
            ),
          ),
          mode,
        );
      });

      testWidgets('Admin screens render cleanly ($mode, 320dp 2.0x)', (
        tester,
      ) async {
        await verifyScreenNoOverflow(tester, const AdminDashboardScreen(), mode);
        await verifyScreenNoOverflow(tester, const VerificationQueueScreen(), mode);
        await verifyScreenNoOverflow(tester, const DisputeResolutionScreen(), mode);
        await verifyScreenNoOverflow(tester, const TeamAssemblyScreen(), mode);
      });
    }
  });
}
