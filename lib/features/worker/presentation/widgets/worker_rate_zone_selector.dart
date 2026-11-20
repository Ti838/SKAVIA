import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_text_field.dart';

/// Adaptive input row for Worker expected hourly rate and working zone dropdown.
class WorkerRateZoneSelector extends StatelessWidget {
  final TextEditingController rateController;
  final String workingArea;
  final List<String> workingZones;
  final ValueChanged<String> onZoneChanged;

  const WorkerRateZoneSelector({
    super.key,
    required this.rateController,
    required this.workingArea,
    required this.workingZones,
    required this.onZoneChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final tokens = context.skavia;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final stackVertically = constraints.maxWidth < 330 || textScale > 1.3;

        final rateField = AppTextField(
          controller: rateController,
          label: 'Rate (৳/Hour)',
          hint: 'e.g. 500',
          keyboardType: TextInputType.number,
          prefixIcon: Icon(
            Icons.sell_outlined,
            color: tokens.brandAccent,
            size: 20,
          ),
        );

        final zoneField = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Working Zone',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: tokens.secondaryText,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: tokens.inputBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: tokens.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: workingArea,
                  isExpanded: true,
                  dropdownColor: tokens.cardBg,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  items: workingZones.map((z) {
                    return DropdownMenuItem<String>(
                      value: z,
                      child: Text(
                        z,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      onZoneChanged(val);
                    }
                  },
                ),
              ),
            ),
          ],
        );

        if (stackVertically) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [rateField, const SizedBox(height: 14), zoneField],
          );
        }

        return Row(
          children: [
            Expanded(flex: 3, child: rateField),
            const SizedBox(width: 12),
            Expanded(flex: 4, child: zoneField),
          ],
        );
      },
    );
  }
}
