import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skavia/app/theme/app_colors.dart';
import 'package:skavia/app/theme/app_theme.dart';
import 'package:skavia/core/extensions/context_extensions.dart';
import 'package:skavia/core/services/app_language_service.dart';
import 'package:skavia/core/services/app_theme_service.dart';
import 'package:skavia/core/services/sound_haptic_preferences.dart';
import 'package:skavia/core/storage/local_cache_service.dart';
import 'package:skavia/core/storage/secure_storage_service.dart';
import 'package:skavia/shared/dialogs/confirmation_dialog.dart';
import 'package:skavia/shared/dialogs/error_dialog.dart';
import 'package:skavia/shared/empty_states/empty_data_view.dart';
import 'package:skavia/shared/error_states/error_view.dart';
import 'package:skavia/shared/loaders/list_shimmer_skeleton.dart';
import 'package:skavia/shared/models/radar_technician.dart';
import 'package:skavia/shared/widgets/app_card.dart';
import 'package:skavia/shared/widgets/radar_location_banner.dart';
import 'package:skavia/shared/widgets/radar_map_filter_bar.dart';
import 'package:skavia/shared/widgets/radar_map_header.dart';
import 'package:skavia/shared/widgets/radar_technician_card.dart';
import 'package:skavia/shared/widgets/user_avatar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Stage B — Core Persistence & Tokens Tests', () {
    test('Theme, language, sound prefs, and local cache persist via SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await AppThemeService.init(prefs: prefs);
      AppThemeService.setThemeMode(ThemeMode.dark);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      AppThemeService.themeModeNotifier.value = ThemeMode.system;
      await AppThemeService.init(prefs: prefs);
      expect(AppThemeService.themeMode, ThemeMode.dark);
      AppThemeService.setThemeMode(ThemeMode.system);

      await AppLanguageService.init(prefs: prefs);
      AppLanguageService.setLanguage('bn');
      await Future<void>.delayed(const Duration(milliseconds: 20));
      AppLanguageService.localeNotifier.value = 'en';
      await AppLanguageService.init(prefs: prefs);
      expect(AppLanguageService.isBengali, isTrue);
      AppLanguageService.setLanguage('en');

      await SoundHapticPreferences.instance.init(prefs: prefs);
      await SoundHapticPreferences.instance.setNotificationSound(false);
      await SoundHapticPreferences.instance.setVibrationEnabled(false);
      expect(SoundHapticPreferences.instance.notificationSoundEnabled, isFalse);
      expect(SoundHapticPreferences.instance.vibrationEnabled, isFalse);

      await LocalCacheService.instance.init(prefs: prefs);
      LocalCacheService.instance.put('stage_b_persist', {'ok': true});
      expect(LocalCacheService.instance.get('stage_b_persist')['ok'], isTrue);

      final storage = SecureStorageService();
      await storage.init(prefs: prefs);
      await storage.write(key: 'remembered_email', value: 'user@skavia.com');
      expect(await storage.read(key: 'remembered_email'), 'user@skavia.com');
    });

    testWidgets('SkaviaSurfaceTokens expose Light & Dark palettes', (tester) async {
      late SkaviaSurfaceTokens lightTokens;
      late SkaviaSurfaceTokens darkTokens;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          home: Builder(
            builder: (context) {
              darkTokens = context.skavia;
              return Theme(
                data: AppTheme.lightTheme,
                child: Builder(
                  builder: (lightCtx) {
                    lightTokens = lightCtx.skavia;
                    return const SizedBox.shrink();
                  },
                ),
              );
            },
          ),
        ),
      );

      expect(lightTokens.cardBg, const Color(0xFFFFFFFF));
      expect(darkTokens.cardBg, const Color(0xFF1E293B));
      expect(darkTokens.brandAccent, const Color(0xFF60A5FA));
    });
  });

  group('Stage B — Shared Widgets Light/Dark & 320dp + 2.0x Text Scale', () {
    Widget wrapForTest({
      required Widget child,
      required ThemeMode mode,
      double textScale = 2.0,
    }) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: mode,
        home: MediaQuery(
          data: MediaQueryData(
            size: const Size(320, 568),
            textScaler: TextScaler.linear(textScale),
          ),
          child: Scaffold(body: SingleChildScrollView(child: child)),
        ),
      );
    }

    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('Shared dialogs & state views render cleanly ($mode)', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          wrapForTest(
            mode: mode,
            child: Column(
              children: [
                ConfirmationDialog(
                  title: 'Delete Account Permanently',
                  message:
                      'Your profile and data will be scheduled for deletion.',
                  confirmText: 'Confirm Delete',
                  isDestructive: true,
                  onConfirm: () {},
                ),
                ErrorDialog(
                  title: 'Upload Blocked',
                  message: 'Please check network connection.',
                  onDismiss: () {},
                ),
                const AppCard(
                  child: Text('Adaptive Card Content'),
                ),
                EmptyDataView(
                  title: 'Nothing Here Yet',
                  message: 'Start a service request.',
                  actionText: 'Browse',
                  onAction: () {},
                ),
                ErrorView(
                  message: 'Could not sync data',
                  onRetry: () {},
                ),
                const UserAvatar(name: 'Tariqul Hasan', isVerified: true),
                const ListShimmerSkeleton(itemCount: 2),
              ],
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 200));
        expect(tester.takeException(), isNull);
        expect(find.byType(ConfirmationDialog), findsOneWidget);
        expect(find.byType(ListShimmerSkeleton), findsOneWidget);

        // Verify destructive button uses red background
        final destructiveBtn = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Confirm Delete'),
        );
        expect(
          destructiveBtn.style?.backgroundColor?.resolve({}),
          AppColors.error,
        );
      });

      testWidgets('Radar sheet widgets render without overflow at 320dp 2.0x scale ($mode)', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          wrapForTest(
            mode: mode,
            child: Column(
              children: [
                RadarMapHeader(
                  locationZone: 'Dhanmondi Residential Area, Dhaka',
                  onClose: () {},
                ),
                RadarMapFilterBar(
                  selectedRadiusKm: 5,
                  onRadiusChanged: (_) {},
                  selectedTradeFilter: 'All',
                  onTradeFilterChanged: (_) {},
                  isBn: false,
                ),
                const RadarLocationBanner(
                  selectedPoint: LatLng(23.7461, 90.3742),
                  selectedAddress: 'House 12, Road 8, Dhanmondi, Dhaka',
                  isReverseGeocoding: false,
                ),
                RadarTechnicianCard(
                  technician: RadarTechnician.seedTechnicians.first,
                  onBook: () {},
                ),
              ],
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  });
}

