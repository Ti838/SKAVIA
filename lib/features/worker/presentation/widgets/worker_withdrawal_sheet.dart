import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../shared/widgets/app_button.dart';

/// Modal bottom sheet allowing workers to request bKash, Nagad, or Bank payouts.
class WorkerWithdrawalSheet extends StatefulWidget {
  final double availableBalance;
  final void Function(double amount, String method) onConfirmWithdrawal;

  const WorkerWithdrawalSheet({
    super.key,
    required this.availableBalance,
    required this.onConfirmWithdrawal,
  });

  static Future<void> show(
    BuildContext context, {
    required double availableBalance,
    required void Function(double amount, String method) onConfirmWithdrawal,
  }) {
    if (availableBalance <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No available balance to withdraw. Complete jobs to earn payouts.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return Future.value();
    }

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => WorkerWithdrawalSheet(
        availableBalance: availableBalance,
        onConfirmWithdrawal: onConfirmWithdrawal,
      ),
    );
  }

  @override
  State<WorkerWithdrawalSheet> createState() => _WorkerWithdrawalSheetState();
}

class _WorkerWithdrawalSheetState extends State<WorkerWithdrawalSheet> {
  final TextEditingController _amountController = TextEditingController();
  String _selectedMethod = 'bKash';

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingMedium),
              const Text(
                'Instant Earnings Withdrawal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Available for payout: ৳ ${widget.availableBalance.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: ['bKash', 'Nagad', 'Bank Transfer'].map((m) {
                  final isSel = _selectedMethod == m;
                  return Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _selectedMethod = m),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSel
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSel ? AppColors.primary : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            m,
                            style: TextStyle(
                              fontWeight:
                                  isSel ? FontWeight.w800 : FontWeight.w500,
                              color: isSel
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Withdraw Amount (BDT)',
                  hintText: 'e.g. 1000',
                  prefixText: '৳ ',
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  text: 'Confirm Withdrawal',
                  onPressed: () {
                    final enteredAmount =
                        double.tryParse(_amountController.text.trim()) ?? 0.0;
                    Navigator.pop(context);
                    widget.onConfirmWithdrawal(enteredAmount, _selectedMethod);
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

