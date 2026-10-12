import 'package:flutter/foundation.dart';

import '../../../../app/config/app_config.dart';
import '../../data/datasources/payment_remote_datasource.dart';
import '../../data/datasources/sslcommerz_gateway_service.dart';
import '../../data/models/payment_transaction_model.dart';

enum PaymentState {
  initial,
  loading,
  sessionCreated,
  processing,
  success,
  failed,
}

/// Controller managing Payment, Checkout, and Invoice operations.
/// Strictly implements SRS Section 3.1.O (FR-O01 to FR-O05) and Section 3.1.P (FR-P01 to FR-P04).
class PaymentController extends ChangeNotifier {
  final PaymentRemoteDataSource _remoteDataSource;
  final SslCommerzGatewayService _gatewayService;

  PaymentController({
    PaymentRemoteDataSource? remoteDataSource,
    SslCommerzGatewayService? gatewayService,
  }) : _remoteDataSource = remoteDataSource ?? PaymentRemoteDataSource(),
       _gatewayService = gatewayService ?? SslCommerzGatewayService();

  PaymentState _state = PaymentState.initial;
  PaymentState get state => _state;

  bool get isLoading =>
      _state == PaymentState.loading || _state == PaymentState.processing;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  PaymentModel? _currentPayment;
  PaymentModel? get currentPayment => _currentPayment;

  TransactionModel? _currentTransaction;
  TransactionModel? get currentTransaction => _currentTransaction;

  InvoiceModel? _currentInvoice;
  InvoiceModel? get currentInvoice => _currentInvoice;

  WorkerEarningModel? _currentWorkerEarning;
  WorkerEarningModel? get currentWorkerEarning => _currentWorkerEarning;

  String? _gatewayPageUrl;
  String? get gatewayPageUrl => _gatewayPageUrl;

  // Platform Fee Percentage (Default 15% from AppConfig)
  double _platformFeePercentage = AppConfig.skaviaPlatformFeePercent;
  double get platformFeePercentage => _platformFeePercentage;

  void setPlatformFeePercentage(double percentage) {
    _platformFeePercentage = percentage;
    notifyListeners();
  }

  /// Calculates fee split transparently (SRS FR-O01 & FR-P01)
  /// Total Amount = Worker Amount + SKAVIA Fee
  Map<String, double> calculateFeeSplit(double totalAmount) {
    final skaviaFee = totalAmount * _platformFeePercentage;
    final workerAmount = totalAmount - skaviaFee;
    return {
      'totalAmount': totalAmount,
      'workerAmount': workerAmount,
      'skaviaFee': skaviaFee,
    };
  }

  /// 1. Initialize a pending payment in Supabase and initiate SSLCommerz session
  Future<String?> initiateCheckout({
    required String clientId,
    String? serviceRequestId,
    String? projectId,
    required double totalAmount,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    String? workerProfileId,
    String serviceTitle = 'SKAVIA On-Demand Service',
  }) async {
    // Prevent accidental duplicate payment attempts from repeated button presses
    if (isLoading) {
      return null;
    }

    _state = PaymentState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final feeSplit = calculateFeeSplit(totalAmount);
      final skaviaFee = feeSplit['skaviaFee']!;

      // 1. Record pending payment in Supabase (FR-O02)
      _currentPayment = await _remoteDataSource.createPendingPayment(
        clientId: clientId,
        serviceRequestId: serviceRequestId,
        projectId: projectId,
        totalAmount: totalAmount,
        skaviaFee: skaviaFee,
      );

      final tranId = 'SKV-${DateTime.now().millisecondsSinceEpoch}';

      // 2. Call SSLCommerz Gateway API
      final result = await _gatewayService.initiatePayment(
        tranId: tranId,
        totalAmount: totalAmount,
        customerName: customerName,
        customerEmail: customerEmail,
        customerPhone: customerPhone,
        productName: serviceTitle,
        paymentId: _currentPayment!.paymentId,
      );

      if (result.isSuccess && result.gatewayUrl != null) {
        _gatewayPageUrl = result.gatewayUrl;
        _state = PaymentState.sessionCreated;
        notifyListeners();
        return _gatewayPageUrl;
      } else {
        _state = PaymentState.failed;
        _errorMessage =
            result.errorMessage ??
            'Failed to initialize payment gateway session.';
        notifyListeners();
        return null;
      }
    } catch (e) {
      _state = PaymentState.failed;
      _errorMessage = 'Payment error: $e';
      notifyListeners();
      return null;
    }
  }

  /// 2. Authoritatively verify backend settlement when user returns from SSLCommerz WebView
  /// Never marks payment completed solely on browser/app redirect.
  Future<bool> handlePaymentSuccess({
    required String gatewayTxId,
    required String gatewayName,
    required String clientName,
    String? workerProfileId,
  }) async {
    if (_currentPayment == null) {
      _errorMessage = 'No active payment session found.';
      _state = PaymentState.failed;
      notifyListeners();
      return false;
    }

    _state = PaymentState.processing;
    notifyListeners();

    try {
      // Step A: Check if authoritative server-side IPN has already settled this payment
      final backendSettlement = await _remoteDataSource.verifyBackendSettlement(
        paymentId: _currentPayment!.paymentId,
        maxAttempts: 3,
        retryInterval: const Duration(seconds: 1),
      );

      if (backendSettlement != null) {
        _currentPayment = backendSettlement.payment;
        _currentTransaction = backendSettlement.transaction;
        _currentInvoice = backendSettlement.invoice;
        _currentWorkerEarning = backendSettlement.workerEarning;
        _state = PaymentState.success;
        notifyListeners();
        return true;
      }

      // Step B: Attempt remote RPC if configured (fails safely if client-role RPC is revoked)
      final feeSplit = calculateFeeSplit(_currentPayment!.totalAmount);
      final workerAmount = feeSplit['workerAmount']!;
      final skaviaFee = feeSplit['skaviaFee']!;

      final result = await _remoteDataSource.completePaymentTransaction(
        paymentId: _currentPayment!.paymentId,
        gatewayTxId: gatewayTxId,
        gatewayName: gatewayName,
        totalAmount: _currentPayment!.totalAmount,
        workerAmount: workerAmount,
        skaviaFee: skaviaFee,
        clientName: clientName,
        workerProfileId: workerProfileId,
      );

      _currentPayment = result.payment;
      _currentTransaction = result.transaction;
      _currentInvoice = result.invoice;
      _currentWorkerEarning = result.workerEarning;

      _state = PaymentState.success;
      notifyListeners();
      return true;
    } catch (e) {
      _state = PaymentState.failed;
      _errorMessage = 'Failed to record completed payment: $e';
      notifyListeners();
      return false;
    }
  }

  /// Authoritatively check payment status from backend (for app reopen, refresh, or delayed callback)
  Future<PaymentModel?> checkPaymentStatus(String paymentId) async {
    final payment = await _remoteDataSource.getPayment(paymentId);
    if (payment != null) {
      _currentPayment = payment;
      if (payment.status == 'Completed') {
        _state = PaymentState.success;
        _currentInvoice = await _remoteDataSource.getInvoiceByPaymentId(
          paymentId,
        );
        _currentTransaction = await _remoteDataSource.getTransactionByPaymentId(
          paymentId,
        );
      } else if (payment.status == 'Failed') {
        _state = PaymentState.failed;
        _errorMessage = 'Payment failed at gateway.';
      }
      notifyListeners();
    }
    return payment;
  }

  /// 3. Handle payment cancellation or failure
  void handlePaymentFailure(String reason) {
    _state = PaymentState.failed;
    _errorMessage = reason;
    notifyListeners();
  }

  void reset() {
    _state = PaymentState.initial;
    _errorMessage = null;
    _gatewayPageUrl = null;
    notifyListeners();
  }
}
