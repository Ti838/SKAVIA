import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/utils/supabase_guard.dart';
import '../../../../data/tables/database_tables.dart';

class TransactionHistoryEntry {
  final String paymentId;
  final String invoiceNumber;
  final String clientName;
  final String serviceTitle;
  final String paymentMethod;
  final String transactionId;
  final String status;
  final double baseAmount;
  final double platformFee;
  final double totalAmount;
  final DateTime paidAt;

  const TransactionHistoryEntry({
    required this.paymentId,
    required this.invoiceNumber,
    required this.clientName,
    required this.serviceTitle,
    required this.paymentMethod,
    required this.transactionId,
    required this.status,
    required this.baseAmount,
    required this.platformFee,
    required this.totalAmount,
    required this.paidAt,
  });

  Map<String, dynamic> toJson() => {
    'paymentId': paymentId,
    'invoiceNumber': invoiceNumber,
    'clientName': clientName,
    'serviceTitle': serviceTitle,
    'paymentMethod': paymentMethod,
    'transactionId': transactionId,
    'status': status,
    'baseAmount': baseAmount,
    'platformFee': platformFee,
    'totalAmount': totalAmount,
    'paidAt': paidAt.toIso8601String(),
  };

  factory TransactionHistoryEntry.fromJson(Map<String, dynamic> json) =>
      TransactionHistoryEntry(
        paymentId: json['paymentId']?.toString() ?? '',
        invoiceNumber: json['invoiceNumber']?.toString() ?? 'INV',
        clientName: json['clientName']?.toString() ?? 'SKAVIA Client',
        serviceTitle: json['serviceTitle']?.toString() ?? 'Service',
        paymentMethod: json['paymentMethod']?.toString() ?? 'Escrow',
        transactionId: json['transactionId']?.toString() ?? '',
        status: json['status']?.toString() ?? 'Pending',
        baseAmount: (json['baseAmount'] as num?)?.toDouble() ?? 0.0,
        platformFee: (json['platformFee'] as num?)?.toDouble() ?? 0.0,
        totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
        paidAt:
            DateTime.tryParse(json['paidAt']?.toString() ?? '') ??
            DateTime.now(),
      );
}

class TransactionHistoryRemoteDataSource {
  static const String _cachePrefix = 'skavia_tx_history_';
  final SupabaseClient? _supabase;

  TransactionHistoryRemoteDataSource({SupabaseClient? supabase})
    : _supabase = supabase ?? tryGetSupabaseClient();

  String? resolveUserId() {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null && uid.isNotEmpty) return uid;
    } catch (_) {}
    return _supabase?.auth.currentUser?.id;
  }

  List<TransactionHistoryEntry> getCachedHistory(String userId) {
    final cached = LocalCacheService.instance.get('$_cachePrefix$userId');
    if (cached is List) {
      return cached
          .whereType<Map>()
          .map(
            (m) =>
                TransactionHistoryEntry.fromJson(Map<String, dynamic>.from(m)),
          )
          .toList();
    }
    return const [];
  }

  /// Fetches payment history + invoices + gateway transactions in 2 batched round trips instead of N+1.
  Future<List<TransactionHistoryEntry>> fetchHistory(String userId) async {
    final client = _supabase;
    if (client == null) {
      return getCachedHistory(userId);
    }

    try {
      final paymentRows = await client
          .from(DatabaseTables.payments)
          .select(
            'payment_id, service_request_id, project_id, total_amount, skavia_fee, status, paid_at, created_at',
          )
          .eq('client_id', userId)
          .order('created_at', ascending: false)
          .limit(40);

      final payments = (paymentRows as List)
          .whereType<Map>()
          .map((r) => Map<String, dynamic>.from(r))
          .toList();

      if (payments.isEmpty) {
        LocalCacheService.instance.put(
          '$_cachePrefix$userId',
          const <Map<String, dynamic>>[],
          ttl: const Duration(days: 3),
        );
        return const [];
      }

      final paymentIds = payments
          .map((p) => p['payment_id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toList();

      final invoiceByPayment = <String, Map<String, dynamic>>{};
      final txByPayment = <String, Map<String, dynamic>>{};

      if (paymentIds.isNotEmpty) {
        final results = await Future.wait<List<dynamic>>([
          () async {
            try {
              final rows = await client
                  .from(DatabaseTables.invoices)
                  .select(
                    'payment_id, invoice_number, client_name, worker_amount, skavia_fee, total_amount, issued_at',
                  )
                  .inFilter('payment_id', paymentIds);
              return rows as List<dynamic>;
            } catch (_) {
              return const <dynamic>[];
            }
          }(),
          () async {
            try {
              final rows = await client
                  .from(DatabaseTables.transactions)
                  .select('payment_id, gateway_name, gateway_tx_id, status')
                  .inFilter('payment_id', paymentIds);
              return rows as List<dynamic>;
            } catch (_) {
              return const <dynamic>[];
            }
          }(),
        ]);

        for (final row in results[0].whereType<Map>()) {
          final map = Map<String, dynamic>.from(row);
          final pid = map['payment_id']?.toString();
          if (pid != null && pid.isNotEmpty) {
            invoiceByPayment.putIfAbsent(pid, () => map);
          }
        }
        for (final row in results[1].whereType<Map>()) {
          final map = Map<String, dynamic>.from(row);
          final pid = map['payment_id']?.toString();
          if (pid != null && pid.isNotEmpty) {
            txByPayment.putIfAbsent(pid, () => map);
          }
        }
      }

      final loaded = payments.map((p) {
        final paymentId = p['payment_id']?.toString() ?? '';
        final inv = invoiceByPayment[paymentId];
        final tx = txByPayment[paymentId];
        final total = (p['total_amount'] as num?)?.toDouble() ?? 0.0;
        final fee =
            (inv?['skavia_fee'] as num?)?.toDouble() ??
            (p['skavia_fee'] as num?)?.toDouble() ??
            0.0;
        final workerAmt =
            (inv?['worker_amount'] as num?)?.toDouble() ?? (total - fee);

        return TransactionHistoryEntry(
          paymentId: paymentId,
          invoiceNumber:
              inv?['invoice_number']?.toString() ??
              'INV-${paymentId.substring(0, paymentId.length >= 6 ? 6 : paymentId.length).toUpperCase()}',
          clientName: inv?['client_name']?.toString() ?? 'SKAVIA Client',
          serviceTitle: p['project_id'] != null
              ? 'Turnkey Project Milestone'
              : 'On-Demand Technical Service',
          paymentMethod: tx?['gateway_name']?.toString() ?? 'Escrow',
          transactionId: tx?['gateway_tx_id']?.toString() ?? paymentId,
          status: p['status']?.toString() ?? 'Pending',
          baseAmount: workerAmt,
          platformFee: fee,
          totalAmount: total,
          paidAt:
              DateTime.tryParse(
                p['paid_at']?.toString() ?? p['created_at']?.toString() ?? '',
              ) ??
              DateTime.now(),
        );
      }).toList();

      LocalCacheService.instance.put(
        '$_cachePrefix$userId',
        loaded.map((e) => e.toJson()).toList(),
        ttl: const Duration(days: 3),
      );
      return loaded;
    } catch (_) {
      return getCachedHistory(userId);
    }
  }
}

