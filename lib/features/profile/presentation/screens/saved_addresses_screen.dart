import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/ui_feedback_helper.dart';
import '../../../../shared/dialogs/confirmation_dialog.dart';
import '../../../../shared/empty_states/empty_data_view.dart';
import '../../../../shared/loaders/list_shimmer_skeleton.dart';
import '../../../../shared/widgets/app_app_bar.dart';
import '../../data/models/user_address_model.dart';
import '../controllers/profile_controller.dart';
import '../widgets/address_editor_sheet.dart';

class SavedAddressesScreen extends StatefulWidget {
  final ProfileController controller;

  const SavedAddressesScreen({super.key, required this.controller});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.loadCurrentUserIfNeeded();
  }

  void _openAddAddressModal([UserAddressModel? editAddress]) {
    AddressEditorSheet.show(
      context,
      controller: widget.controller,
      editAddress: editAddress,
    );
  }

  Future<void> _confirmDelete(UserAddressModel addr) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Delete Saved Address?',
      message:
          'Remove "${addr.label}" (${addr.addressLine}) from your saved locations?',
      confirmText: 'Delete',
      isDestructive: true,
    );
    if (confirmed == true && mounted) {
      await widget.controller.deleteAddress(addr.id);
      if (mounted) {
        UiFeedbackHelper.showInfo(context, 'Address removed.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = context.skavia;

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final addresses = widget.controller.profile?.savedAddresses ?? [];

        return Scaffold(
          appBar: const AppAppBar(title: 'Saved Delivery Addresses'),
          body: SafeArea(
            child: widget.controller.isLoading &&
                    widget.controller.profile == null
                ? const ListShimmerSkeleton(itemCount: 3, itemHeight: 110)
                : addresses.isEmpty
                    ? EmptyDataView(
                        icon: Icons.location_off_outlined,
                        title: 'No Addresses Saved Yet',
                        message:
                            'Add your home or office address to enable 1-tap service dispatch across Dhaka.',
                        actionText: '+ Add First Address',
                        onAction: () => _openAddAddressModal(),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          AppDimensions.paddingLarge,
                          AppDimensions.paddingLarge,
                          AppDimensions.paddingLarge,
                          96,
                        ),
                        itemCount: addresses.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final addr = addresses[index];
                          IconData icon = Icons.home_rounded;
                          final lowerLabel = addr.label.toLowerCase();
                          if (lowerLabel.contains('work') ||
                              lowerLabel.contains('office')) {
                            icon = Icons.business_rounded;
                          } else if (lowerLabel.contains('other')) {
                            icon = Icons.location_on_rounded;
                          }

                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: tokens.cardBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: addr.isDefault
                                    ? tokens.brandAccent
                                    : tokens.border,
                                width: addr.isDefault ? 1.5 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: addr.isDefault
                                        ? tokens.brandAccent
                                              .withValues(alpha: 0.14)
                                        : colorScheme.surfaceContainerHighest,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    icon,
                                    color: addr.isDefault
                                        ? tokens.brandAccent
                                        : colorScheme.onSurfaceVariant,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 4,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        children: [
                                          Text(
                                            addr.label,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                              color: colorScheme.onSurface,
                                            ),
                                          ),
                                          if (addr.isDefault)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: tokens.brandAccent
                                                    .withValues(alpha: 0.14),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                'DEFAULT',
                                                style: TextStyle(
                                                  color: tokens.brandAccent,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      if ((addr.recipientName ?? '')
                                              .isNotEmpty ||
                                          (addr.recipientPhone ?? '')
                                              .isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          [
                                            if ((addr.recipientName ?? '')
                                                .isNotEmpty)
                                              addr.recipientName!,
                                            if ((addr.recipientPhone ?? '')
                                                .isNotEmpty)
                                              addr.recipientPhone!,
                                          ].join(' • '),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 4),
                                      Text(
                                        addr.addressLine,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${addr.zone}, ${addr.city} ${addr.postalCode ?? ''}'
                                            .trim(),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: tokens.mutedText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  icon: Icon(
                                    Icons.more_vert,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  onSelected: (val) async {
                                    if (val == 'default') {
                                      await widget.controller
                                          .setDefaultAddress(addr);
                                      if (context.mounted) {
                                        UiFeedbackHelper.showSuccess(
                                          context,
                                          '${addr.label} set as primary address.',
                                        );
                                      }
                                    } else if (val == 'edit') {
                                      _openAddAddressModal(addr);
                                    } else if (val == 'delete') {
                                      await _confirmDelete(addr);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    if (!addr.isDefault)
                                      const PopupMenuItem(
                                        value: 'default',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.star_outline_rounded,
                                              size: 16,
                                            ),
                                            SizedBox(width: 8),
                                            Text('Set as Default'),
                                          ],
                                        ),
                                      ),
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit_outlined, size: 16),
                                          SizedBox(width: 8),
                                          Text('Edit'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.delete_outline,
                                            color: AppColors.errorRed,
                                            size: 16,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Delete',
                                            style: TextStyle(
                                              color: AppColors.errorRed,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
          floatingActionButton: addresses.isNotEmpty
              ? FloatingActionButton.extended(
                  onPressed: () => _openAddAddressModal(),
                  backgroundColor: AppColors.primaryRoyal,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Address'),
                )
              : null,
        );
      },
    );
  }
}
