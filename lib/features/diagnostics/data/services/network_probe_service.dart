import 'dart:async';

import 'package:http/http.dart' as http;

import '../../domain/entities/network_benchmark.dart';
import '../../domain/enums/diagnostic_status.dart';

/// Lightweight network probe service measuring connection health and edge latency.
class NetworkProbeService {
  static final NetworkProbeService instance = NetworkProbeService._internal();
  factory NetworkProbeService() => instance;
  NetworkProbeService._internal();

  static const String defaultEdgePingEndpoint = 'https://1.1.1.1';

  Future<NetworkBenchmark> probeNetwork({
    String endpoint = defaultEdgePingEndpoint,
    Duration timeout = const Duration(seconds: 4),
    http.Client? client,
  }) async {
    final httpClient = client ?? http.Client();
    final stopwatch = Stopwatch()..start();

    try {
      final uri = Uri.parse(endpoint);
      final response = await httpClient.head(uri).timeout(timeout);
      stopwatch.stop();

      final latency = stopwatch.elapsedMilliseconds;
      final isSuccess = response.statusCode >= 200 && response.statusCode < 400;

      DiagnosticStatus quality;
      if (!isSuccess) {
        quality = DiagnosticStatus.limited;
      } else if (latency < 150) {
        quality = DiagnosticStatus.supported; // Excellent edge latency
      } else if (latency < 500) {
        quality = DiagnosticStatus.limited; // Tolerable mobile latency
      } else {
        quality = DiagnosticStatus.limited; // High latency
      }

      String connType;
      if (latency < 80) {
        connType = '5G / Ultra-Fast Broadband';
      } else if (latency < 200) {
        connType = '4G LTE / High-Speed';
      } else {
        connType = 'Mobile Data / Standard Connection';
      }

      return NetworkBenchmark(
        isOnline: isSuccess,
        latencyMs: latency,
        testEndpoint: endpoint,
        quality: quality,
        connectionType: connType,
      );
    } catch (_) {
      stopwatch.stop();
      return NetworkBenchmark(
        isOnline: false,
        latencyMs: stopwatch.elapsedMilliseconds > 0
            ? stopwatch.elapsedMilliseconds
            : -1,
        testEndpoint: endpoint,
        quality: DiagnosticStatus.unsupported,
        connectionType: 'Disconnected / Unreachable',
      );
    } finally {
      if (client == null) {
        httpClient.close();
      }
    }
  }
}
