import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Standard diagnostic status states strictly complying with SKAVIA specifications.
enum DiagnosticStatus {
  supported,
  limited,
  unsupported,
  notTested,
  permissionRequired,
  notApplicable;

  String get labelEn {
    switch (this) {
      case DiagnosticStatus.supported:
        return 'Supported';
      case DiagnosticStatus.limited:
        return 'Limited';
      case DiagnosticStatus.unsupported:
        return 'Unsupported';
      case DiagnosticStatus.notTested:
        return 'Not Tested';
      case DiagnosticStatus.permissionRequired:
        return 'Permission Required';
      case DiagnosticStatus.notApplicable:
        return 'Not Used by SKAVIA';
    }
  }

  String get labelBn {
    switch (this) {
      case DiagnosticStatus.supported:
        return 'সমর্থিত (Supported)';
      case DiagnosticStatus.limited:
        return 'সীমিত (Limited)';
      case DiagnosticStatus.unsupported:
        return 'অসমর্থিত (Unsupported)';
      case DiagnosticStatus.notTested:
        return 'পরীক্ষিত নয়';
      case DiagnosticStatus.permissionRequired:
        return 'অনুমতি প্রয়োজন';
      case DiagnosticStatus.notApplicable:
        return 'ব্যবহৃত নয়';
    }
  }

  Color get color {
    switch (this) {
      case DiagnosticStatus.supported:
        return AppColors.successGreen;
      case DiagnosticStatus.limited:
        return AppColors.warningAmber;
      case DiagnosticStatus.unsupported:
        return AppColors.errorRed;
      case DiagnosticStatus.notTested:
        return const Color(0xFF64748B); // Slate muted
      case DiagnosticStatus.permissionRequired:
        return const Color(0xFFE11D48); // Rose
      case DiagnosticStatus.notApplicable:
        return const Color(0xFF94A3B8); // Slate subtle
    }
  }

  IconData get icon {
    switch (this) {
      case DiagnosticStatus.supported:
        return Icons.check_circle_rounded;
      case DiagnosticStatus.limited:
        return Icons.warning_amber_rounded;
      case DiagnosticStatus.unsupported:
        return Icons.cancel_rounded;
      case DiagnosticStatus.notTested:
        return Icons.help_outline_rounded;
      case DiagnosticStatus.permissionRequired:
        return Icons.lock_outline_rounded;
      case DiagnosticStatus.notApplicable:
        return Icons.remove_circle_outline_rounded;
    }
  }
}
