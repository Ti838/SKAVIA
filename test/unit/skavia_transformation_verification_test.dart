import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:skavia/app/theme/app_theme.dart';
import 'package:skavia/app/theme/app_typography.dart';
import 'package:skavia/core/extensions/context_extensions.dart';
import 'package:skavia/core/services/app_language_service.dart';
import 'package:skavia/core/utils/formatters.dart';
import 'package:skavia/features/ai_assistant/presentation/widgets/ai_results_view.dart';
import 'package:skavia/features/authentication/presentation/controllers/auth_controller.dart';
import 'package:skavia/features/billing/presentation/screens/invoice_screen.dart';
import 'package:skavia/features/chat/presentation/screens/chat_list_screen.dart';
import 'package:skavia/features/customer/data/models/service_model.dart';
import 'package:skavia/features/customer/presentation/screens/category_catalog_screen.dart';
import 'package:skavia/features/customer/presentation/screens/live_job_feed_screen.dart';
import 'package:skavia/features/customer/presentation/widgets/business_dashboard_view.dart';
import 'package:skavia/features/customer/presentation/widgets/catalog_service_card.dart';
import 'package:skavia/features/customer/presentation/widgets/customer_dashboard_view.dart';
import 'package:skavia/features/matching/domain/entities/match_result_entity.dart';
import 'package:skavia/features/navigation/data/repositories/dashboard_repository.dart';
import 'package:skavia/features/navigation/presentation/screens/main_scaffold_screen.dart';
import 'package:skavia/features/navigation/presentation/widgets/dashboard_bottom_nav_bar.dart';
import 'package:skavia/features/navigation/presentation/widgets/dashboard_top_app_bar.dart';
import 'package:skavia/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:skavia/features/profile/data/models/profile_stats_model.dart';
import 'package:skavia/features/profile/data/models/user_profile_model.dart';
import 'package:skavia/features/profile/presentation/controllers/profile_controller.dart';
import 'package:skavia/features/profile/presentation/widgets/unified_profile_view.dart';
import 'package:skavia/features/reviews/data/models/review_model.dart';
import 'package:skavia/features/worker/data/models/worker_profile_model.dart';
import 'package:skavia/features/worker/presentation/widgets/worker_dashboard_view.dart';
import 'package:skavia/l10n/generated/app_localizations.dart';
import 'package:skavia/shared/widgets/skavia_badge.dart';
import 'package:skavia/shared/widgets/skavia_search_field.dart';

class _EmptyProfileRemoteDataSource extends ProfileRemoteDataSource {
  @override
  Future<UserProfileModel> getProfile(
    String userId, {
    String? fallbackEmail,
    String? fallbackName,
    String? fallbackPhone,
    String? fallbackAvatarUrl,
  }) async {
    return UserProfileModel(
      id: userId,
      fullName: 'Timon Biswas',
      email: 'timon@skavia.app',
      phone: '+8801711000000',
    );
  }

  @override
  Future<ProfileStatsModel> getProfileStats(String userId) async {
    return const ProfileStatsModel(
      servicesCount: 0,
      projectsCount: 0,
      ratingAverage: 0.0,
      reviewCount: 0,
    );
  }
}

double _channelLuminance(double c) {
  return c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
}

double _relativeLuminance(Color color) {
  return 0.2126 * _channelLuminance(color.r) +
      0.7152 * _channelLuminance(color.g) +
      0.0722 * _channelLuminance(color.b);
}

double _contrastRatio(Color a, Color b) {
  final l1 = _relativeLuminance(a);
  final l2 = _relativeLuminance(b);
  final lighter = math.max(l1, l2);
  final darker = math.min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

Widget _wrap({
  required Widget child,
  ThemeMode mode = ThemeMode.light,
  double textScale = 1.0,
  Locale locale = const Locale('en'),
}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    theme: AppTheme.getTheme(
      brightness: Brightness.light,
      languageCode: locale.languageCode,
    ),
    darkTheme: AppTheme.getTheme(
      brightness: Brightness.dark,
      languageCode: locale.languageCode,
    ),
    themeMode: mode,
    builder: (context, widget) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(textScale),
      ),
      child: widget!,
    ),
    home: child,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    AppLanguageService.setLanguage('en');
  });

  group('Phase 4 — WCAG 2.1 Contrast & Token Integrity', () {
    testWidgets('Light theme color tokens meet WCAG AA/AAA contrast ratios', (
      tester,
    ) async {
      late ColorScheme cs;
      late SkaviaSurfaceTokens t;
      await tester.pumpWidget(
        _wrap(
          mode: ThemeMode.light,
          child: Builder(
            builder: (ctx) {
              cs = Theme.of(ctx).colorScheme;
              t = Theme.of(ctx).extension<SkaviaSurfaceTokens>()!;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      await tester.pump();

      expect(_contrastRatio(cs.onPrimary, cs.primary), greaterThanOrEqualTo(4.5));
      expect(_contrastRatio(cs.onSurface, cs.surface), greaterThanOrEqualTo(7.0));
      expect(_contrastRatio(t.secondaryText, t.cardBg), greaterThanOrEqualTo(4.5));
      expect(_contrastRatio(t.mutedText, t.cardBg), greaterThanOrEqualTo(4.5));
      expect(_contrastRatio(t.mutedText, t.subtleCardBg), greaterThanOrEqualTo(4.5));
      expect(_contrastRatio(t.interactiveBorder, t.cardBg), greaterThanOrEqualTo(3.0));
      expect(_contrastRatio(t.violetAccent, t.cardBg), greaterThanOrEqualTo(4.5));
      expect(_contrastRatio(t.tealAccent, t.cardBg), greaterThanOrEqualTo(4.5));
      expect(_contrastRatio(t.onSuccessBg, t.successBg), greaterThanOrEqualTo(4.5));
      expect(_contrastRatio(t.onWarningBg, t.warningBg), greaterThanOrEqualTo(4.5));
      expect(_contrastRatio(t.onErrorBg, t.errorBg), greaterThanOrEqualTo(4.5));
      expect(_contrastRatio(t.onInfoBg, t.infoBg), greaterThanOrEqualTo(4.5));
    });

    testWidgets('Dark theme color tokens meet WCAG AA/AAA contrast ratios', (
      tester,
    ) async {
      late ColorScheme cs;
      late SkaviaSurfaceTokens t;
      await tester.pumpWidget(
        _wrap(
          mode: ThemeMode.dark,
          child: Builder(
            builder: (ctx) {
              cs = Theme.of(ctx).colorScheme;
              t = Theme.of(ctx).extension<SkaviaSurfaceTokens>()!;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      await tester.pump();

      expect(_contrastRatio(cs.onPrimary, cs.primary), greaterThanOrEqualTo(4.5));
      expect(_contrastRatio(cs.onSurface, cs.surface), greaterThanOrEqualTo(7.0));
      expect(_contrastRatio(t.secondaryText, t.cardBg), greaterThanOrEqualTo(4.5));
      expect(_contrastRatio(t.mutedText, t.cardBg), greaterThanOrEqualTo(4.5));
      expect(_contrastRatio(t.interactiveBorder, t.cardBg), greaterThanOrEqualTo(3.0));
      expect(_contrastRatio(t.violetAccent, t.cardBg), greaterThanOrEqualTo(4.5));
      expect(_contrastRatio(t.tealAccent, t.cardBg), greaterThanOrEqualTo(4.5));
      expect(_contrastRatio(t.onSuccessBg, t.successBg), greaterThanOrEqualTo(4.5));
      expect(_contrastRatio(t.onWarningBg, t.warningBg), greaterThanOrEqualTo(4.5));
      expect(_contrastRatio(t.onErrorBg, t.errorBg), greaterThanOrEqualTo(4.5));
      expect(_contrastRatio(t.onInfoBg, t.infoBg), greaterThanOrEqualTo(4.5));
    });
  });

  group('Phase 6 — Strict Real-Data Integrity Enforcement', () {
    test('Domain models never fabricate 5.0 ratings, rates, or verified status', () {
      const emptyStats = ProfileStatsModel(servicesCount: 0, projectsCount: 0);
      expect(emptyStats.ratingAverage, 0.0);
      expect(emptyStats.reviewCount, 0);
      expect(emptyStats.hasVerifiedRating, isFalse);

      final emptyRep = ReputationModel.fromJson(const {});
      expect(emptyRep.overallScore, 0.0);
      expect(emptyRep.totalRatings, 0);
      expect(emptyRep.badgeLevel, 'New Specialist');

      final emptyMatch = MatchResultEntity.fromMap(const {});
      expect(emptyMatch.rating, 0.0);
      expect(emptyMatch.completedJobs, 0);
      expect(emptyMatch.isVerified, isFalse);
      expect(emptyMatch.hourlyRate, 0.0);

      final emptyWorker = WorkerProfileModel.fromJson(const {});
      expect(emptyWorker.rating, 0.0);
      expect(emptyWorker.hourlyRate, 0.0);
      expect(emptyWorker.isVerified, isFalse);
      expect(emptyWorker.isAvailable, isFalse);
    });

    testWidgets('UnifiedProfileView renders dash instead of 5.0 when 0 reviews exist and hides worker badges for customer', (
      tester,
    ) async {
      final profileController = ProfileController(
        dataSource: _EmptyProfileRemoteDataSource(),
      );
      addTearDown(profileController.dispose);
      await profileController.loadProfile('u_test_real');

      final authController = AuthController();
      addTearDown(authController.dispose);

      await tester.pumpWidget(
        _wrap(
          child: Scaffold(
            body: UnifiedProfileView(
              authController: authController,
              profileController: profileController,
              currentMode: AppRoleMode.customer,
              onAvatarPick: () {},
              onOpenSettings: () {},
              onOpenServices: () {},
              onOpenProjects: () {},
              onCallHelpline: () {},
              onSwitchRole: () {},
              onLogout: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('5.0'), findsNothing);
      expect(find.text('—'), findsOneWidget);
      expect(find.text('Worker Reputation & Badges'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('CatalogServiceCard hides 0.0 (0) rating and fabricated duration', (
      tester,
    ) async {
      const service = ServiceModel(
        serviceId: 'svc_db_1',
        categoryId: 'cat_elec',
        name: 'Residential Main DB Board Setup',
        description: 'Circuit breaker load balancing and earthing',
        basePrice: 1800,
        ratingAverage: 0.0,
        totalBookings: 0,
      );

      await tester.pumpWidget(
        _wrap(
          child: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: CatalogServiceCard(
                service: service,
                onBook: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('0.0 (0)'), findsNothing);
      expect(find.textContaining('1-2 Hours'), findsNothing);
      expect(find.text('Residential Main DB Board Setup'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('LiveJobFeedScreen shows genuine empty state and has no overlapping FAB', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(child: const LiveJobFeedScreen(isTab: true)),
      );
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.byType(FloatingActionButton), findsNothing);
      expect(find.text('No posts matching your filter'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ChatListScreen hides search when empty and provides discovery CTA', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(child: const ChatListScreen(isTab: true)),
      );
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.byType(SkaviaSearchField), findsNothing);
      expect(find.text('No Conversations Yet'), findsOneWidget);
      expect(find.text('Browse Services'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('AiResultsView shows honest empty state when analysisData is absent', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          child: Scaffold(
            body: AiResultsView(
              requiredSkills: const [],
              recommendedTeam: const [],
              onEditRequest: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('No Analysis Yet'), findsOneWidget);
      expect(find.textContaining('Mobile App for E-Commerce'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('Phase 7 — Responsive & Localization Matrix (320dp, 390dp, 768dp × Light/Dark × EN/BN)', () {
    final viewports = <({String label, Size size, double textScale, ThemeMode mode, String lang})>[
      (label: 'Small 320dp Light 2.0x EN', size: const Size(320, 640), textScale: 2.0, mode: ThemeMode.light, lang: 'en'),
      (label: 'Small 320dp Dark 1.3x BN', size: const Size(320, 640), textScale: 1.3, mode: ThemeMode.dark, lang: 'bn'),
      (label: 'Standard 390dp Light 1.0x EN', size: const Size(390, 844), textScale: 1.0, mode: ThemeMode.light, lang: 'en'),
      (label: 'Tablet 768dp Dark 1.3x EN', size: const Size(768, 1024), textScale: 1.3, mode: ThemeMode.dark, lang: 'en'),
    ];

    for (final vp in viewports) {
      testWidgets('Global Shell, Customer, Business & Worker Homes render cleanly (${vp.label})', (
        tester,
      ) async {
        AppLanguageService.setLanguage(vp.lang);
        tester.view.physicalSize = vp.size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final searchController = TextEditingController();
        addTearDown(searchController.dispose);

        // 1. Global Top Bar + Customer Dashboard + Bottom Nav
        await tester.pumpWidget(
          _wrap(
            mode: vp.mode,
            textScale: vp.textScale,
            locale: Locale(vp.lang, vp.lang == 'bn' ? 'BD' : null),
            child: Scaffold(
              body: Column(
                children: [
                  DashboardTopAppBar(
                    customAvatarUrl: null,
                    userName: 'Timon Biswas',
                    hasUnreadNotifications: true,
                    unreadNotificationCount: 2,
                    currentLocationZone: 'Dhaka',
                    isLocating: false,
                    isGpsVerified: false,
                    currentMode: AppRoleMode.customer,
                    onAvatarTap: () {},
                    onNotificationsTap: () {},
                    onLocationTap: () {},
                    onModeSwitch: (_) {},
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: CustomerDashboardView(
                        searchController: searchController,
                        currentLocationZone: 'Dhaka',
                        userIdentifier: 'Timon Biswas',
                        isEnterpriseMode: false,
                        activeClientBooking: null,
                        onSelectServicesTab: () {},
                        onOpenChat: () {},
                        onViewOtp: () {},
                        onCallHelpline: () {},
                        onQuickBookService: (_, _, _) {},
                        liveRequirements: const [],
                      ),
                    ),
                  ),
                ],
              ),
              bottomNavigationBar: DashboardBottomNavBar(
                currentIndex: 0,
                currentMode: AppRoleMode.customer,
                onTabSelected: (_) {},
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 150));
        if (vp.lang == 'en') {
          expect(find.text('Feed'), findsOneWidget); // Bottom nav only (top bar duplicate removed)
        }
        expect(tester.takeException(), isNull);

        // 2. Business Client / Organization Home View
        await tester.pumpWidget(
          _wrap(
            mode: vp.mode,
            textScale: vp.textScale,
            locale: Locale(vp.lang, vp.lang == 'bn' ? 'BD' : null),
            child: Scaffold(
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: BusinessDashboardView(
                  stats: const DashboardBusinessStats(
                    activeProjectsCount: 0,
                    openRequirementsCount: 0,
                    customerType: 'Business Client',
                  ),
                  currentLocationZone: 'Dhaka',
                  onSelectServicesTab: () {},
                  onOpenProjectsTab: () {},
                ),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull);

        // 3. Worker Home View
        await tester.pumpWidget(
          _wrap(
            mode: vp.mode,
            textScale: vp.textScale,
            locale: Locale(vp.lang, vp.lang == 'bn' ? 'BD' : null),
            child: Scaffold(
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: WorkerDashboardView(
                  workerEarnings: 0.0,
                  workerCompletedJobs: 0,
                  workerRating: 0.0,
                  isWorkerAvailable: false,
                  locationZone: 'Dhaka',
                  liveJobRequests: const [],
                  verificationStatus: 'Unverified',
                  onToggleAvailability: (_) {},
                ),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull);

        // 4. Services Catalog + Invoice + Shared Badges
        await tester.pumpWidget(
          _wrap(
            mode: vp.mode,
            textScale: vp.textScale,
            locale: Locale(vp.lang, vp.lang == 'bn' ? 'BD' : null),
            child: const CategoryCatalogScreen(isTab: true),
          ),
        );
        await tester.pump(const Duration(milliseconds: 150));
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(
          _wrap(
            mode: vp.mode,
            textScale: vp.textScale,
            locale: Locale(vp.lang, vp.lang == 'bn' ? 'BD' : null),
            child: InvoiceScreen(
              invoiceNumber: 'INV-2026-001',
              serviceTitle: 'Inverter AC Master Jet Wash',
              clientName: 'Timon Biswas',
              clientPhone: '01711000000',
              specialistName: 'Assigned Specialist',
              baseAmount: 1200,
              platformFee: 180,
              totalAmount: 1380,
              paymentMethod: 'bKash',
              transactionId: 'TXN-001',
              paidAt: DateTime(2026, 11, 18),
              status: 'Pending Escrow',
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.text('PENDING ESCROW'), findsOneWidget);
        expect(find.byType(SkaviaBadge), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('SKAVIA Complete Bilingual Localization & Bengali Typography Verification Suite', () {
    testWidgets('AppLocalizations loads both English and Bengali without missing keys', (
      tester,
    ) async {
      late AppLocalizations en;
      late AppLocalizations bn;

      await tester.pumpWidget(
        _wrap(
          locale: const Locale('en'),
          child: Builder(
            builder: (ctx) {
              en = ctx.l10n;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      await tester.pump();

      await tester.pumpWidget(
        _wrap(
          locale: const Locale('bn', 'BD'),
          child: Builder(
            builder: (ctx) {
              bn = ctx.l10n;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      await tester.pump();

      // Verify all seven user roles are fully localized
      expect(en.roleSuperAdmin, 'Super Admin');
      expect(bn.roleSuperAdmin, 'সুপার অ্যাডমিন');

      expect(en.roleCompanyAdmin, 'Company Admin');
      expect(bn.roleCompanyAdmin, 'কোম্পানি অ্যাডমিন');

      expect(en.roleBranchManager, 'Branch Manager');
      expect(bn.roleBranchManager, 'ব্রাঞ্চ ম্যানেজার');

      expect(en.roleWorker, 'Worker');
      expect(bn.roleWorker, 'কর্মী');

      expect(en.roleIndividualCustomer, 'Individual Customer');
      expect(bn.roleIndividualCustomer, 'ব্যক্তিগত গ্রাহক');

      expect(en.roleBusinessClient, 'Business Client');
      expect(bn.roleBusinessClient, 'বিজনেস ক্লায়েন্ট');

      expect(en.roleOrganization, 'Organization');
      expect(bn.roleOrganization, 'প্রতিষ্ঠান');

      // Verify navigation labels
      expect(en.navHome, 'Home');
      expect(bn.navHome, 'হোম');
      expect(en.navServices, 'Services');
      expect(bn.navServices, 'সার্ভিস');
      expect(en.navMessages, 'Messages');
      expect(bn.navMessages, 'মেসেজ');
      expect(en.navFeed, 'Feed');
      expect(bn.navFeed, 'ফিড');
      expect(en.navProfile, 'Profile');
      expect(bn.navProfile, 'প্রোফাইল');
    });

    testWidgets('AppTypography adapts font family, letter spacing and line heights for Bengali script', (
      tester,
    ) async {
      final themeEn = AppTypography.buildTextTheme(
        brightness: Brightness.light,
        languageCode: 'en',
      );
      expect(themeEn.displayLarge, isNotNull);
      final themeBn = AppTypography.buildTextTheme(
        brightness: Brightness.light,
        languageCode: 'bn',
      );

      // In Bengali, letter spacing MUST be zero to prevent conjunct ligature breakage
      expect(themeBn.displayLarge?.letterSpacing, 0.0);
      expect(themeBn.headlineMedium?.letterSpacing, 0.0);
      expect(themeBn.labelSmall?.letterSpacing, 0.0);

      // In Bengali, line height MUST provide safe headroom (>1.35) for top and bottom vowel signs
      expect(themeBn.bodyMedium?.height, greaterThanOrEqualTo(1.45));
      expect(themeBn.titleMedium?.height, greaterThanOrEqualTo(1.40));
    });

    test('Formatters formats currency, dates, numbers, and relative time in Bengali and English', () {
      // 1. Currency
      expect(Formatters.formatCurrency(1500, useBnDigits: false), '৳ 1,500');
      expect(Formatters.formatCurrency(1500, useBnDigits: true), '৳ ১,৫০০');

      // 2. Dates
      final testDate = DateTime(2026, 10, 19, 15, 30);
      expect(Formatters.formatDate(testDate, useBn: false), '19 Oct 2026');
      expect(Formatters.formatDate(testDate, useBn: true), '১৯ অক্টোবর ২০২৬');

      // 3. Time
      expect(Formatters.formatTime(testDate, useBn: false), contains('PM'));
      expect(Formatters.formatTime(testDate, useBn: true), contains('PM'));

      // 4. Relative Time
      final justNow = DateTime.now();
      expect(Formatters.timeAgo(justNow, useBn: false), 'Just now');
      expect(Formatters.timeAgo(justNow, useBn: true), 'এইমাত্র');

      final fiveMinutesAgo = DateTime.now().subtract(const Duration(minutes: 5));
      expect(Formatters.timeAgo(fiveMinutesAgo, useBn: false), '5m ago');
      expect(Formatters.timeAgo(fiveMinutesAgo, useBn: true), '৫ মিনিট আগে');

      // 5. Bengali Digits helper
      expect(Formatters.toBengaliDigits(1234567890), '১২৩৪৫৬৭৮৯০');
    });

    testWidgets('Zero-flicker reactive language switching updates UI instantaneously without crashing', (
      tester,
    ) async {
      AppLanguageService.setLanguage('en');

      await tester.pumpWidget(
        ValueListenableBuilder<String>(
          valueListenable: AppLanguageService.localeNotifier,
          builder: (context, langCode, _) {
            return _wrap(
              locale: Locale(langCode, langCode == 'bn' ? 'BD' : null),
              child: Builder(
                builder: (ctx) {
                  return Scaffold(
                    appBar: AppBar(title: Text(ctx.l10n.navServices)),
                    body: Center(child: Text(ctx.l10n.commonSave)),
                  );
                },
              ),
            );
          },
        ),
      );
      await tester.pump();

      expect(find.text('Services'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);

      // Instant switch to Bengali
      AppLanguageService.setLanguage('bn');
      await tester.pump();

      expect(find.text('সার্ভিস'), findsOneWidget);
      expect(find.text('সংরক্ষণ করুন'), findsOneWidget);

      // Instant switch back to English
      AppLanguageService.setLanguage('en');
      await tester.pump();

      expect(find.text('Services'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    test('AppLanguageService provides localized names for all 7 user roles', () {
      AppLanguageService.setLanguage('en');
      expect(AppLanguageService.getRoleName('Super Admin'), 'Super Admin');
      expect(AppLanguageService.getRoleName('Company Admin'), 'Company Admin');
      expect(AppLanguageService.getRoleName('Branch Manager'), 'Branch Manager');
      expect(AppLanguageService.getRoleName('Worker'), 'Worker');
      expect(AppLanguageService.getRoleName('Individual Customer'), 'Individual Customer');
      expect(AppLanguageService.getRoleName('Business Client'), 'Business Client');
      expect(AppLanguageService.getRoleName('Organization'), 'Organization');

      AppLanguageService.setLanguage('bn');
      expect(AppLanguageService.getRoleName('Super Admin'), 'সুপার অ্যাডমিন');
      expect(AppLanguageService.getRoleName('Company Admin'), 'কোম্পানি অ্যাডমিন');
      expect(AppLanguageService.getRoleName('Branch Manager'), 'ব্রাঞ্চ ম্যানেজার');
      expect(AppLanguageService.getRoleName('Worker'), 'কর্মী');
      expect(AppLanguageService.getRoleName('Individual Customer'), 'ব্যক্তিগত গ্রাহক');
      expect(AppLanguageService.getRoleName('Business Client'), 'বিজনেস ক্লায়েন্ট');
      expect(AppLanguageService.getRoleName('Organization'), 'প্রতিষ্ঠান');
      AppLanguageService.setLanguage('en');
    });

    testWidgets('DashboardBottomNavBar with Bengali labels renders without overflow at 320dp width', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320 * 2.0, 568 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      AppLanguageService.setLanguage('bn');

      await tester.pumpWidget(
        _wrap(
          locale: const Locale('bn', 'BD'),
          child: Scaffold(
            bottomNavigationBar: DashboardBottomNavBar(
              currentIndex: 0,
              currentMode: AppRoleMode.customer,
              onTabSelected: (_) {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('হোম'), findsOneWidget);
      expect(find.text('সার্ভিস'), findsOneWidget);
      expect(find.text('মেসেজ'), findsOneWidget);
      expect(find.text('ফিড'), findsOneWidget);
      expect(find.text('প্রোফাইল'), findsOneWidget);

      AppLanguageService.setLanguage('en');
    });
  });
}
