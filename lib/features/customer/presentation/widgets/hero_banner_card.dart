import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../app/router/app_routes.dart';

/// Screen 4 Hero Banner Card: "Turn Your Ideas Into Reality"
class HeroBannerCard extends StatelessWidget {
  final VoidCallback? onRequestService;

  const HeroBannerCard({super.key, this.onRequestService});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E56F0), Color(0xFF2563EB), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Turn Your Ideas\nInto Reality',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Find skilled workers or teams for your next project.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.88),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed:
                      onRequestService ??
                      () => Navigator.pushNamed(
                        context,
                        AppRoutes.postRequirement,
                      ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primaryRoyal,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Request Service',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 95,
            height: 95,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(12),
            child: Image.asset(
              AppAssets.techniciansConsole,
              fit: BoxFit.contain,
              errorBuilder: (_, error, stack) => const Icon(
                Icons.computer_rounded,
                size: 48,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
