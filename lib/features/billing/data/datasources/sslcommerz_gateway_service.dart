import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../app/config/app_config.dart';

/// SSLCommerz Gateway Backend Communication Service
/// Handles API V4 session initiation for Hosted Checkout (bKash, Nagad, Cards, etc.)
class SslCommerzGatewayService {
  // API Endpoints
  static const String sandboxApiUrl = 'https://sandbox.sslcommerz.com/gwprocess/v4/api.php';
  static const String liveApiUrl = 'https://securepay.sslcommerz.com/gwprocess/v4/api.php';

  // Internal Callback URLs for redirect interception
  static const String successUrl = 'https://skavia-platform.web.app/payment/success';
  static const String failUrl = 'https://skavia-platform.web.app/payment/fail';
  static const String cancelUrl = 'https://skavia-platform.web.app/payment/cancel';
  static const String ipnUrl = 'https://skavia-platform.web.app/payment/ipn';

  final String storeId;
  final String storePasswd;
  final bool isSandbox;

  SslCommerzGatewayService({
    String? storeId,
    String? storePasswd,
    bool? isSandbox,
  })  : storeId = storeId ?? AppConfig.sslCommerzStoreId,
        storePasswd = storePasswd ?? AppConfig.sslCommerzStorePasswd,
        isSandbox = isSandbox ?? AppConfig.sslCommerzIsSandbox;

  /// Initiates a payment session with SSLCommerz and returns the GatewayPageURL
  Future<SslCommerzInitResult> initiatePayment({
    required String tranId,
    required double totalAmount,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    String productName = 'SKAVIA On-Demand Service',
    String productCategory = 'Service',
  }) async {
    final endpoint = isSandbox ? sandboxApiUrl : liveApiUrl;

    final body = {
      'store_id': storeId,
      'store_passwd': storePasswd,
      'total_amount': totalAmount.toStringAsFixed(2),
      'currency': 'BDT',
      'tran_id': tranId,
      'success_url': successUrl,
      'fail_url': failUrl,
      'cancel_url': cancelUrl,
      'ipn_url': ipnUrl,
      'cus_name': customerName.isNotEmpty ? customerName : 'SKAVIA Customer',
      'cus_email': customerEmail.isNotEmpty ? customerEmail : 'customer@skavia.app',
      'cus_add1': 'Dhaka, Bangladesh',
      'cus_phone': customerPhone.isNotEmpty ? customerPhone : '01700000000',
      'cus_city': 'Dhaka',
      'cus_country': 'Bangladesh',
      'shipping_method': 'NO',
      'product_name': productName,
      'product_category': productCategory,
      'product_profile': 'general',
    };

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final status = data['status'] as String?;

        if (status == 'SUCCESS') {
          final gatewayUrl = data['GatewayPageURL'] as String?;
          final sessionKey = data['sessionkey'] as String?;
          if (gatewayUrl != null && gatewayUrl.isNotEmpty) {
            return SslCommerzInitResult(
              isSuccess: true,
              gatewayUrl: gatewayUrl,
              sessionKey: sessionKey,
            );
          }
        }

        return SslCommerzInitResult(
          isSuccess: false,
          errorMessage: data['failedreason'] ?? 'SSLCommerz session initialization failed.',
        );
      } else {
        return SslCommerzInitResult(
          isSuccess: false,
          errorMessage: 'HTTP ${response.statusCode}: Failed to connect to SSLCommerz.',
        );
      }
    } catch (e) {
      return SslCommerzInitResult(
        isSuccess: false,
        errorMessage: 'Network exception during SSLCommerz initialization: $e',
      );
    }
  }
}

class SslCommerzInitResult {
  final bool isSuccess;
  final String? gatewayUrl;
  final String? sessionKey;
  final String? errorMessage;

  SslCommerzInitResult({
    required this.isSuccess,
    this.gatewayUrl,
    this.sessionKey,
    this.errorMessage,
  });
}
