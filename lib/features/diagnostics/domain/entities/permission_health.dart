import '../enums/diagnostic_status.dart';

/// Status of runtime and system permissions required by SKAVIA workflows.
class PermissionHealth {
  final DiagnosticStatus camera;
  final DiagnosticStatus location;
  final DiagnosticStatus notifications;
  final DiagnosticStatus microphone;
  final DiagnosticStatus storage;

  const PermissionHealth({
    required this.camera,
    required this.location,
    required this.notifications,
    required this.microphone,
    required this.storage,
  });

  const PermissionHealth.initial()
      : camera = DiagnosticStatus.notTested,
        location = DiagnosticStatus.notTested,
        notifications = DiagnosticStatus.notTested,
        microphone = DiagnosticStatus.notApplicable,
        storage = DiagnosticStatus.notTested;

  Map<String, dynamic> toJson() => {
        'camera': camera.name,
        'location': location.name,
        'notifications': notifications.name,
        'microphone': microphone.name,
        'storage': storage.name,
      };
}
