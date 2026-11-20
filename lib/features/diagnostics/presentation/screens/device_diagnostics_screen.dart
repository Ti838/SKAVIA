import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/services/app_language_service.dart';
import '../../../../core/utils/ui_feedback_helper.dart';
import '../../../../shared/widgets/app_app_bar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../data/services/device_diagnostics_service.dart';
import '../../data/services/network_probe_service.dart';
import '../../domain/entities/diagnostic_report.dart';
import '../../domain/enums/diagnostic_status.dart';
import '../widgets/diagnostic_category_card.dart';
import '../widgets/diagnostic_consent_dialog.dart';
import '../widgets/diagnostic_status_badge.dart';
import '../widgets/hardware_spec_tile.dart';

/// Professional device diagnostics dashboard for SKAVIA mobile.
class DeviceDiagnosticsScreen extends StatefulWidget {
  final DeviceDiagnosticsService? diagnosticsService;

  const DeviceDiagnosticsScreen({super.key, this.diagnosticsService});

  @override
  State<DeviceDiagnosticsScreen> createState() =>
      _DeviceDiagnosticsScreenState();
}

class _DeviceDiagnosticsScreenState extends State<DeviceDiagnosticsScreen> {
  DeviceDiagnosticsService get _service =>
      widget.diagnosticsService ?? DeviceDiagnosticsService.instance;

  bool _isLoading = false;
  DiagnosticReport? _report;

  @override
  void initState() {
    super.initState();
    _service.initializeFrameMonitoring();
    _runDiagnostics();
  }

  Future<void> _runDiagnostics() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final report = await _service.runFullDiagnostics();
      if (mounted) {
        setState(() {
          _report = report;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        UiFeedbackHelper.showError(
          context,
          AppLanguageService.isBengali
              ? 'ডায়াগনস্টিক চালানো সম্ভব হয়নি'
              : 'Failed to run full diagnostics: $e',
        );
      }
    }
  }

  Future<void> _requestPermission(Permission perm) async {
    await perm.request();
    await _runDiagnostics();
  }

  @override
  Widget build(BuildContext context) {
    final isBn = AppLanguageService.isBengali;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppAppBar(
        title: isBn
            ? 'ডিভাইস ও সিস্টেম ডায়াগনস্টিকস'
            : 'Device & System Diagnostics',
        actions: [
          IconButton(
            icon: const Icon(Icons.shield_outlined),
            tooltip: isBn ? 'প্রাইভেসি ও ডেটা নিরাপত্তা' : 'Privacy & Security',
            onPressed: () =>
                DiagnosticConsentDialog.show(context, report: _report),
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading && _report == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Overview & Trigger Header
                    _buildOverviewHeader(isBn, isDark),
                    const SizedBox(height: 16),

                    // Section 1: Device Hardware & Operating System
                    if (_report != null) ...[
                      _buildHardwareSection(isBn, isDark),
                      const SizedBox(height: 16),

                      // Section 2: Platform Architecture & ABIs
                      _buildArchitectureSection(isBn, isDark),
                      const SizedBox(height: 16),

                      // Section 3: Essential Permissions Audit
                      _buildPermissionsSection(isBn, isDark),
                      const SizedBox(height: 16),

                      // Section 4: Network & Edge Latency
                      _buildNetworkSection(isBn, isDark),
                      const SizedBox(height: 16),

                      // Section 5: App Performance & Responsiveness
                      _buildPerformanceSection(isBn, isDark),
                      const SizedBox(height: 20),

                      // Bottom Export Action
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(
                              color: theme.colorScheme.outlineVariant,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.copy_rounded, size: 16),
                          label: Text(
                            isBn
                                ? 'ডায়াগনস্টিক রিপোর্ট কপি করুন'
                                : 'Copy Redacted Diagnostic Report',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          onPressed: () => DiagnosticConsentDialog.show(
                            context,
                            report: _report,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildOverviewHeader(bool isBn, bool isDark) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.successGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isBn
                      ? 'লোকাল ডায়াগনস্টিক ইঞ্জিন'
                      : 'On-Device Diagnostic Engine',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
              if (_report != null) ...[
                const SizedBox(width: 8),
                DiagnosticStatusBadge(
                  status: _report!.hardware.compatibilityStatus,
                  compact: true,
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isBn
                ? 'আপনার ফোনের প্রসেসর, ওএস সংস্করণ, নেটওয়ার্ক লেটেন্সি এবং প্রয়োজনীয় পারমিশন যাচাই করা হয়।'
                : 'Evaluates your device hardware, Android OS compatibility, network latency, and operational permissions.',
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: _isLoading
                      ? (isBn ? 'যাচাই করা হচ্ছে...' : 'Testing...')
                      : (isBn ? 'পুনরায় টেস্ট করুন' : 'Run Diagnostics'),
                  isLoading: _isLoading,
                  onPressed: _runDiagnostics,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHardwareSection(bool isBn, bool isDark) {
    final hw = _report!.hardware;

    return DiagnosticCategoryCard(
      icon: Icons.smartphone_rounded,
      title: isBn ? 'ডিভাইস ও অপারেটিং সিস্টেম' : 'Device & Operating System',
      subtitle: isBn ? 'হার্ডওয়্যার স্পেসিফিকেশন' : 'Hardware Telemetry',
      trailing: DiagnosticStatusBadge(
        status: hw.compatibilityStatus,
        compact: true,
      ),
      children: [
        HardwareSpecTile(
          icon: Icons.business_rounded,
          title: isBn ? 'প্রস্তুতকারক' : 'Manufacturer',
          value: hw.manufacturer,
        ),
        HardwareSpecTile(
          icon: Icons.devices_rounded,
          title: isBn ? 'মডেল' : 'Device Model',
          value: hw.model,
        ),
        HardwareSpecTile(
          icon: Icons.android_rounded,
          title: isBn ? 'ওএস ভার্সন' : 'Operating System',
          value: '${hw.osName} ${hw.osVersion} (API ${hw.sdkInt})',
          subtitle: hw.isMinSdkSatisfied
              ? (isBn
                    ? 'Android 7.0 থেকে Android 15+ (সকল ফোনে কার্যকর)'
                    : 'Android 7.0 up to Android 15+ (Fully Supported)')
              : (isBn
                    ? 'Android 7.0 এর নিচে - অসমর্থিত'
                    : 'Below Android 7.0 - Unsupported'),
        ),
        HardwareSpecTile(
          icon: Icons.verified_user_outlined,
          title: isBn ? 'ডিভাইস টাইপ' : 'Device Environment',
          value: hw.isPhysicalDevice
              ? (isBn ? 'ফিজিক্যাল স্মার্টফোন' : 'Physical Device')
              : (isBn ? 'ভার্চুয়াল / এমুলেটর' : 'Virtual / Emulator'),
        ),
      ],
    );
  }

  Widget _buildArchitectureSection(bool isBn, bool isDark) {
    final hw = _report!.hardware;

    return DiagnosticCategoryCard(
      icon: Icons.memory_rounded,
      title: isBn ? 'প্রসেসর আর্কিটেকচার' : 'CPU Architecture & ABIs',
      subtitle: isBn ? 'বাইনারি কম্প্যাটিবিলিটি' : 'Native Binary Support',
      children: [
        HardwareSpecTile(
          icon: Icons.developer_board_rounded,
          title: isBn ? 'সমর্থিত ABIs' : 'Supported ABIs',
          value: hw.supportedAbis.join(', '),
          subtitle: hw.is64BitArm
              ? (isBn
                    ? 'আধুনিক 5G ও 4G আর্কিটেকচার (ARM64-v8a) সক্রিয়'
                    : 'Modern 5G & 4G Architecture (ARM64-v8a) Active')
              : (isBn
                    ? '৩২-বিট ARMv7 লিগ্যাসি মোড'
                    : '32-bit ARMv7 Legacy Mode'),
        ),
        HardwareSpecTile(
          icon: Icons.security_rounded,
          title: isBn
              ? 'প্যাকেজ ইনস্টলার কমপ্লায়েন্স'
              : 'Package Compatibility',
          value: hw.isMinSdkSatisfied && hw.is64BitArm
              ? (isBn
                    ? 'সকল 5G ও 4G স্মার্টফোনে ১০০% সমর্থিত'
                    : '100% Compatible with all 5G & 4G Smartphones')
              : (isBn
                    ? 'ARMv7 32-bit APK প্রয়োজন'
                    : 'Requires ARMv7 32-bit APK'),
          trailing: DiagnosticStatusBadge(
            status: hw.compatibilityStatus,
            compact: true,
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionsSection(bool isBn, bool isDark) {
    final perm = _report!.permissions;

    return DiagnosticCategoryCard(
      icon: Icons.rule_folder_outlined,
      title: isBn ? 'পারমিশন অডিট' : 'Operational Permissions',
      subtitle: isBn
          ? 'কাজের প্রয়োজনীয় অনুমোদন'
          : 'Required App Entitlements',
      children: [
        HardwareSpecTile(
          icon: Icons.camera_alt_outlined,
          title: isBn ? 'ক্যামেরা' : 'Camera Access',
          value: isBn
              ? 'প্রোফাইল ছবি ও কাজের প্রমাণ'
              : 'Profile verification & job completion proof',
          trailing: perm.camera == DiagnosticStatus.permissionRequired
              ? TextButton(
                  onPressed: () => _requestPermission(Permission.camera),
                  child: Text(isBn ? 'অনুমতি দিন' : 'Grant'),
                )
              : DiagnosticStatusBadge(status: perm.camera, compact: true),
        ),
        HardwareSpecTile(
          icon: Icons.location_on_outlined,
          title: isBn ? 'লোকেশন ও জিপিএস' : 'Location & GPS Service',
          value: isBn
              ? 'হাভারসাইন ডিসপ্যাচ ও কাছাকাছি টেকনিশিয়ান'
              : 'Haversine nearby technician dispatch',
          trailing: perm.location == DiagnosticStatus.permissionRequired
              ? TextButton(
                  onPressed: () => _requestPermission(Permission.location),
                  child: Text(isBn ? 'অনুমতি দিন' : 'Grant'),
                )
              : DiagnosticStatusBadge(status: perm.location, compact: true),
        ),
        HardwareSpecTile(
          icon: Icons.notifications_none_rounded,
          title: isBn ? 'নোটিফিকেশন' : 'Notification Service',
          value: isBn
              ? 'জরুরি ডিসপ্যাচ ও ৪-সংখ্যার ওটিপি'
              : 'Urgent dispatch alerts & arrival OTP handoff',
          trailing: perm.notifications == DiagnosticStatus.permissionRequired
              ? TextButton(
                  onPressed: () => _requestPermission(Permission.notification),
                  child: Text(isBn ? 'অনুমতি দিন' : 'Grant'),
                )
              : DiagnosticStatusBadge(
                  status: perm.notifications,
                  compact: true,
                ),
        ),
        HardwareSpecTile(
          icon: Icons.mic_off_outlined,
          title: isBn ? 'মাইক্রোফোন' : 'Microphone Access',
          value: isBn
              ? 'SKAVIA দ্বারা অব্যবহৃত (ম্যানিফেস্টে অপ্রয়োজনীয়)'
              : 'Feature not used by SKAVIA (Not in manifest)',
          trailing: const DiagnosticStatusBadge(
            status: DiagnosticStatus.notApplicable,
            compact: true,
          ),
        ),
      ],
    );
  }

  Widget _buildNetworkSection(bool isBn, bool isDark) {
    final net = _report!.network;

    return DiagnosticCategoryCard(
      icon: Icons.wifi_rounded,
      title: isBn ? 'নেটওয়ার্ক ও লেটেন্সি টেস্ট' : 'Network & Edge Latency',
      subtitle: isBn ? 'ক্লাউড সংযোগের গতি' : 'API Connection Latency',
      trailing: DiagnosticStatusBadge(status: net.quality, compact: true),
      children: [
        HardwareSpecTile(
          icon: Icons.router_outlined,
          title: isBn ? 'সংযোগ অবস্থা' : 'Connectivity Status',
          value: net.isOnline
              ? (isBn ? 'অনলাইন (সক্রিয়)' : 'Online (Active)')
              : (isBn ? 'অফলাইন' : 'Offline'),
        ),
        HardwareSpecTile(
          icon: Icons.speed_rounded,
          title: isBn ? 'এজ লেটেন্সি' : 'Edge Ping Latency',
          value: net.latencyMs >= 0 ? '${net.latencyMs} ms' : 'N/A',
          subtitle: isBn
              ? 'রাউন্ড-ট্রিপ সময় (RTT)'
              : 'Round-trip response time',
          trailing: TextButton.icon(
            icon: const Icon(Icons.refresh_rounded, size: 14),
            label: Text(isBn ? 'পিং' : 'Ping'),
            onPressed: () async {
              final newNet = await NetworkProbeService.instance.probeNetwork();
              if (mounted) {
                setState(() {
                  if (_report != null) {
                    _report = DiagnosticReport(
                      timestamp: _report!.timestamp,
                      hardware: _report!.hardware,
                      permissions: _report!.permissions,
                      network: newNet,
                      performance: _report!.performance,
                    );
                  }
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceSection(bool isBn, bool isDark) {
    final perf = _report!.performance;

    return DiagnosticCategoryCard(
      icon: Icons.bolt_rounded,
      title: isBn
          ? 'অ্যাপ পারফরম্যান্স ও রেসপন্সিভনেস'
          : 'App Performance & Responsiveness',
      subtitle: isBn ? 'ফ্রেম রেন্ডারিং ও স্টার্টআপ' : 'Frame Timing & Startup',
      trailing: DiagnosticStatusBadge(
        status: perf.responsiveness,
        compact: true,
      ),
      children: [
        HardwareSpecTile(
          icon: Icons.timer_outlined,
          title: isBn ? 'স্টার্টআপ সময়' : 'App Startup Duration',
          value: '${perf.startupDurationMs} ms',
          subtitle: isBn
              ? 'বুটস্ট্র্যাপ থেকে প্রথম ফ্রেম রেন্ডার'
              : 'Bootstrap initialization to first paint',
        ),
        HardwareSpecTile(
          icon: Icons.speed_outlined,
          title: isBn ? 'UI রাস্টার সময়' : 'UI Frame Raster Duration',
          value: '${perf.recentFrameRasterDurationMs.toStringAsFixed(1)} ms',
          subtitle: perf.recentFrameRasterDurationMs <= 16.67
              ? (isBn
                    ? '৬০ এফপিএস স্মুথ রেন্ডারিং'
                    : '60 FPS Smooth Render Target')
              : (isBn ? '৩২ এফপিএস রেন্ডারিং' : 'Acceptable Frame Timing'),
        ),
        HardwareSpecTile(
          icon: Icons.storage_rounded,
          title: isBn ? 'স্টোরেজ অবস্থা' : 'Internal Storage Health',
          value: perf.estimatedStorageStatus,
        ),
      ],
    );
  }
}
