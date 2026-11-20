import '../enums/diagnostic_status.dart';

/// App startup and UI responsiveness metrics.
class PerformanceTelemetry {
  final int startupDurationMs;
  final DiagnosticStatus responsiveness;
  final double recentFrameRasterDurationMs;
  final String estimatedStorageStatus;

  const PerformanceTelemetry({
    required this.startupDurationMs,
    required this.responsiveness,
    required this.recentFrameRasterDurationMs,
    required this.estimatedStorageStatus,
  });

  const PerformanceTelemetry.initial()
      : startupDurationMs = 0,
        responsiveness = DiagnosticStatus.notTested,
        recentFrameRasterDurationMs = 0.0,
        estimatedStorageStatus = 'Checking...';

  Map<String, dynamic> toJson() => {
        'startup_duration_ms': startupDurationMs,
        'responsiveness': responsiveness.name,
        'recent_frame_raster_duration_ms': recentFrameRasterDurationMs,
        'estimated_storage_status': estimatedStorageStatus,
      };
}
