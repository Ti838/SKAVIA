import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/empty_states/empty_data_view.dart';
import '../../../../shared/loaders/list_shimmer_skeleton.dart';
import '../../../../shared/widgets/app_app_bar.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../data/datasources/transaction_history_datasource.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final TransactionHistoryRemoteDataSource _dataSource =
      TransactionHistoryRemoteDataSource();
  bool _isLoading = true;
  String _selectedFilter = 'All';
  List<TransactionHistoryEntry> _entries = const [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final userId = _dataSource.resolveUserId();
    if (userId == null) {
      setState(() {
        _entries = const [];
        _isLoading = false;
      });
      return;
    }

    if (_entries.isEmpty) {
      _entries = _dataSource.getCachedHistory(userId);
    }

    final loaded = await _dataSource.fetchHistory(userId);
    if (mounted) {
      setState(() {
        _entries = loaded;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = context.skavia;

    final filtered = _entries.where((e) {
      if (_selectedFilter == 'All') return true;
      return e.status.toLowerCase() == _selectedFilter.toLowerCase();
    }).toList();

    return Scaffold(
      appBar: const AppAppBar(title: 'Transaction History & Invoices'),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadHistory,
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: ['All', 'Completed', 'Pending', 'Refunded'].map((
                    status,
                  ) {
                    final selected = _selectedFilter == status;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () => setState(() => _selectedFilter = status),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? tokens.brandAccent.withValues(alpha: 0.14)
                                : colorScheme.surfaceContainerHighest.withValues(
                                    alpha: 0.45,
                                  ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selected
                                  ? tokens.brandAccent
                                  : tokens.subtleBorder,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (selected) ...[
                                Icon(
                                  Icons.check_rounded,
                                  size: 14,
                                  color: tokens.brandAccent,
                                ),
                                const SizedBox(width: 5),
                              ],
                              Text(
                                status,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: selected
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  color: selected
                                      ? tokens.brandAccent
                                      : colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: _isLoading && _entries.isEmpty
                    ? const ListShimmerSkeleton(itemCount: 4, itemHeight: 92)
                    : filtered.isEmpty
                    ? EmptyDataView(
                        icon: Icons.receipt_long_outlined,
                        title: 'No Transactions Found',
                        message:
                            'Your completed service payments, escrow settlements, and itemized VAT invoices will appear here.',
                        actionText: 'Refresh',
                        onAction: _loadHistory,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          final isCompleted =
                              item.status.toLowerCase() == 'completed';
                          final badgeColor = isCompleted
                              ? AppColors.success
                              : (item.status.toLowerCase() == 'refunded'
                                    ? AppColors.primarySky
                                    : AppColors.warning);

                          return AppCard(
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.invoice,
                              arguments: {
                                'invoiceNumber': item.invoiceNumber,
                                'serviceTitle': item.serviceTitle,
                                'clientName': item.clientName,
                                'clientPhone': '',
                                'specialistName': 'SKAVIA Verified Team',
                                'baseAmount': item.baseAmount,
                                'platformFee': item.platformFee,
                                'totalAmount': item.totalAmount,
                                'paymentMethod': item.paymentMethod,
                                'transactionId': item.transactionId,
                                'paidAt': item.paidAt,
                              },
                            ),
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.serviceTitle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: badgeColor.withValues(alpha: 0.14),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        item.status.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: badgeColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 4,
                                  alignment: WrapAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${item.invoiceNumber} • ${item.paymentMethod}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    Text(
                                      Formatters.formatCurrency(
                                        item.totalAmount,
                                      ),
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: tokens.brandAccent,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${Formatters.formatDateTime(item.paidAt)} • Tap for itemized invoice',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: tokens.mutedText,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
