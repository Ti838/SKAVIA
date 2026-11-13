import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skavia/app/router/app_router.dart';
import 'package:skavia/app/router/app_routes.dart';
import 'package:skavia/app/theme/app_theme.dart';
import 'package:skavia/core/network/network_connectivity_service.dart';
import 'package:skavia/core/services/app_language_service.dart';
import 'package:skavia/core/services/app_theme_service.dart';
import 'package:skavia/core/services/sound_haptic_preferences.dart';
import 'package:skavia/core/storage/local_cache_service.dart';
import 'package:skavia/core/storage/secure_storage_service.dart';
import 'package:skavia/core/utils/validators.dart';
import 'package:skavia/features/authentication/presentation/controllers/auth_controller.dart';
import 'package:skavia/features/authentication/presentation/screens/login_screen.dart';
import 'package:skavia/features/authentication/presentation/screens/otp_verification_screen.dart';
import 'package:skavia/features/authentication/presentation/screens/register_screen.dart';
import 'package:skavia/features/authentication/presentation/screens/role_selection_screen.dart';
import 'package:skavia/features/billing/presentation/screens/transaction_history_screen.dart';
import 'package:skavia/shared/dialogs/account_deletion_dialog.dart';
import 'package:skavia/shared/screens/image_crop_resize_screen.dart';
import 'package:skavia/features/customer/presentation/widgets/avatar_picker_sheet.dart';
import 'package:skavia/features/navigation/presentation/screens/main_scaffold_screen.dart';
import 'package:skavia/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:skavia/features/profile/data/models/profile_stats_model.dart';
import 'package:skavia/features/profile/data/models/user_address_model.dart';
import 'package:skavia/features/profile/data/models/user_profile_model.dart';
import 'package:skavia/features/profile/data/models/user_session_model.dart';
import 'package:skavia/features/profile/presentation/controllers/profile_controller.dart';
import 'package:skavia/features/profile/presentation/screens/about_skavia_screen.dart';
import 'package:skavia/features/profile/presentation/screens/edit_detailed_profile_screen.dart';
import 'package:skavia/features/profile/presentation/screens/notification_preferences_screen.dart';
import 'package:skavia/features/profile/presentation/screens/privacy_security_screen.dart';
import 'package:skavia/features/profile/presentation/screens/saved_addresses_screen.dart';
import 'package:skavia/features/profile/presentation/screens/settings_screen.dart';
import 'package:skavia/features/profile/presentation/screens/support_faq_screen.dart';
import 'package:skavia/features/profile/presentation/widgets/unified_profile_view.dart';
import 'package:skavia/features/reviews/presentation/screens/submit_complaint_screen.dart';

class _FakeProfileRemoteDataSource extends ProfileRemoteDataSource {
  UserProfileModel storedProfile;
  ProfileStatsModel storedStats;
  List<UserSessionModel> storedSessions;
  bool failRevoke = false;

  _FakeProfileRemoteDataSource({
    UserProfileModel? initialProfile,
    ProfileStatsModel? initialStats,
    List<UserSessionModel>? initialSessions,
  })  : storedProfile =
            initialProfile ??
            UserProfileModel(
              id: 'user_stage_c_01',
              email: 'nadia.corporate@skavia.com',
              fullName: 'Nadia Rahman',
              phone: '+8801712345678',
              role: 'Business Client',
              customerType: 'Business Client',
              companyName: 'Rahman Cold Storage Ltd',
              tradeLicense: 'TRAD/DSCC/004412',
              billingAddress: 'Plot 12, Tejgaon Industrial Area, Dhaka',
              savedAddresses: [
                UserAddressModel(
                  id: 'addr_home',
                  userId: 'user_stage_c_01',
                  label: 'Headquarters',
                  addressLine: 'House 22, Road 11, Banani, Dhaka',
                  isDefault: true,
                ),
                UserAddressModel(
                  id: 'addr_depot',
                  userId: 'user_stage_c_01',
                  label: 'Depot',
                  addressLine: 'Section 4, Chattogram Port Access Rd',
                  isDefault: false,
                ),
              ],
            ),
        storedStats =
            initialStats ??
            const ProfileStatsModel(
              servicesCount: 9,
              projectsCount: 3,
              ratingAverage: 4.9,
              completedJobs: 12,
            ),
        storedSessions =
            initialSessions ??
            [
              UserSessionModel(
                id: 'sess_current',
                userId: 'user_stage_c_01',
                deviceId: 'device_current_001',
                deviceName: 'Pixel 8 Pro',
                deviceOs: 'android',
                appVersion: '1.0.0+1',
                lastActiveAt: DateTime.now(),
                isCurrentDevice: true,
              ),
              UserSessionModel(
                id: 'sess_other',
                userId: 'user_stage_c_01',
                deviceId: 'device_other_002',
                deviceName: 'Galaxy Tab S9',
                deviceOs: 'android',
                appVersion: '1.0.0+1',
                lastActiveAt: DateTime.now().subtract(const Duration(hours: 4)),
                isCurrentDevice: false,
              ),
            ],
        super(supabase: null);

  @override
  Future<UserProfileModel> getProfile(
    String userId, {
    String? fallbackEmail,
    String? fallbackName,
    String? fallbackPhone,
    String? fallbackAvatarUrl,
  }) async {
    return storedProfile;
  }

  @override
  Future<ProfileStatsModel> getProfileStats(String userId) async => storedStats;

  @override
  Future<bool> updateProfile(UserProfileModel profile) async {
    storedProfile = profile;
    return true;
  }

  @override
  Future<bool> saveAddress(UserAddressModel address) async => true;

  @override
  Future<bool> deleteAddress(String addressId, String userId) async => true;

  @override
  Future<String> getOrCreateDeviceId() async => 'device_current_001';

  @override
  Future<List<UserSessionModel>> getUserSessions(String userId) async {
    return List<UserSessionModel>.from(storedSessions);
  }

  @override
  Future<bool> revokeSession(String sessionId, String userId) async {
    if (failRevoke) return false;
    storedSessions = storedSessions
        .map((s) => s.id == sessionId ? s.copyWith(isRevoked: true) : s)
        .toList();
    return true;
  }

  @override
  Future<bool> revokeOtherSessions(
    String userId,
    String currentDeviceId,
  ) async {
    if (failRevoke) return false;
    storedSessions = storedSessions
        .map(
          (s) => s.deviceId == currentDeviceId ? s : s.copyWith(isRevoked: true),
        )
        .toList();
    return true;
  }

  @override
  Future<bool> deactivateAccount(String userId, String reason) async {
    storedProfile = storedProfile.copyWith(accountStatus: 'deactivated');
    return true;
  }

  @override
  Future<bool> requestAccountDeletion(String userId, String reason) async {
    storedProfile = storedProfile.copyWith(accountStatus: 'pending_deletion');
    return true;
  }
}

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

  group('Stage C — Validators, Models & ProfileController Unit Tests', () {
    test('Validators accept modern multi-char TLDs & normalize BD phones', () {
      expect(Validators.email('ops@skavia.agency'), isNull);
      expect(Validators.email('qa+team@company.global'), isNull);
      expect(Validators.email('bad-email'), isNotNull);

      expect(Validators.bdPhone('01712345678'), isNull);
      expect(Validators.bdPhone('+8801812345678'), isNull);
      expect(Validators.bdPhone('01212345678'), isNotNull);
      expect(Validators.optionalBdPhone(''), isNull);
      expect(Validators.optionalBdPhone('123'), isNotNull);

      expect(Validators.normalizeBdPhone('01712345678'), '+8801712345678');
      expect(Validators.normalizeBdPhone('+8801712345678'), '+8801712345678');
      expect(Validators.otp('1234'), isNull);
      expect(Validators.otp('12ab'), isNotNull);
      expect(Validators.positiveNumber('2500'), isNull);
      expect(Validators.positiveNumber('-10'), isNotNull);
    });

    test('UserProfileModel normalizes customer types & serializes corporate data', () {
      final legacyBusiness = UserProfileModel.fromJson({
        'user_id': 'u_biz',
        'email': 'biz@skavia.com',
        'full_name': 'Karim Enterprise',
        'customer_type': 'Business',
        'company_name': 'Karim Logistics',
        'trade_license': 'TL-908',
        'billing_address': 'Motijheel C/A, Dhaka',
      });
      expect(legacyBusiness.customerType, 'Business Client');
      expect(legacyBusiness.isCorporateClient, isTrue);

      final org = UserProfileModel.fromJson({
        'id': 'u_org',
        'email': 'org@skavia.com',
        'full_name': 'BRAC Facilities',
        'customer_type': 'Organization',
      });
      expect(org.isCorporateClient, isTrue);

      final roundtrip = UserProfileModel.fromJson(legacyBusiness.toJson());
      expect(roundtrip.companyName, 'Karim Logistics');
      expect(roundtrip.tradeLicense, 'TL-908');
      expect(roundtrip.billingAddress, 'Motijheel C/A, Dhaka');
    });

    test('UserSessionModel & ProfileStatsModel roundtrip cleanly', () {
      final now = DateTime.now();
      final session = UserSessionModel.fromJson(
        {
          'id': 's1',
          'user_id': 'u1',
          'device_id': 'dev_abc',
          'device_name': 'Pixel 9',
          'device_os': 'android',
          'app_version': '1.0.0+1',
          'last_active_at': now.toIso8601String(),
          'is_revoked': false,
        },
        currentDeviceId: 'dev_abc',
      );
      expect(session.isCurrentDevice, isTrue);
      expect(session.copyWith(isRevoked: true).isRevoked, isTrue);
      expect(UserSessionModel.fromJson(session.toJson()).deviceName, 'Pixel 9');

      final stats = ProfileStatsModel.fromJson(
        const ProfileStatsModel(
          servicesCount: 4,
          projectsCount: 2,
          ratingAverage: 4.85,
          completedJobs: 6,
        ).toJson(),
      );
      expect(stats.servicesCount, 4);
      expect(stats.projectsCount, 2);
      expect(stats.ratingAverage, 4.85);
      expect(stats.completedJobs, 6);
    });

    test('ProfileController manages profile edits, single default address, sessions & deactivation', () async {
      final fakeDs = _FakeProfileRemoteDataSource();
      final controller = ProfileController(dataSource: fakeDs);
      addTearDown(controller.dispose);

      await controller.loadProfile('user_stage_c_01');
      expect(controller.profile?.fullName, 'Nadia Rahman');
      expect(controller.stats.servicesCount, 9);

      final updatedOk = await controller.updateProfile(
        customerType: 'Organization',
        companyName: 'Delta Cold Chain BD',
        preferredLanguage: 'bn',
        timezone: 'Asia/Dhaka',
        gender: 'female',
      );
      expect(updatedOk, isTrue);
      expect(controller.profile?.customerType, 'Organization');
      expect(AppLanguageService.isBengali, isTrue);
      AppLanguageService.setLanguage('en');

      await controller.setDefaultAddress(
        controller.profile!.savedAddresses.last,
      );
      final defaults = controller.profile!.savedAddresses
          .where((a) => a.isDefault)
          .toList();
      expect(defaults.length, 1);
      expect(defaults.first.id, 'addr_depot');

      await controller.deleteAddress('addr_depot');
      expect(
        controller.profile!.savedAddresses.any((a) => a.id == 'addr_depot'),
        isFalse,
      );

      await controller.toggleNotificationPreference('promotional', true);
      expect(controller.profile!.notificationPreferences['promotional'], isTrue);

      await controller.updatePrivacySettings({
        'profile_visibility': 'contacts_only',
        'share_phone_with_assigned_specialist': false,
        'data_sharing_consent': false,
      });
      expect(
        controller.profile!.privacySettings['profile_visibility'],
        'contacts_only',
      );

      await controller.loadSessions();
      expect(controller.sessions.length, 2);

      await controller.revokeAllOtherSessions();
      expect(
        controller.sessions.firstWhere((s) => s.id == 'sess_current').isRevoked,
        isFalse,
      );
      expect(
        controller.sessions.firstWhere((s) => s.id == 'sess_other').isRevoked,
        isTrue,
      );

      await controller.deactivateAccount('Seasonal break');
      expect(controller.profile?.accountStatus, 'deactivated');

      await controller.requestAccountDeletion('Compliance test');
      expect(controller.profile?.accountStatus, 'pending_deletion');

      controller.clearSession();
      expect(controller.profile, isNull);
      expect(controller.sessions, isEmpty);
    });
  });

  group('Stage C — Screens Light/Dark & 320dp + 2.0x Text Scale Verification', () {
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

    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('Auth screens render & toggle safely ($mode, 320dp 2.0x)', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(wrapScreen(const LoginScreen(), mode));
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.byType(LoginScreen), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(wrapScreen(const RegisterScreen(), mode));
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.byType(RegisterScreen), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(
          wrapScreen(
            const OtpVerificationScreen(phoneNumber: '+8801712345678'),
            mode,
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.byType(OtpVerificationScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('RoleSelectionScreen reveals Business Client/Organization subtype ($mode)', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(wrapScreen(const RoleSelectionScreen(), mode));
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull);

        final bizFinder = find.text('Business / Organization');
        await tester.scrollUntilVisible(
          bizFinder,
          120,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.ensureVisible(bizFinder);
        await tester.pump(const Duration(milliseconds: 100));
        await tester.tap(bizFinder);
        await tester.pump(const Duration(milliseconds: 250));

        final orgFinder = find.text('Organization');
        await tester.scrollUntilVisible(
          orgFinder,
          120,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.ensureVisible(orgFinder);
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.text('Business Client'), findsOneWidget);
        expect(find.text('Organization'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('Profile & Settings screens render cleanly ($mode, 320dp 2.0x)', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final fakeDs = _FakeProfileRemoteDataSource();
        final controller = ProfileController(dataSource: fakeDs);
        await controller.loadProfile('user_stage_c_01');
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          wrapScreen(EditDetailedProfileScreen(controller: controller), mode),
        );
        await tester.pump(const Duration(milliseconds: 150));
        expect(find.text('Nadia Rahman'), findsWidgets);
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(
          wrapScreen(SavedAddressesScreen(controller: controller), mode),
        );
        await tester.pump(const Duration(milliseconds: 150));
        expect(find.text('Headquarters'), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(
          wrapScreen(
            NotificationPreferencesScreen(controller: controller),
            mode,
          ),
        );
        await tester.pump(const Duration(milliseconds: 150));
        expect(find.text('Alert Channels'), findsOneWidget);
        await tester.scrollUntilVisible(
          find.text('Sound, Chime & Haptic Controls'),
          160,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('Sound, Chime & Haptic Controls'), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(
          wrapScreen(PrivacySecurityScreen(controller: controller), mode),
        );
        await tester.pump(const Duration(milliseconds: 150));
        expect(find.text('Privacy Controls'), findsOneWidget);
        await tester.scrollUntilVisible(
          find.text('Active Devices & Sessions'),
          160,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('Active Devices & Sessions'), findsOneWidget);
        expect(tester.takeException(), isNull);

        final auth = AuthController();
        addTearDown(auth.dispose);
        await tester.pumpWidget(
          wrapScreen(
            SettingsScreen(
              authController: auth,
              profileController: controller,
            ),
            mode,
          ),
        );
        await tester.pump(const Duration(milliseconds: 150));
        expect(find.text('Settings & Preferences'), findsOneWidget);
        await tester.scrollUntilVisible(
          find.text('Sync Now'),
          160,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('Sync Now'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('Support, About, Transactions, Complaints & UnifiedProfileView render cleanly ($mode)', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(wrapScreen(const SupportFaqScreen(), mode));
        await tester.pump(const Duration(milliseconds: 150));
        expect(find.text('Help Center & FAQ'), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(wrapScreen(const AboutSkaviaScreen(), mode));
        await tester.pump(const Duration(milliseconds: 150));
        expect(find.text('Every Skill. Every Opportunity.'), findsOneWidget);
        await tester.scrollUntilVisible(
          find.text('Unified Solution Platform'),
          160,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('Unified Solution Platform'), findsOneWidget);
        await tester.scrollUntilVisible(
          find.text('9 Specialization Branches'),
          160,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('9 Specialization Branches'), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(
          wrapScreen(const TransactionHistoryScreen(), mode),
        );
        await tester.pump(const Duration(milliseconds: 150));
        expect(find.text('Transaction History & Invoices'), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(
          wrapScreen(const SubmitComplaintScreen(), mode),
        );
        await tester.pump(const Duration(milliseconds: 150));
        expect(find.text('Submit a Complaint'), findsOneWidget);
        expect(tester.takeException(), isNull);

        final fakeDs = _FakeProfileRemoteDataSource();
        final profileController = ProfileController(dataSource: fakeDs);
        await profileController.loadProfile('user_stage_c_01');
        final auth = AuthController();
        addTearDown(profileController.dispose);
        addTearDown(auth.dispose);

        await tester.pumpWidget(
          wrapScreen(
            Scaffold(
              body: UnifiedProfileView(
                authController: auth,
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
            mode,
          ),
        );
        await tester.pump(const Duration(milliseconds: 150));
        expect(find.text('Nadia Rahman'), findsOneWidget);
        expect(find.text('Timon Biswas'), findsNothing);
        expect(tester.takeException(), isNull);
      });

      testWidgets('AvatarPickerSheet & AccountDeletionDialog render without overflow ($mode, 320dp 2.0x)', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          wrapScreen(
            Scaffold(
              body: SingleChildScrollView(
                child: AvatarPickerSheet(
                  currentAvatarUrl: null,
                  userId: 'user_stage_c_01',
                  onAvatarSelected: (_) {},
                ),
              ),
            ),
            mode,
          ),
        );
        await tester.pump(const Duration(milliseconds: 150));
        expect(find.byType(AvatarPickerSheet), findsOneWidget);
        expect(tester.takeException(), isNull);

        final auth = AuthController();
        addTearDown(auth.dispose);
        await tester.pumpWidget(
          wrapScreen(
            Builder(
              builder: (ctx) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () =>
                        AccountDeletionDialog.show(ctx, authController: auth),
                    child: const Text('Open Delete'),
                  ),
                ),
              ),
            ),
            mode,
          ),
        );
        await tester.tap(find.text('Open Delete'));
        await tester.pump(const Duration(milliseconds: 250));
        expect(find.byType(AccountDeletionDialog), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('Stage C — Route Resolution Integrity', () {
    test('AppRouter generates routes for all Stage C destinations', () {
      for (final routeName in [
        AppRoutes.settings,
        AppRoutes.supportFaq,
        AppRoutes.aboutSkavia,
        AppRoutes.transactionHistory,
        AppRoutes.submitComplaint,
        AppRoutes.editDetailedProfile,
        AppRoutes.savedAddresses,
        AppRoutes.notificationPreferences,
        AppRoutes.privacySecurity,
      ]) {
        final route = AppRouter.onGenerateRoute(RouteSettings(name: routeName));
        expect(route, isA<MaterialPageRoute<dynamic>>());
      }
    });

    test('UserProfileModel resolves cover_url directly and via privacy_settings fallback', () {
      final direct = UserProfileModel.fromJson({
        'user_id': 'u1',
        'email': 'u1@skavia.com',
        'full_name': 'Nadia Rahman',
        'cover_url': 'https://example.com/cover.jpg',
      });
      expect(direct.coverUrl, 'https://example.com/cover.jpg');

      final fallback = UserProfileModel.fromJson({
        'user_id': 'u2',
        'email': 'u2@skavia.com',
        'full_name': 'Nadia Rahman',
        'privacy_settings': {'cover_url': 'https://example.com/fallback-cover.jpg'},
      });
      expect(fallback.coverUrl, 'https://example.com/fallback-cover.jpg');
    });

    testWidgets('AvatarPickerSheet cover slot and ImageCropResizeScreen render cleanly without dummy avatars', (
      tester,
    ) async {
      final assetSample = File('assets/images/skavia_logo.png');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AvatarPickerSheet(
                currentAvatarUrl: 'https://example.com/existing-cover.jpg',
                userId: 'u_cover_01',
                slot: ProfileMediaSlot.cover,
                onAvatarSelected: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Change Cover Banner'), findsOneWidget);
      expect(find.text('Remove banner'), findsOneWidget);
      expect(find.text('Verified Pro Avatars'), findsNothing);
      expect(tester.takeException(), isNull);

      ui.Image? decodedLogo;
      await tester.runAsync(() async {
        final bytes = await File('assets/images/skavia_logo.png').readAsBytes();
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        decodedLogo = frame.image;
      });
      expect(decodedLogo, isNotNull);

      await tester.pumpWidget(
        MaterialApp(
          home: ImageCropResizeScreen(
            imageFile: assetSample,
            isBanner: true,
            initialImage: decodedLogo,
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Crop & Resize Cover Banner'), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
