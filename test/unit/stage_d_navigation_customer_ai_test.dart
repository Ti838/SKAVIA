import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skavia/app/config/app_config.dart';
import 'package:skavia/app/router/app_router.dart';
import 'package:skavia/app/router/app_routes.dart';
import 'package:skavia/app/theme/app_theme.dart';
import 'package:skavia/core/network/network_connectivity_service.dart';
import 'package:skavia/core/services/app_language_service.dart';
import 'package:skavia/core/services/app_theme_service.dart';
import 'package:skavia/core/services/skavia_ai_service.dart';
import 'package:skavia/core/services/sound_haptic_preferences.dart';
import 'package:skavia/core/storage/local_cache_service.dart';
import 'package:skavia/core/storage/secure_storage_service.dart';
import 'package:skavia/core/utils/category_resolver.dart';
import 'package:skavia/core/utils/formatters.dart';
import 'package:skavia/core/utils/job_otp_util.dart';
import 'package:skavia/features/ai_assistant/presentation/screens/skavia_ai_screen.dart';
import 'package:skavia/features/customer/data/datasources/customer_remote_datasource.dart';
import 'package:skavia/features/customer/domain/entities/requirement_entity.dart';
import 'package:skavia/features/customer/presentation/screens/booking_confirmation_screen.dart';
import 'package:skavia/features/customer/presentation/screens/booking_timeline_screen.dart';
import 'package:skavia/features/customer/presentation/screens/candidate_matches_screen.dart';
import 'package:skavia/features/customer/presentation/screens/category_catalog_screen.dart';
import 'package:skavia/features/customer/presentation/screens/customer_dashboard_screen.dart';
import 'package:skavia/features/customer/presentation/screens/live_job_feed_screen.dart';
import 'package:skavia/features/customer/presentation/screens/post_requirement_screen.dart';
import 'package:skavia/features/customer/presentation/widgets/booking_payment_details_card.dart';
import 'package:skavia/features/customer/presentation/widgets/candidate_match_card.dart';
import 'package:skavia/features/customer/presentation/widgets/job_otp_dialog.dart';
import 'package:skavia/features/customer/presentation/widgets/live_job_bid_sheet.dart';
import 'package:skavia/features/customer/presentation/widgets/match_score_badge.dart';
import 'package:skavia/features/customer/presentation/widgets/post_comments_sheet.dart';
import 'package:skavia/features/customer/presentation/widgets/post_composer_sheet.dart';
import 'package:skavia/features/customer/presentation/widgets/post_requirement_success_dialog.dart';
import 'package:skavia/features/matching/domain/entities/match_result_entity.dart';
import 'package:skavia/features/navigation/presentation/screens/main_scaffold_screen.dart';
import 'package:skavia/features/navigation/presentation/widgets/dashboard_bottom_nav_bar.dart';
import 'package:skavia/features/notifications/data/models/app_notification_model.dart';
import 'package:skavia/features/notifications/presentation/controllers/notification_center_controller.dart';
import 'package:skavia/features/notifications/presentation/screens/notification_center_screen.dart';

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
    NotificationCenterController.instance.clearSession();
  });

  group('Stage D — Unit Tests: Resolvers, OTP, Offline Safety & AI', () {
    test('CategoryResolver normalizes types, urgencies, names & seed UUIDs', () async {
      expect(CategoryResolver.normalizeRequirementType('Simple'), 'Simple');
      expect(CategoryResolver.normalizeRequirementType('Complex'), 'Complex');
      expect(CategoryResolver.normalizeRequirementType('Team Project'), 'Complex');
      expect(CategoryResolver.normalizeRequirementType('turnkey'), 'Complex');
      expect(CategoryResolver.normalizeRequirementType(null), 'Simple');

      expect(CategoryResolver.normalizeUrgency('low'), 'Low');
      expect(CategoryResolver.normalizeUrgency('Standard'), 'Medium');
      expect(CategoryResolver.normalizeUrgency('High'), 'High');
      expect(CategoryResolver.normalizeUrgency('Urgent'), 'High');
      expect(CategoryResolver.normalizeUrgency('emergency'), 'Emergency');

      expect(
        CategoryResolver.displayName('a1111111-1111-4111-8111-111111111111'),
        'Electrical Solutions',
      );
      expect(
        CategoryResolver.displayName('cat_ac_hvac'),
        'HVAC & Cooling Systems',
      );

      expect(
        await CategoryResolver.resolveCategoryUuid(null, 'cat_electrical'),
        'a1111111-1111-4111-8111-111111111111',
      );
      expect(
        await CategoryResolver.resolveCategoryUuid(null, 'cat_plumbing'),
        'a3333333-3333-4333-8333-333333333333',
      );
      expect(
        await CategoryResolver.resolveCategoryUuid(null, 'cat_civil_carpentry'),
        'a6666666-6666-4666-8666-666666666666',
      );
      expect(
        await CategoryResolver.resolveCategoryUuid(null, 'cat_automotive'),
        isNull,
      );
    });

    test('JobOtpUtil generates 4-digit OTP and extracts notes & fallbacks', () {
      for (var i = 0; i < 15; i++) {
        final otp = JobOtpUtil.generateOtp();
        final parsed = int.tryParse(otp);
        expect(otp.length, 4);
        expect(parsed, isNotNull);
        expect(parsed!, inInclusiveRange(1000, 9999));
      }

      expect(
        JobOtpUtil.extractOtp('OTP: 7391 | Method: bKash'),
        '7391',
      );
      expect(
        JobOtpUtil.extractOtp('No code here', fallbackRequestId: 'sr-982341'),
        '2341',
      );
      expect(
        JobOtpUtil.extractOtp(null, fallbackRequestId: 'ab_xy9z'),
        'XY9Z',
      );
    });

    test('CustomerRemoteDataSource enforces online requirement & safe empty lists offline', () async {
      final ds = CustomerRemoteDataSource(client: null);
      expect(await ds.getCustomerRequirements('user_01'), isEmpty);
      expect(await ds.getActiveBookings('user_01'), isEmpty);

      await expectLater(
        () => ds.createRequirement(
          RequirementEntity(
            requirementId: '',
            clientId: 'user_01',
            title: 'AC Servicing',
            description: 'Jet wash & gas refill',
            categoryId: 'cat_ac_hvac',
            location: 'Gulshan, Dhaka',
            budget: 2500,
            createdAt: DateTime(2026, 11, 12),
          ),
        ),
        throwsStateError,
      );
    });

    test('SkaviaAiService.diagnoseRequirement classifies AC, Electrical, Plumbing & Carpentry', () async {
      final ai = SkaviaAiService();

      final acDiag = await ai.diagnoseRequirement(
        'Urgent inverter AC cooling issue and freon gas check',
      );
      expect(acDiag, isNotNull);
      expect(acDiag!['category_id'], 'cat_ac_hvac');
      expect((acDiag['budget_estimate'] as num).toDouble(), greaterThan(0));
      expect(acDiag['urgency'], 'Emergency');

      final plumbingDiag = await ai.diagnoseRequirement(
        'Bathroom water pipe leak repair needed',
      );
      expect(plumbingDiag!['category_id'], 'cat_plumbing');

      final carpentryDiag = await ai.diagnoseRequirement(
        'Wooden door lock alignment and furniture polish',
      );
      expect(carpentryDiag!['category_id'], 'cat_civil_carpentry');

      final elecDiag = await ai.diagnoseRequirement(
        'Main distribution breaker switchboard tripping',
      );
      expect(elecDiag!['category_id'], 'cat_electrical');
      expect(elecDiag['technical_summary'], isNotEmpty);
    });

    test('LocalCacheService persists liked/saved ID sets and feed comments', () {
      final cache = LocalCacheService.instance;
      cache.put('skavia_feed_liked_ids', ['job_1', 'job_2']);
      cache.put('skavia_feed_saved_ids', ['job_2']);
      cache.put('skavia_feed_comments_job_1', [
        {'id': 'c1', 'author': 'Tariq', 'body': 'Available at 4pm?', 'time': 'Just now'},
      ]);

      expect(List<String>.from(cache.get('skavia_feed_liked_ids') as List), ['job_1', 'job_2']);
      expect(List<String>.from(cache.get('skavia_feed_saved_ids') as List), ['job_2']);
      final comments = cache.get('skavia_feed_comments_job_1') as List;
      expect(comments.length, 1);
      expect((comments.first as Map)['author'], 'Tariq');
    });
  });

  group('Stage D — Screens & Widgets Light/Dark @ 320dp + 2.0x Text Scale', () {
    Widget wrapScreen(Widget screen, ThemeMode mode) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: mode,
        onGenerateRoute: AppRouter.onGenerateRoute,
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 568),
            textScaler: TextScaler.linear(2.0),
          ),
          child: screen,
        ),
      );
    }

    const sampleJob = JobRequirementItem(
      id: 'job_stage_d_01',
      title: 'Split AC Compressor Servicing & Gas Top-Up',
      category: 'HVAC & Cooling Systems',
      categoryId: 'cat_ac_hvac',
      description: 'Looking for verified HVAC specialist in Banani Road 11.',
      location: 'Banani, Dhaka',
      budgetMin: 2000,
      budgetMax: 3500,
      urgency: 'High',
      timeAgo: '15m ago',
      clientName: 'Sadia Chowdhury',
    );

    final sampleCandidate = MatchResultEntity(
      matchId: 'match_1',
      requirementId: 'req_stage_d_01',
      workerProfileId: 'wp_stage_d_01',
      matchScore: 94.0,
      rankPosition: 1,
      skillScore: 96.0,
      distanceScore: 92.0,
      ratingScore: 98.0,
      rateScore: 90.0,
      workerName: 'Kamrul Hasan',
      tradeTitle: 'Senior HVAC Specialist',
      location: 'Banani, Dhaka',
      hourlyRate: 1200,
      rating: 4.9,
      completedJobs: 47,
      isVerified: true,
    );

    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('MainScaffoldScreen switches tabs cleanly ($mode, 320dp 2.0x)', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(wrapScreen(const MainScaffoldScreen(), mode));
        await tester.pump(const Duration(milliseconds: 150));
        expect(find.byType(MainScaffoldScreen), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.tap(
          find.descendant(
            of: find.byType(DashboardBottomNavBar),
            matching: find.text('Services'),
          ),
        );
        await tester.pump(const Duration(milliseconds: 200));
        expect(find.byType(CategoryCatalogScreen), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.tap(
          find.descendant(
            of: find.byType(DashboardBottomNavBar),
            matching: find.text('Feed'),
          ),
        );
        await tester.pump(const Duration(milliseconds: 200));
        expect(find.byType(LiveJobFeedScreen), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(const SizedBox());
        await tester.pump();
      });

      testWidgets('CustomerDashboardScreen, CategoryCatalogScreen & PostRequirementScreen render ($mode, 320dp 2.0x)', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          wrapScreen(const CustomerDashboardScreen(), mode),
        );
        await tester.pump(const Duration(milliseconds: 150));
        expect(find.byType(CustomerDashboardScreen), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Dispose CustomerDashboardScreen immediately so its 1500ms permission timer cancels cleanly.
        await tester.pumpWidget(const SizedBox());
        await tester.pump();

        await tester.pumpWidget(wrapScreen(const CategoryCatalogScreen(), mode));
        await tester.pump(const Duration(milliseconds: 150));
        expect(find.byType(CategoryCatalogScreen), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(wrapScreen(const PostRequirementScreen(), mode));
        await tester.pump(const Duration(milliseconds: 150));
        expect(find.text('Request a Service'), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(
          wrapScreen(const LiveJobFeedScreen(isTab: false), mode),
        );
        await tester.pump(const Duration(milliseconds: 150));
        expect(find.byType(LiveJobFeedScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('CandidateMatchesScreen empty state, CandidateMatchCard & MatchScoreBadge render ($mode, 320dp 2.0x)', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          wrapScreen(
            const CandidateMatchesScreen(
              requirementId: 'req_empty_01',
              requirementTitle: 'Emergency Electrical Switchboard Fix',
              requirementZone: 'Uttara Sector 4, Dhaka',
              budget: 3500,
            ),
            mode,
          ),
        );
        await tester.pump(const Duration(milliseconds: 200));
        expect(
          find.text('No matched specialists found in this zone'),
          findsOneWidget,
        );
        expect(find.text('Re-evaluate Matches'), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(
          wrapScreen(
            Scaffold(
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    CandidateMatchCard(
                      candidate: sampleCandidate,
                      requirementTitle: 'AC Gas Refill',
                      requirementZone: 'Banani, Dhaka',
                    ),
                    const MatchScoreBadge(score: 94),
                    const MatchScoreBadge(score: 0.78),
                    const MatchScoreBadge(score: 65),
                    const MatchScoreBadge(score: 45),
                  ],
                ),
              ),
            ),
            mode,
          ),
        );
        await tester.pump(const Duration(milliseconds: 150));
        expect(find.text('Kamrul Hasan'), findsOneWidget);
        expect(find.text('Scorecard'), findsOneWidget);
        expect(find.text('Book Specialist'), findsOneWidget);
        expect(find.text('94% Match'), findsWidgets);
        expect(tester.takeException(), isNull);
      });

      testWidgets('BookingConfirmationScreen uses 15% fee & BDT currency and BookingTimelineScreen advances ($mode, 320dp 2.0x)', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        const baseRate = 2000.0;
        const expectedFee = baseRate * AppConfig.skaviaPlatformFeePercent;
        const expectedTotal = baseRate + expectedFee;

        await tester.pumpWidget(
          wrapScreen(
            const BookingConfirmationScreen(
              workerProfileId: 'wp_stage_d_01',
              workerName: 'Kamrul Hasan',
              tradeTitle: 'HVAC Specialist',
              hourlyRate: baseRate,
              jobTitle: 'AC Jet Wash & Servicing',
              location: 'Gulshan 2, Dhaka',
            ),
            mode,
          ),
        );
        await tester.pump(const Duration(milliseconds: 150));
        expect(find.byType(BookingPaymentDetailsCard), findsOneWidget);
        expect(find.text('SKAVIA Management Fee (15%)'), findsOneWidget);
        expect(
          find.text(Formatters.formatCurrency(expectedTotal)),
          findsWidgets,
        );
        expect(find.textContaining(r'$'), findsNothing);
        expect(find.text('Cash on Completion'), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(
          wrapScreen(
            const BookingTimelineScreen(
              requestId: 'sr_stage_d_01',
              jobTitle: 'AC Jet Wash & Servicing',
              workerName: 'Kamrul Hasan',
              tradeTitle: 'HVAC Specialist',
              scheduledSlot: 'Today, 4:00 PM',
              totalPrice: expectedTotal,
              jobOtp: '7391',
              address: 'Gulshan 2, Dhaka',
            ),
            mode,
          ),
        );
        await tester.pump(const Duration(milliseconds: 150));
        expect(find.text('7391'), findsOneWidget);

        // Initial step is 1 (Accepted) -> advance to 2, then 3
        final updateBtnFinder = find.text('Update Service Progress');
        await tester.scrollUntilVisible(
          updateBtnFinder,
          140,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(updateBtnFinder);
        await tester.pump(const Duration(milliseconds: 100));
        await tester.tap(updateBtnFinder);
        await tester.pump(const Duration(milliseconds: 150));

        expect(find.text('Rate & Review Specialist'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('NotificationCenterScreen filter pills & Mark all as read work ($mode, 320dp 2.0x)', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        NotificationCenterController.instance.addNotification(
          AppNotificationModel(
            id: 'notif_d_1',
            userId: 'user_d_1',
            dedupKey: 'booking_d_1',
            title: 'Specialist Dispatched',
            body: 'Kamrul Hasan is on the way for AC Servicing.',
            category: 'booking',
            isRead: false,
            createdAt: DateTime.now(),
          ),
        );
        NotificationCenterController.instance.addNotification(
          AppNotificationModel(
            id: 'notif_d_2',
            userId: 'user_d_1',
            dedupKey: 'profile_d_2',
            title: 'Profile 100% Verified',
            body: 'Your account meets corporate verification requirements.',
            category: 'profile',
            isRead: true,
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          ),
        );

        await tester.pumpWidget(
          wrapScreen(const NotificationCenterScreen(), mode),
        );
        await tester.pump(const Duration(milliseconds: 150));
        expect(find.text('Unread (1)'), findsOneWidget);
        expect(find.byTooltip('Mark all as read'), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.tap(find.byTooltip('Mark all as read'));
        await tester.pump(const Duration(milliseconds: 150));
        expect(NotificationCenterController.instance.unreadCount, 0);
        expect(find.byTooltip('Mark all as read'), findsNothing);
        expect(tester.takeException(), isNull);
      });

      testWidgets('SkaviaAiScreen renders Chat, Analyzing & Results modes ($mode, 320dp 2.0x)', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          wrapScreen(
            const SkaviaAiScreen(initialMode: AiScreenMode.chat),
            mode,
          ),
        );
        await tester.pump(const Duration(milliseconds: 150));
        expect(find.text('SKAVIA AI'), findsWidgets);
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(
          wrapScreen(
            const SkaviaAiScreen(
              initialMode: AiScreenMode.analyzing,
            ),
            mode,
          ),
        );
        await tester.pump(const Duration(milliseconds: 150));
        expect(find.text('Analyzing your requirements...'), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(
          wrapScreen(
            const SkaviaAiScreen(
              initialMode: AiScreenMode.results,
              analysisData: {
                'suggested_title': 'Commercial HVAC Fit-Out',
                'technical_summary': 'Multi-zone split AC ductwork installation.',
                'skills': ['Inverter AC', 'Copper Piping'],
              },
            ),
            mode,
          ),
        );
        await tester.pump(const Duration(milliseconds: 150));
        expect(find.text('Recommended Team'), findsOneWidget);
        expect(find.text('Inverter AC'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('Stage D sheets & dialogs render without overflow ($mode, 320dp 2.0x)', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          wrapScreen(const Scaffold(body: PostComposerSheet()), mode),
        );
        await tester.pump(const Duration(milliseconds: 150));
        expect(find.text('Create Opportunity or Post'), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(
          wrapScreen(
            const Scaffold(body: LiveJobBidSheet(job: sampleJob)),
            mode,
          ),
        );
        await tester.pump(const Duration(milliseconds: 150));
        expect(find.text('Submit Direct Proposal'), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(
          wrapScreen(
            const Scaffold(body: PostCommentsSheet(job: sampleJob)),
            mode,
          ),
        );
        await tester.pump(const Duration(milliseconds: 150));
        expect(find.text('Community Discussion'), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(
          wrapScreen(
            const PostRequirementSuccessDialog(
              requirementId: 'req_d_dialog',
              title: 'AC Gas Top-Up',
              budget: 2500,
              selectedLocation: 'Banani, Dhaka',
              requirementType: 'Simple',
            ),
            mode,
          ),
        );
        await tester.pump(const Duration(milliseconds: 150));
        expect(find.text('Job Posted Successfully'), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(
          wrapScreen(
            const JobOtpDialog(bookingId: 'sr_d_01', otpCode: '8429'),
            mode,
          ),
        );
        await tester.pump(const Duration(milliseconds: 150));
        expect(find.text('Job Security OTP'), findsOneWidget);
        expect(find.text('8429'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('Stage D — Route Resolution Integrity', () {
    test('AppRouter passes requirementId & BDT default rate to BookingConfirmation', () {
      for (final routeName in [
        AppRoutes.appShell,
        AppRoutes.categoryCatalog,
        AppRoutes.postRequirement,
        AppRoutes.candidateMatches,
        AppRoutes.liveJobFeed,
        AppRoutes.bookingConfirmation,
        AppRoutes.skaviaAi,
        AppRoutes.notificationCenter,
      ]) {
        final route = AppRouter.onGenerateRoute(RouteSettings(name: routeName));
        expect(route, isA<MaterialPageRoute<dynamic>>());
      }
    });
  });
}
