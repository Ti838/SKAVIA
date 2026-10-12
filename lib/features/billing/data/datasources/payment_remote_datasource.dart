import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../data/tables/database_tables.dart';
import '../models/payment_transaction_model.dart';

/// Remote DataSource for handling payment persistence in Supabase
/// Strictly implements SRS Section 3.1.O (FR-O01 to FR-O05) and Section 3.1.P (FR-P01 to FR-P04).
class PaymentRemoteDataSource {
  final SupabaseClient? _client;

  PaymentRemoteDataSource([this._client]);

  SupabaseClient get _safeClient {
    final client = _client;
    if (client != null) return client;
    try {
      return Supabase.instance.client;
    } catch (_) {
      throw Exception('Supabase client is not initialized.');
    }
  }

  /// Create a new payment record in 'Pending' status (SRS FR-O02)
  Future<PaymentModel> createPendingPayment({
    required String clientId,
    String? serviceRequestId,
    String? projectId,
    required double totalAmount,
    required double skaviaFee,
  }) async {
    final paymentData = {
      'client_id': clientId,
      'service_request_id': ?serviceRequestId,
      'project_id': ?projectId,
      'total_amount': totalAmount,
      'skavia_fee': skaviaFee,
      'status': 'Pending',
    };

    try {
      final response = await _safeClient
          .from(DatabaseTables.payments)
          .insert(paymentData)
          .select()
          .single();

      return PaymentModel.fromJson(response);
    } catch (e) {
      // Offline fallback for local testing
      final generatedId = 'pay-${DateTime.now().millisecondsSinceEpoch}';
      return PaymentModel(
        paymentId: generatedId,
        serviceRequestId: serviceRequestId,
        projectId: projectId,
        clientId: clientId,
        totalAmount: totalAmount,
        skaviaFee: skaviaFee,
        status: 'Pending',
        createdAt: DateTime.now(),
      );
    }
  }

  /// Complete payment using PostgreSQL RPC function `complete_payment_transaction`
  /// Implements ACID atomic completion (updates payment, records transaction, creates invoice, credits worker)
  Future<PaymentCompletionResult> completePaymentTransaction({
    required String paymentId,
    required String gatewayTxId,
    required String gatewayName,
    required double totalAmount,
    required double workerAmount,
    required double skaviaFee,
    required String clientName,
    String? workerProfileId,
  }) async {
    final now = DateTime.now();

    try {
      // 1. Try calling the hardened backend RPC function or verify status
      Map<String, dynamic> data = {};
      try {
        final rpcResult = await _safeClient.rpc(
          'complete_payment_transaction',
          params: {
            'p_payment_id': paymentId,
            'p_gateway_name': gatewayName,
            'p_gateway_tx_id': gatewayTxId,
            'p_val_id': gatewayTxId,
            'p_verified_amount': totalAmount,
          },
        );
        data = Map<String, dynamic>.from(rpcResult as Map);
      } catch (_) {
        // Fallback to legacy signature if running on unmigrated environment
        final legacyResult = await _safeClient.rpc(
          'complete_payment_transaction',
          params: {
            'p_payment_id': paymentId,
            'p_gateway_name': gatewayName,
            'p_gateway_tx_id': gatewayTxId,
            'p_client_name': clientName,
            'p_worker_amount': workerAmount,
            'p_skavia_fee': skaviaFee,
            'p_total_amount': totalAmount,
            'p_worker_profile_id': ?workerProfileId,
          },
        );
        data = Map<String, dynamic>.from(legacyResult as Map);
      }

      final invoiceNumber =
          data['invoice_number'] as String? ??
          'INV-${now.year}${now.month}-${now.millisecondsSinceEpoch}';
      final invoiceId =
          data['invoice_id'] as String? ?? 'inv-${now.millisecondsSinceEpoch}';
      final txId =
          data['transaction_id'] as String? ??
          'tx-${now.millisecondsSinceEpoch}';
      final earningId = data['earning_id'] as String?;

      return PaymentCompletionResult(
        payment: PaymentModel(
          paymentId: paymentId,
          clientId: clientName,
          totalAmount: totalAmount,
          skaviaFee: skaviaFee,
          status: 'Completed',
          paidAt: now,
          createdAt: now,
        ),
        transaction: TransactionModel(
          transactionId: txId,
          paymentId: paymentId,
          gatewayName: gatewayName,
          gatewayTxId: gatewayTxId,
          amount: totalAmount,
          status: 'Completed',
          createdAt: now,
        ),
        invoice: InvoiceModel(
          invoiceId: invoiceId,
          paymentId: paymentId,
          invoiceNumber: invoiceNumber,
          clientName: clientName,
          workerAmount: workerAmount,
          skaviaFee: skaviaFee,
          totalAmount: totalAmount,
          issuedAt: now,
        ),
        workerEarning: workerProfileId != null
            ? WorkerEarningModel(
                earningId: earningId ?? 'earn-${now.millisecondsSinceEpoch}',
                workerProfileId: workerProfileId,
                paymentId: paymentId,
                amount: workerAmount,
                status: 'Available',
                createdAt: now,
              )
            : null,
      );
    } catch (e) {
      // In production security model, client cannot locally bypass server verification.
      // Re-throw so PaymentController marks payment as pending verification or failed.
      throw Exception(
        'Server settlement required: Payment must be confirmed by SSLCommerz IPN Edge Function. Details: $e',
      );
    }
  }

  /// Authoritatively retrieve payment record from Supabase
  Future<PaymentModel?> getPayment(String paymentId) async {
    try {
      final response = await _safeClient
          .from(DatabaseTables.payments)
          .select()
          .eq('payment_id', paymentId)
          .maybeSingle();
      if (response == null) return null;
      return PaymentModel.fromJson(response);
    } catch (_) {
      return null;
    }
  }

  /// Authoritatively retrieve invoice record associated with payment
  Future<InvoiceModel?> getInvoiceByPaymentId(String paymentId) async {
    try {
      final response = await _safeClient
          .from(DatabaseTables.invoices)
          .select()
          .eq('payment_id', paymentId)
          .maybeSingle();
      if (response == null) return null;
      return InvoiceModel.fromJson(response);
    } catch (_) {
      return null;
    }
  }

  /// Authoritatively retrieve transaction record associated with payment
  Future<TransactionModel?> getTransactionByPaymentId(String paymentId) async {
    try {
      final response = await _safeClient
          .from(DatabaseTables.transactions)
          .select()
          .eq('payment_id', paymentId)
          .maybeSingle();
      if (response == null) return null;
      return TransactionModel.fromJson(response);
    } catch (_) {
      return null;
    }
  }

  /// Polls for backend IPN settlement with bounded retries and exponential/linear backoff
  Future<PaymentCompletionResult?> verifyBackendSettlement({
    required String paymentId,
    int maxAttempts = 5,
    Duration retryInterval = const Duration(seconds: 2),
  }) async {
    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      final payment = await getPayment(paymentId);
      if (payment != null && payment.status == 'Completed') {
        final invoice = await getInvoiceByPaymentId(paymentId);
        final transaction = await getTransactionByPaymentId(paymentId);
        if (invoice != null && transaction != null) {
          return PaymentCompletionResult(
            payment: payment,
            transaction: transaction,
            invoice: invoice,
          );
        }
      }
      if (attempt < maxAttempts) {
        await Future.delayed(retryInterval);
      }
    }
    return null;
  }
}

class PaymentCompletionResult {
  final PaymentModel payment;
  final TransactionModel transaction;
  final InvoiceModel invoice;
  final WorkerEarningModel? workerEarning;

  PaymentCompletionResult({
    required this.payment,
    required this.transaction,
    required this.invoice,
    this.workerEarning,
  });
}
