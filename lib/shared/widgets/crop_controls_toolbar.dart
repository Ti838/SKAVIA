import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Bottom controls toolbar for ImageCropResizeScreen containing zoom slider, instructions, and actions.
class CropControlsToolbar extends StatelessWidget {
  final double zoom;
  final bool isSaving;
  final bool isBengali;
  final ValueChanged<double> onZoomChanged;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const CropControlsToolbar({
    super.key,
    required this.zoom,
    required this.isSaving,
    required this.isBengali,
    required this.onZoomChanged,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.zoom_out_rounded,
                  color: Colors.white60,
                  size: 20,
                ),
                Expanded(
                  child: Slider(
                    value: zoom.clamp(1.0, 4.5),
                    min: 1.0,
                    max: 4.5,
                    activeColor: AppColors.primarySky,
                    inactiveColor: Colors.white24,
                    onChanged: isSaving ? null : onZoomChanged,
                  ),
                ),
                const Icon(
                  Icons.zoom_in_rounded,
                  color: Colors.white60,
                  size: 20,
                ),
              ],
            ),
            Text(
              isBengali
                  ? 'ছবি সরাতে টেনে নিন এবং জুম করতে পিঞ্চ বা স্লাইডার ব্যবহার করুন'
                  : 'Drag to reposition and pinch or slide to resize',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 11.5,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: isSaving ? null : onCancel,
                    child: Text(isBengali ? 'বাতিল' : 'Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRoyal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: isSaving ? null : onConfirm,
                    icon: isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_rounded, size: 18),
                    label: Text(
                      isSaving
                          ? (isBengali ? 'প্রসেস হচ্ছে...' : 'Applying...')
                          : (isBengali ? 'সেভ ও আপলোড' : 'Crop & Save'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
