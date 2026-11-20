import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skavia/app/theme/app_theme.dart';
import 'package:skavia/features/diagnostics/data/services/device_diagnostics_service.dart';
import 'package:skavia/features/diagnostics/domain/entities/diagnostic_report.dart';
import 'package:skavia/features/diagnostics/domain/entities/hardware_telemetry.dart';
import 'package:skavia/features/diagnostics/domain/entities/network_benchmark.dart';
import 'package:skavia/features/diagnostics/domain/entities/performance_telemetry.dart';
import 'package:skavia/features/diagnostics/domain/entities/permission_health.dart';
import 'package:skavia/features/diagnostics/domain/enums/diagnostic_status.dart';
import 'package:skavia/features/diagnostics/presentation/screens/device_diagnostics_screen.dart';
import 'package:skavia/features/diagnostics/presentation/widgets/diagnostic_status_badge.dart';

class MockDiagnosticsService extends DeviceDiagnosticsService {
  MockDiagnosticsService() : super.custom();

  @override
  Future<HardwareTelemetry> inspectHardware() async {
    return const HardwareTelemetry(
      manufacturer: 'Samsung',
      model: 'Galaxy S23',
      osName: 'Android',
      osVersion: '14',
      sdkInt: 34,
      supportedAbis: ['arm64-v8a'],
      isPhysicalDevice: true,
      deviceType: 'Smartphone',
    );
  }

  @override
  Future<PermissionHealth> auditPermissions() async {
    return const PermissionHealth(
      camera: DiagnosticStatus.supported,
      location: DiagnosticStatus.supported,
      notifications: DiagnosticStatus.supported,
      microphone: DiagnosticStatus.notApplicable,
      storage: DiagnosticStatus.supported,
    );
  }

  @override
  Future<PerformanceTelemetry> inspectPerformance() async {
    return const PerformanceTelemetry(
      startupDurationMs: 380,
      responsiveness: DiagnosticStatus.supported,
      recentFrameRasterDurationMs: 11.4,
      estimatedStorageStatus: 'Healthy (> 5 GB Available)',
    );
  }

  @override
  Future<DiagnosticReport> runFullDiagnostics() async {
    final hw = await inspectHardware();
    final perm = await auditPermissions();
    final perf = await inspectPerformance();

    return DiagnosticReport(
      timestamp: DateTime(2026, 11, 20, 12, 0),
      hardware: hw,
      permissions: perm,
      network: const NetworkBenchmark(
        isOnline: true,
        latencyMs: 42,
        testEndpoint: 'https://1.1.1.1',
        quality: DiagnosticStatus.supported,
        connectionType: 'WiFi 6 / 4G LTE',
      ),
      performance: perf,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SKAVIA Device Diagnostics Domain & Service Tests', () {
    test('HardwareTelemetry evaluates 64-bit modern Android accurately', () {
      const modernAndroid = HardwareTelemetry(
        manufacturer: 'Google',
        model: 'Pixel 8 Pro',
        osName: 'Android',
        osVersion: '14',
        sdkInt: 34,
        supportedAbis: ['arm64-v8a'],
        isPhysicalDevice: true,
        deviceType: 'Smartphone',
      );

      expect(modernAndroid.isMinSdkSatisfied, isTrue);
      expect(modernAndroid.is64BitArm, isTrue);
      expect(modernAndroid.compatibilityStatus, DiagnosticStatus.supported);

      final json = modernAndroid.toJson();
      expect(json['manufacturer'], 'Google');
      expect(json['sdk_int'], 34);
      expect(json['is_min_sdk_satisfied'], isTrue);
      // Ensure zero tracking fields
      expect(json.containsKey('imei'), isFalse);
      expect(json.containsKey('serial'), isFalse);
    });

    test('HardwareTelemetry evaluates legacy 32-bit Android accurately', () {
      const legacyAndroid = HardwareTelemetry(
        manufacturer: 'Xiaomi',
        model: 'Redmi 4A',
        osName: 'Android',
        osVersion: '7.1.2',
        sdkInt: 25,
        supportedAbis: ['armeabi-v7a', 'armeabi'],
        isPhysicalDevice: true,
        deviceType: 'Smartphone',
      );

      expect(legacyAndroid.isMinSdkSatisfied, isTrue);
      expect(legacyAndroid.is64BitArm, isFalse);
      expect(legacyAndroid.compatibilityStatus, DiagnosticStatus.limited);
    });

    test('HardwareTelemetry flags obsolete Android (< API 24) as unsupported', () {
      const obsoleteAndroid = HardwareTelemetry(
        manufacturer: 'Samsung',
        model: 'Galaxy S4',
        osName: 'Android',
        osVersion: '5.0.1',
        sdkInt: 21,
        supportedAbis: ['armeabi-v7a'],
        isPhysicalDevice: true,
        deviceType: 'Smartphone',
      );

      expect(obsoleteAndroid.isMinSdkSatisfied, isFalse);
      expect(obsoleteAndroid.compatibilityStatus, DiagnosticStatus.unsupported);
    });

    test('DiagnosticStatus enum provides complete dual-script labels and icons', () {
      for (final status in DiagnosticStatus.values) {
        expect(status.labelEn.isNotEmpty, isTrue);
        expect(status.labelBn.isNotEmpty, isTrue);
        expect(status.color, isNotNull);
        expect(status.icon, isNotNull);
      }
    });
  });

  group('SKAVIA Device Diagnostics UI & 320dp Constraint Tests', () {
    testWidgets(
      'DeviceDiagnosticsScreen renders with zero overflow on 320dp screen (ThemeMode.light)',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final mockService = MockDiagnosticsService();

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(320, 640),
                textScaler: TextScaler.linear(1.5),
              ),
              child: DeviceDiagnosticsScreen(
                diagnosticsService: mockService,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(DeviceDiagnosticsScreen), findsOneWidget);
        expect(find.text('Device & Operating System'), findsOneWidget);
        expect(find.text('CPU Architecture & ABIs'), findsOneWidget);
        expect(find.text('Operational Permissions'), findsOneWidget);
        expect(find.text('Network & Edge Latency'), findsOneWidget);
        final ex = tester.takeException();
        if (ex != null) {
          // ignore: avoid_print
          print('TEST OVERFLOW EXCEPTION: $ex');
        }
        expect(ex, isNull);
      },
    );

    testWidgets(
      'DeviceDiagnosticsScreen renders cleanly in Dark Mode (ThemeMode.dark)',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final mockService = MockDiagnosticsService();

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(320, 640),
                textScaler: TextScaler.linear(1.2),
              ),
              child: DeviceDiagnosticsScreen(
                diagnosticsService: mockService,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(DeviceDiagnosticsScreen), findsOneWidget);
        expect(find.text('Galaxy S23'), findsOneWidget);
        final ex = tester.takeException();
        if (ex != null) {
          // ignore: avoid_print
          print('TEST OVERFLOW EXCEPTION: $ex');
        }
        expect(ex, isNull);
      },
    );

    testWidgets(
      'DiagnosticStatusBadge renders all statuses compactly without error',
      (tester) async {
        for (final status in DiagnosticStatus.values) {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: DiagnosticStatusBadge(status: status, compact: true),
              ),
            ),
          );
          expect(find.byType(DiagnosticStatusBadge), findsOneWidget);
          final ex = tester.takeException();
        if (ex != null) {
          // ignore: avoid_print
          print('TEST OVERFLOW EXCEPTION: $ex');
        }
        expect(ex, isNull);
        }
      },
    );
  });
}
