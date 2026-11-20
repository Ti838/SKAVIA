import '../enums/diagnostic_status.dart';

/// Privacy-safe device hardware information (no IMEI, serials, or persistent IDs).
class HardwareTelemetry {
  final String manufacturer;
  final String model;
  final String osName;
  final String osVersion;
  final int sdkInt;
  final List<String> supportedAbis;
  final bool isPhysicalDevice;
  final String deviceType;

  const HardwareTelemetry({
    required this.manufacturer,
    required this.model,
    required this.osName,
    required this.osVersion,
    required this.sdkInt,
    required this.supportedAbis,
    required this.isPhysicalDevice,
    required this.deviceType,
  });

  /// SKAVIA requires Android 7.0 Nougat (API 24+) minimum.
  bool get isMinSdkSatisfied => sdkInt >= 24;

  /// Check if 64-bit ARM architecture is present.
  bool get is64BitArm => supportedAbis.any(
    (abi) =>
        abi.toLowerCase().contains('arm64') ||
        abi.toLowerCase().contains('aarch64'),
  );

  DiagnosticStatus get compatibilityStatus {
    if (!isMinSdkSatisfied) {
      return DiagnosticStatus.unsupported;
    }
    if (is64BitArm) {
      return DiagnosticStatus.supported;
    }
    // 32-bit devices are supported in limited legacy mode via ARMv7 build
    return DiagnosticStatus.limited;
  }

  Map<String, dynamic> toJson() => {
    'manufacturer': manufacturer,
    'model': model,
    'os_name': osName,
    'os_version': osVersion,
    'sdk_int': sdkInt,
    'supported_abis': supportedAbis,
    'is_physical_device': isPhysicalDevice,
    'device_type': deviceType,
    'is_min_sdk_satisfied': isMinSdkSatisfied,
    'is_64_bit_arm': is64BitArm,
    'compatibility_status': compatibilityStatus.name,
  };
}
