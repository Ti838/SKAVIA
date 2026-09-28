/// Centralized models for SKAVIA Payment, Invoicing, Transactions & Worker Earnings.
/// Aligned strictly with SRS Section 3.1.O (FR-O01 to FR-O05) and Section 3.1.P (FR-P01 to FR-P04).
library;

class PaymentModel {
  final String paymentId;
  final String? serviceRequestId;
  final String? projectId;
  final String clientId;
  final double totalAmount;
  final double skaviaFee;
  final String status; // 'Pending', 'Completed', 'Failed', 'Refunded'
  final DateTime? paidAt;
  final DateTime createdAt;

  PaymentModel({
    required this.paymentId,
    this.serviceRequestId,
    this.projectId,
    required this.clientId,
    required this.totalAmount,
    required this.skaviaFee,
    required this.status,
    this.paidAt,
    required this.createdAt,
  });

  double get workerAmount => totalAmount - skaviaFee;

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      paymentId: json['payment_id'] as String,
      serviceRequestId: json['service_request_id'] as String?,
      projectId: json['project_id'] as String?,
      clientId: json['client_id'] as String,
      totalAmount: (json['total_amount'] as num).toDouble(),
      skaviaFee: (json['skavia_fee'] as num).toDouble(),
      status: json['status'] as String? ?? 'Pending',
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at'] as String) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_id': paymentId,
      if (serviceRequestId != null) 'service_request_id': serviceRequestId,
      if (projectId != null) 'project_id': projectId,
      'client_id': clientId,
      'total_amount': totalAmount,
      'skavia_fee': skaviaFee,
      'status': status,
      if (paidAt != null) 'paid_at': paidAt!.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class TransactionModel {
  final String transactionId;
  final String paymentId;
  final String gatewayName;
  final String? gatewayTxId;
  final double amount;
  final String status;
  final DateTime createdAt;

  TransactionModel({
    required this.transactionId,
    required this.paymentId,
    required this.gatewayName,
    this.gatewayTxId,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      transactionId: json['transaction_id'] as String,
      paymentId: json['payment_id'] as String,
      gatewayName: json['gateway_name'] as String? ?? 'sslcommerz',
      gatewayTxId: json['gateway_tx_id'] as String?,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String? ?? 'Completed',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_id': transactionId,
      'payment_id': paymentId,
      'gateway_name': gatewayName,
      if (gatewayTxId != null) 'gateway_tx_id': gatewayTxId,
      'amount': amount,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class InvoiceModel {
  final String invoiceId;
  final String paymentId;
  final String invoiceNumber;
  final String clientName;
  final double workerAmount;
  final double skaviaFee;
  final double totalAmount;
  final DateTime issuedAt;
  final String? pdfUrl;

  InvoiceModel({
    required this.invoiceId,
    required this.paymentId,
    required this.invoiceNumber,
    required this.clientName,
    required this.workerAmount,
    required this.skaviaFee,
    required this.totalAmount,
    required this.issuedAt,
    this.pdfUrl,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      invoiceId: json['invoice_id'] as String,
      paymentId: json['payment_id'] as String,
      invoiceNumber: json['invoice_number'] as String,
      clientName: json['client_name'] as String,
      workerAmount: (json['worker_amount'] as num).toDouble(),
      skaviaFee: (json['skavia_fee'] as num).toDouble(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      issuedAt: json['issued_at'] != null ? DateTime.parse(json['issued_at'] as String) : DateTime.now(),
      pdfUrl: json['pdf_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'invoice_id': invoiceId,
      'payment_id': paymentId,
      'invoice_number': invoiceNumber,
      'client_name': clientName,
      'worker_amount': workerAmount,
      'skavia_fee': skaviaFee,
      'total_amount': totalAmount,
      'issued_at': issuedAt.toIso8601String(),
      if (pdfUrl != null) 'pdf_url': pdfUrl,
    };
  }
}

class WorkerEarningModel {
  final String earningId;
  final String workerProfileId;
  final String? paymentId;
  final double amount;
  final String status; // 'Pending', 'Available', 'Withdrawn'
  final DateTime createdAt;

  WorkerEarningModel({
    required this.earningId,
    required this.workerProfileId,
    this.paymentId,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  factory WorkerEarningModel.fromJson(Map<String, dynamic> json) {
    return WorkerEarningModel(
      earningId: json['earning_id'] as String,
      workerProfileId: json['worker_profile_id'] as String,
      paymentId: json['payment_id'] as String?,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String? ?? 'Available',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'earning_id': earningId,
      'worker_profile_id': workerProfileId,
      if (paymentId != null) 'payment_id': paymentId,
      'amount': amount,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
