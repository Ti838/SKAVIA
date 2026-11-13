import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/extensions/context_extensions.dart';
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
  String? _errorText;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    final enteredAmount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (enteredAmount <= 0) {
      setState(() => _errorText = 'Enter a valid amount greater than ৳ 0.');
      return;
    }
    if (enteredAmount > widget.availableBalance) {
      setState(
        () => _errorText =
            'Amount cannot exceed available balance (৳ ${widget.availableBalance.toStringAsFixed(0)}).',
      );
      return;
    }

    Navigator.pop(context);
    widget.onConfirmWithdrawal(enteredAmount, _selectedMethod);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.skavia;
    final colorScheme = context.colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        decoration: BoxDecoration(
          color: tokens.sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: tokens.border)),
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
                    color: tokens.border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingMedium),
              Text(
                'Instant Earnings Withdrawal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Available for payout: ৳ ${widget.availableBalance.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 13,
                  color: tokens.secondaryText,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['bKash', 'Nagad', 'Bank'].map((m) {
                  final isSel = _selectedMethod == m;
                  return InkWell(
                    onTap: () => setState(() => _selectedMethod = m),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSel ? tokens.softBlueBg : tokens.subtleCardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSel ? tokens.brandAccent : tokens.border,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        m,
                        style: TextStyle(
                          fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
                          color: isSel
                              ? tokens.brandAccent
                              : colorScheme.onSurface,
                          fontSize: 12,
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
                style: TextStyle(color: colorScheme.onSurface),
                onChanged: (_) {
                  if (_errorText != null) setState(() => _errorText = null);
                },
                decoration: InputDecoration(
                  labelText: 'Withdraw Amount (BDT)',
                  hintText: 'e.g. 1000',
                  prefixText: '৳ ',
                  errorText: _errorText,
                  filled: true,
                  fillColor: tokens.inputBg,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: tokens.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: tokens.brandAccent, width: 1.5),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  text: 'Confirm Withdrawal',
                  onPressed: _submit,
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

