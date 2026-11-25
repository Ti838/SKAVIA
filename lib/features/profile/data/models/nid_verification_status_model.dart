/// Status representation for citizen National ID (NID) compliance
enum NidStatus {
  unverified,
  pending,
  verified,
  rejected,
}

class NidVerificationStatusModel {
  final NidStatus status;
  final String? nidNumber;
  final String? fullName;
  final DateTime? submittedAt;
  final String? reviewNotes;

  const NidVerificationStatusModel({
    required this.status,
    this.nidNumber,
    this.fullName,
    this.submittedAt,
    this.reviewNotes,
  });

  bool get isVerified => status == NidStatus.verified;
  bool get isPending => status == NidStatus.pending;
  bool get isRejected => status == NidStatus.rejected;
  bool get isUnverified => status == NidStatus.unverified;

  String get maskedNid {
    if (nidNumber == null || nidNumber!.length < 6) return '••••••••••';
    final len = nidNumber!.length;
    final prefix = nidNumber!.substring(0, 3);
    final suffix = nidNumber!.substring(len - 3);
    return '$prefix••••••$suffix';
  }

  factory NidVerificationStatusModel.fromJson(Map<String, dynamic> json) {
    final rawStatus = (json['status']?.toString() ?? 'unverified').toLowerCase();
    final status = switch (rawStatus) {
      'verified' => NidStatus.verified,
      'pending' => NidStatus.pending,
      'rejected' => NidStatus.rejected,
      _ => NidStatus.unverified,
    };

    DateTime? submittedAt;
    if (json['submittedAt'] != null) {
      submittedAt = DateTime.tryParse(json['submittedAt'].toString());
    }

    return NidVerificationStatusModel(
      status: status,
      nidNumber: json['nidNumber']?.toString(),
      fullName: json['fullName']?.toString(),
      submittedAt: submittedAt,
      reviewNotes: json['reviewNotes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status.name,
    'nidNumber': nidNumber,
    'fullName': fullName,
    'submittedAt': submittedAt?.toIso8601String(),
    'reviewNotes': reviewNotes,
  };
}
