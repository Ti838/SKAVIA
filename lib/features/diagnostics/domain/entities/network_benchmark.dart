import '../enums/diagnostic_status.dart';

/// Network connectivity and latency probe metrics.
class NetworkBenchmark {
  final bool isOnline;
  final int latencyMs;
  final String testEndpoint;
  final DiagnosticStatus quality;
  final String? connectionType;

  const NetworkBenchmark({
    required this.isOnline,
    required this.latencyMs,
    required this.testEndpoint,
    required this.quality,
    this.connectionType,
  });

  const NetworkBenchmark.initial()
    : isOnline = false,
      latencyMs = -1,
      testEndpoint = 'https://1.1.1.1',
      quality = DiagnosticStatus.notTested,
      connectionType = 'Unknown';

  Map<String, dynamic> toJson() => {
    'is_online': isOnline,
    'latency_ms': latencyMs,
    'test_endpoint': testEndpoint,
    'quality': quality.name,
    'connection_type': connectionType,
  };
}
