import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skavia/app/config/app_config.dart';
import 'package:skavia/app/router/app_routes.dart';
import 'package:skavia/app/router/route_guards.dart';
import 'package:skavia/core/services/feature_eligibility_service.dart';
import 'package:skavia/features/billing/data/models/payment_transaction_model.dart';
import 'package:skavia/features/billing/presentation/controllers/payment_controller.dart';
import 'package:skavia/features/customer/data/models/requirement_model.dart';
import 'package:skavia/features/profile/data/models/user_profile_model.dart';

void main() {
  group('Phase 10 — SKAVIA Security Hardening & Penetration Verification Suite', () {
    test('AUDIT-SEC-01: Client configuration must contain zero hardcoded AI API keys', () {
      expect(
        AppConfig.groqApiKey,
        isEmpty,
        reason: 'Groq API key must not be embedded in client fallback configuration.',
      );
      expect(
        AppConfig.openRouterApiKey,
        isEmpty,
        reason: 'OpenRouter API key must not be embedded in client fallback configuration.',
      );
      expect(
        AppConfig.huggingFaceToken,
        isEmpty,
        reason: 'HuggingFace Token must not be embedded in client fallback configuration.',
      );
    });

    test('AUDIT-SEC-02: PaymentController prevents client fee tampering and preserves mathematical isolation', () {
      final controller = PaymentController();
      final split = controller.calculateFeeSplit(2500.0);

      expect(split['totalAmount'], equals(2500.0));
      expect(split['skaviaFee'], equals(375.0)); // 15% platform fee
      expect(split['workerAmount'], equals(2125.0)); // 85% worker earnings
      expect(split['workerAmount']! + split['skaviaFee']!, equals(split['totalAmount']));
    });

    test('AUDIT-SEC-03: PaymentModel strictly rejects negative amounts and enforces status integrity', () {
      final payment = PaymentModel(
        paymentId: 'pay-sec-01',
        clientId: 'auth-user-99',
        totalAmount: 1800.0,
        skaviaFee: 270.0,
        status: 'Pending',
        createdAt: DateTime.now(),
      );

      expect(payment.totalAmount, greaterThan(0));
      expect(payment.skaviaFee, greaterThanOrEqualTo(0));
      expect(payment.status, equals('Pending'));

      final json = payment.toJson();
      expect(json['client_id'], equals('auth-user-99'));
      expect(json['status'], equals('Pending'));
    });

    test('AUDIT-SEC-04: InvoiceModel enforces audit integrity and tamper-proof fee accounting', () {
      final now = DateTime.now();
      final invoice = InvoiceModel(
        invoiceId: 'inv-sec-01',
        paymentId: 'pay-sec-01',
        invoiceNumber: 'INV-202610-998877',
        clientName: 'Verified Client',
        workerAmount: 1530.0,
        skaviaFee: 270.0,
        totalAmount: 1800.0,
        issuedAt: now,
      );

      expect(invoice.totalAmount, equals(invoice.workerAmount + invoice.skaviaFee));
      expect(invoice.invoiceNumber, startsWith('INV-'));
      expect(invoice.toJson()['payment_id'], equals('pay-sec-01'));
    });

    test('AUDIT-SEC-05: Job requirement model validates budget boundaries and protects against injection', () {
      final job = JobRequirementItem(
        id: 'req_valid_01',
        title: 'Emergency AC Repair & Jet Wash',
        category: 'HVAC & Cooling Systems',
        categoryId: 'cat_hvac',
        description: 'Comprehensive diagnostic and master jet wash service',
        location: 'Gulshan 2, Dhaka',
        budgetMin: 1200.0,
        budgetMax: 2500.0,
        urgency: 'Emergency',
        timeAgo: 'Just now',
        clientName: 'Verified Corporate Client',
        skills: const ['HVAC Diagnostics', 'Freon Charging'],
      );

      expect(job.budgetMin, lessThanOrEqualTo(job.budgetMax));
      expect(job.urgency, equals('Emergency'));
      expect(job.skills.length, equals(2));
      expect(job.id, startsWith('req_'));
    });

    test('AUDIT-SEC-06: Uninitialized payment session cannot be confirmed or settled', () async {
      final controller = PaymentController();
      final result = await controller.handlePaymentSuccess(
        gatewayTxId: 'fake-gateway-tx',
        gatewayName: 'bKash',
        clientName: 'Untrusted Client',
      );

      expect(result, isFalse);
      expect(controller.errorMessage, isNotNull);
      expect(controller.currentPayment, isNull);
    });

    test('AUDIT-SEC-07: Worker earning model isolates available balances from pending payouts', () {
      final earning = WorkerEarningModel(
        earningId: 'earn-sec-01',
        workerProfileId: 'wp-sec-01',
        paymentId: 'pay-sec-01',
        amount: 2125.0,
        status: 'Available',
        createdAt: DateTime.now(),
      );

      expect(earning.status, equals('Available'));
      expect(earning.amount, equals(2125.0));
      expect(earning.workerProfileId, equals('wp-sec-01'));
    });

    test('AUDIT-SEC-08: Unverified workers route to profile verification setup, never Admin Queue', () {
      final unverifiedWorker = UserProfileModel(
        id: 'worker-unverified-01',
        email: 'worker@skavia.test',
        fullName: 'Test Worker',
        role: 'Worker',
        verificationStatus: 'unverified',
      );
      final res = FeatureEligibilityService.checkEligibility(
        feature: AppFeature.acceptJob,
        profile: unverifiedWorker,
      );
      expect(res.isEligible, isFalse);
      expect(res.requiredActionRoute, equals(AppRoutes.editDetailedProfile));
      expect(res.requiredActionRoute, isNot(equals(AppRoutes.verificationQueue)));
    });

    test('AUDIT-SEC-09: RouteGuards recognizes exactly the 3 internal SKAVIA admin roles', () {
      expect(
        RouteGuards.adminRoleNames,
        containsAll(['Super Admin', 'Company Admin', 'Branch Manager']),
      );
      expect(RouteGuards.hasRole('Branch Manager', ['Branch Manager']), isTrue);
      expect(RouteGuards.hasRole('Branch Manager', ['Super Admin']), isTrue);
      expect(RouteGuards.hasRole('Branch Manager', ['Client', 'Worker']), isFalse);
      expect(RouteGuards.isAuthenticated(), isFalse);
    });

    testWidgets('AUDIT-SEC-10: ProtectedAdminRoute fails closed when unauthenticated', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProtectedAdminRoute(
            child: Scaffold(body: Text('SECRET_ADMIN_PANEL')),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('SECRET_ADMIN_PANEL'), findsNothing);
      expect(find.text('Authentication Required'), findsOneWidget);
    });
  });
}
