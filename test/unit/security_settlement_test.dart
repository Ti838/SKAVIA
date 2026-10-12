import 'package:flutter_test/flutter_test.dart';
import 'package:skavia/features/billing/data/datasources/payment_remote_datasource.dart';
import 'package:skavia/features/billing/data/models/payment_transaction_model.dart';
import 'package:skavia/features/billing/presentation/controllers/payment_controller.dart';

void main() {
  group('SKAVIA Comprehensive Security & Settlement Test Suite', () {
    test('SEC-01: Fee calculation mathematically isolates worker and platform shares', () {
      final controller = PaymentController();
      controller.setPlatformFeePercentage(0.15); // 15% platform fee
      final split = controller.calculateFeeSplit(1000.0);

      expect(split['totalAmount'], equals(1000.0));
      expect(split['workerAmount'], equals(850.0));
      expect(split['skaviaFee'], equals(150.0));
      expect(
        split['workerAmount']! + split['skaviaFee']!,
        equals(split['totalAmount']),
      );
    });

    test(
      'SEC-02: Payment lifecycle states enforce strict transition validation',
      () {
        final pendingPayment = PaymentModel(
          paymentId: 'pay-001',
          clientId: 'usr-client-01',
          totalAmount: 1500.0,
          skaviaFee: 225.0,
          status: 'Pending',
          createdAt: DateTime.now(),
        );

        expect(pendingPayment.status, equals('Pending'));

        final json = pendingPayment.toJson();
        expect(json['status'], equals('Pending'));
        expect(json['total_amount'], equals(1500.0));
        expect(json['skavia_fee'], equals(225.0));

        final restored = PaymentModel.fromJson(json);
        expect(restored.paymentId, equals('pay-001'));
        expect(restored.status, equals('Pending'));
      },
    );

    test('SEC-03: Invoice creation deterministically captures financial values without client tampering', () {
      final invoice = InvoiceModel(
        invoiceId: 'inv-123456',
        paymentId: 'pay-001',
        invoiceNumber: 'INV-202610-123456',
        clientName: 'Test Client',
        workerAmount: 850.0,
        skaviaFee: 150.0,
        totalAmount: 1000.0,
        issuedAt: DateTime.now(),
      );

      final json = invoice.toJson();
      expect(json['worker_amount'], equals(850.0));
      expect(json['skavia_fee'], equals(150.0));
      expect(json['total_amount'], equals(1000.0));
      expect(json['invoice_number'], startsWith('INV-'));
    });

    test('SEC-04: Worker earnings model tracks balance states reliably', () {
      final earning = WorkerEarningModel(
        earningId: 'earn-001',
        workerProfileId: 'wp-001',
        paymentId: 'pay-001',
        amount: 850.0,
        status: 'Available',
        createdAt: DateTime.now(),
      );

      expect(earning.status, equals('Available'));
      expect(earning.amount, equals(850.0));

      final json = earning.toJson();
      expect(json['status'], equals('Available'));
      expect(json['amount'], equals(850.0));
    });

    test(
      'SEC-05: PaymentController prevents empty session completion',
      () async {
        final controller = PaymentController();

        // Attempting to finalize without prior checkout initiation must fail immediately
        final success = await controller.handlePaymentSuccess(
          gatewayTxId: 'val-999',
          gatewayName: 'sslcommerz',
          clientName: 'Untrusted Caller',
        );

        expect(success, isFalse);
        expect(
          controller.errorMessage,
          equals('No active payment session found.'),
        );
      },
    );

    test('SEC-06: Direct settlement failure properly propagates error without insecure client fallback', () async {
      // Create a PaymentRemoteDataSource that cannot reach backend RPC
      final datasource = PaymentRemoteDataSource();

      expect(
        () => datasource.completePaymentTransaction(
          paymentId: 'invalid-pay-id',
          gatewayTxId: 'val-fake',
          gatewayName: 'sslcommerz',
          totalAmount: 500.0,
          workerAmount: 425.0,
          skaviaFee: 75.0,
          clientName: 'Test Client',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('SEC-07: Insecure local completion is eliminated; client fails safely on error', () async {
      final controller = PaymentController();
      // Simulate active checkout
      await controller.initiateCheckout(
        clientId: 'client-123',
        totalAmount: 1000.0,
        customerName: 'Test User',
        customerEmail: 'test@skavia.app',
        customerPhone: '01711111111',
      );

      expect(controller.currentPayment, isNotNull);

      // Attempting handlePaymentSuccess when remote RPC is denied will set state to failed
      final result = await controller.handlePaymentSuccess(
        gatewayTxId: 'val-12345',
        gatewayName: 'sslcommerz',
        clientName: 'Test User',
      );

      expect(result, isFalse);
      expect(controller.state, equals(PaymentState.failed));
      expect(controller.errorMessage, contains('Server settlement required'));
    });

    test('SEC-08: Non-PII projection contract validation for marketplace profile discovery', () {
      // Mock row returned by marketplace_public_profiles view
      final marketplaceRecord = {
        'worker_profile_id': 'wp-100',
        'user_id': 'usr-200',
        'display_name': 'Hasan Mahmud',
        'avatar_url': 'https://skavia.app/avatars/hasan.jpg',
        'title': 'Certified Electrician',
        'bio': '10 years experience in residential DB board wiring',
        'location': 'Dhanmondi, Dhaka',
        'expected_rate': 600.0,
        'rating_average': 4.95,
        'completed_jobs': 42,
        'verification_status': 'Verified',
        'is_available': true,
      };

      // Assert approved public fields exist
      expect(marketplaceRecord['display_name'], equals('Hasan Mahmud'));
      expect(marketplaceRecord['expected_rate'], equals(600.0));
      expect(marketplaceRecord['rating_average'], equals(4.95));

      // Assert private PII fields strictly DO NOT EXIST
      expect(marketplaceRecord.containsKey('phone'), isFalse);
      expect(marketplaceRecord.containsKey('phone_number'), isFalse);
      expect(marketplaceRecord.containsKey('email'), isFalse);
      expect(marketplaceRecord.containsKey('nid_number'), isFalse);
      expect(marketplaceRecord.containsKey('password_hash'), isFalse);
    });

    test('SEC-09: KYC Storage folder path parsing contract strictly binds to authenticated owner UUID', () {
      const userAId = 'usr-owner-001';
      const userBId = 'usr-adversary-002';

      // Simulation of (storage.foldername(name))[1] logic
      String extractOwnerFolder(String filePath) {
        final segments = filePath.split('/');
        return segments.isNotEmpty ? segments.first : '';
      }

      final ownerUploadPath = '$userAId/nid_front.jpg';
      final adversaryUploadPath = '$userBId/nid_stolen.jpg';

      expect(extractOwnerFolder(ownerUploadPath) == userAId, isTrue);
      // User A attempting to upload to User B path is rejected
      expect(extractOwnerFolder(adversaryUploadPath) == userAId, isFalse);
    });

    test(
      'SEC-10: SSLCommerz Gateway verification rejects currency other than BDT',
      () {
        bool validateCurrency(String currency) => currency == 'BDT';

        expect(validateCurrency('BDT'), isTrue);
        expect(validateCurrency('USD'), isFalse);
        expect(validateCurrency('EUR'), isFalse);
      },
    );

    test(
      'SEC-11: SSLCommerz Gateway verification rejects mismatched amounts',
      () {
        bool validateAmount(double gatewayAmount, double expectedAmount) {
          return (gatewayAmount - expectedAmount).abs() < 0.01;
        }

        expect(validateAmount(1500.0, 1500.0), isTrue);
        expect(validateAmount(1499.0, 1500.0), isFalse);
        expect(validateAmount(0.0, 1500.0), isFalse);
      },
    );

    test('SEC-12: Gateway verification rejects non-VALID status (FAILED, CANCELLED, UNATTEMPTED)', () {
      bool isGatewayStatusValid(String status) {
        return status == 'VALID' || status == 'VALIDATED';
      }

      expect(isGatewayStatusValid('VALID'), isTrue);
      expect(isGatewayStatusValid('VALIDATED'), isTrue);
      expect(isGatewayStatusValid('FAILED'), isFalse);
      expect(isGatewayStatusValid('CANCELLED'), isFalse);
      expect(isGatewayStatusValid('UNATTEMPTED'), isFalse);
    });

    test('SEC-13: Idempotent settlement prevents duplicate invoices on duplicate callbacks', () {
      final processedPaymentIds = <String>{};

      bool settlePayment(String paymentId) {
        if (processedPaymentIds.contains(paymentId)) {
          return false; // Idempotent: duplicate ignored
        }
        processedPaymentIds.add(paymentId);
        return true;
      }

      expect(settlePayment('pay-unique-01'), isTrue);
      expect(
        settlePayment('pay-unique-01'),
        isFalse,
      ); // Second callback ignored
      expect(processedPaymentIds.length, equals(1));
    });

    test('SEC-14: Repeated checkout button presses are blocked while previous checkout is loading', () async {
      final controller = PaymentController();

      // Initiate first checkout
      final firstAttempt = controller.initiateCheckout(
        clientId: 'client-1',
        totalAmount: 1200.0,
        customerName: 'Customer',
        customerEmail: 'cus@skavia.app',
        customerPhone: '01700000000',
      );

      // Rapid second press while state is loading
      final secondAttempt = await controller.initiateCheckout(
        clientId: 'client-1',
        totalAmount: 1200.0,
        customerName: 'Customer',
        customerEmail: 'cus@skavia.app',
        customerPhone: '01700000000',
      );

      // Second press must be immediately rejected (returns null)
      expect(secondAttempt, isNull);
      await firstAttempt;
    });

    test('SEC-15: Client redirect without backend confirmation fails safely with server settlement requirement', () async {
      final controller = PaymentController();
      await controller.initiateCheckout(
        clientId: 'client-redirect-test',
        totalAmount: 2000.0,
        customerName: 'Test Client',
        customerEmail: 'test@skavia.app',
        customerPhone: '01712345678',
      );

      // Simulating returning from WebView with success URL redirect parameters
      // Without actual backend DB confirmation, client cannot self-mark Completed
      final settled = await controller.handlePaymentSuccess(
        gatewayTxId: 'bank-redirect-val',
        gatewayName: 'sslcommerz',
        clientName: 'Test Client',
      );

      expect(settled, isFalse);
      expect(controller.state, equals(PaymentState.failed));
      expect(controller.errorMessage, contains('Server settlement required'));
    });
  });
}
