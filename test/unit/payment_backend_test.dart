import 'package:flutter_test/flutter_test.dart';
import 'package:skavia/features/billing/data/datasources/sslcommerz_gateway_service.dart';
import 'package:skavia/features/billing/data/models/payment_transaction_model.dart';
import 'package:skavia/features/billing/presentation/controllers/payment_controller.dart';

void main() {
  group('SKAVIA SRS Section 3.1.O & 3.1.P - Payment & Worker Earnings Unit Tests', () {
    late PaymentController controller;

    setUp(() {
      controller = PaymentController();
    });

    test('FR-O01 & FR-P01: Fee calculation separates worker payment and SKAVIA platform fee', () {
      const double totalAmount = 2500.0; // e.g. R32 Gas Refill
      final split = controller.calculateFeeSplit(totalAmount);

      expect(split['totalAmount'], equals(2500.0));
      expect(split['skaviaFee'], equals(375.0)); // 15% of 2500
      expect(split['workerAmount'], equals(2125.0)); // 85% of 2500
      expect(split['workerAmount']! + split['skaviaFee']!, equals(totalAmount));
    });

    test('FR-O01: Platform fee percentage can be configured dynamically', () {
      controller.setPlatformFeePercentage(0.10); // 10% promotional fee
      final split = controller.calculateFeeSplit(1000.0);

      expect(split['skaviaFee'], equals(100.0));
      expect(split['workerAmount'], equals(900.0));
    });

    test('FR-O02: PaymentModel supports defined status lifecycle states', () {
      final validStatuses = ['Pending', 'Completed', 'Failed', 'Refunded'];

      for (final status in validStatuses) {
        final payment = PaymentModel(
          paymentId: 'pay-001',
          clientId: 'client-usr-123',
          totalAmount: 1500.0,
          skaviaFee: 225.0,
          status: status,
          createdAt: DateTime(2026, 9, 28),
        );

        expect(payment.status, equals(status));
        expect(payment.workerAmount, equals(1275.0));
      }
    });

    test('FR-O02 & Data Models: PaymentModel JSON roundtrip preserves all financial fields', () {
      final payment = PaymentModel(
        paymentId: 'pay-999',
        serviceRequestId: 'req-456',
        projectId: null,
        clientId: 'user-client-789',
        totalAmount: 3500.0,
        skaviaFee: 525.0,
        status: 'Completed',
        paidAt: DateTime(2026, 9, 28, 14, 30),
        createdAt: DateTime(2026, 9, 28, 14, 0),
      );

      final json = payment.toJson();
      final fromJson = PaymentModel.fromJson(json);

      expect(fromJson.paymentId, equals(payment.paymentId));
      expect(fromJson.serviceRequestId, equals(payment.serviceRequestId));
      expect(fromJson.projectId, isNull);
      expect(fromJson.clientId, equals(payment.clientId));
      expect(fromJson.totalAmount, equals(3500.0));
      expect(fromJson.skaviaFee, equals(525.0));
      expect(fromJson.workerAmount, equals(2975.0));
      expect(fromJson.status, equals('Completed'));
      expect(fromJson.paidAt, isNotNull);
    });

    test('FR-O04: InvoiceModel records itemized amounts and invoice number', () {
      final invoice = InvoiceModel(
        invoiceId: 'inv-001',
        paymentId: 'pay-001',
        invoiceNumber: 'INV-202609-123456',
        clientName: 'Rahim Chowdhury',
        workerAmount: 850.0,
        skaviaFee: 150.0,
        totalAmount: 1000.0,
        issuedAt: DateTime(2026, 9, 28),
      );

      final json = invoice.toJson();
      final fromJson = InvoiceModel.fromJson(json);

      expect(fromJson.invoiceNumber, startsWith('INV-'));
      expect(fromJson.clientName, equals('Rahim Chowdhury'));
      expect(fromJson.workerAmount, equals(850.0));
      expect(fromJson.skaviaFee, equals(150.0));
      expect(fromJson.totalAmount, equals(1000.0));
    });

    test('FR-P01 & FR-P02: WorkerEarningModel tracks earning status and credited amount', () {
      final earning = WorkerEarningModel(
        earningId: 'earn-001',
        workerProfileId: 'worker-prof-777',
        paymentId: 'pay-001',
        amount: 2125.0,
        status: 'Available',
        createdAt: DateTime(2026, 9, 28),
      );

      final json = earning.toJson();
      final fromJson = WorkerEarningModel.fromJson(json);

      expect(fromJson.earningId, equals('earn-001'));
      expect(fromJson.workerProfileId, equals('worker-prof-777'));
      expect(fromJson.amount, equals(2125.0));
      expect(fromJson.status, equals('Available'));
    });

    test('FR-O03: SslCommerzGatewayService handles sandbox endpoint switching correctly', () {
      final sandboxGateway = SslCommerzGatewayService(isSandbox: true);
      final liveGateway = SslCommerzGatewayService(isSandbox: false);

      expect(sandboxGateway.isSandbox, isTrue);
      expect(liveGateway.isSandbox, isFalse);
    });

    test('PaymentController state management and failure handling', () {
      expect(controller.state, equals(PaymentState.initial));
      expect(controller.isLoading, isFalse);

      controller.handlePaymentFailure('User canceled payment on SSLCommerz portal');

      expect(controller.state, equals(PaymentState.failed));
      expect(controller.errorMessage, contains('User canceled'));

      controller.reset();
      expect(controller.state, equals(PaymentState.initial));
      expect(controller.errorMessage, isNull);
    });
  });
}
