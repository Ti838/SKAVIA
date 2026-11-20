import 'hardware_telemetry.dart';
import 'network_benchmark.dart';
import 'performance_telemetry.dart';
import 'permission_health.dart';

/// Aggregated, privacy-compliant diagnostic report of the SKAVIA mobile runtime.
class DiagnosticReport {
  final DateTime timestamp;
  final HardwareTelemetry hardware;
  final PermissionHealth permissions;
  final NetworkBenchmark network;
  final PerformanceTelemetry performance;

  const DiagnosticReport({
    required this.timestamp,
    required this.hardware,
    required this.permissions,
    required this.network,
    required this.performance,
  });

  Map<String, dynamic> toJson() => {
        'report_type': 'SKAVIA_DEVICE_DIAGNOSTICS',
        'generated_at': timestamp.toIso8601String(),
        'hardware': hardware.toJson(),
        'permissions': permissions.toJson(),
        'network': network.toJson(),
        'performance': performance.toJson(),
      };
}
