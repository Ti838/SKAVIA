import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/services/app_language_service.dart';

/// Screen 4 Hero Banner Card: "Turn Your Ideas Into Reality" with bilingual support
class HeroBannerCard extends StatelessWidget {
  final VoidCallback? onRequestService;

  const HeroBannerCard({super.key, this.onRequestService});

  @override
  Widget build(BuildContext context) {
    final isBn = AppLanguageService.isBengali;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);

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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compactArtwork =
              constraints.maxWidth < 310 || textScale > 1.35;

          final artwork = Container(
            width: compactArtwork ? 56 : 95,
            height: compactArtwork ? 56 : 95,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            padding: EdgeInsets.all(compactArtwork ? 8 : 12),
            child: Image.asset(
              AppAssets.techniciansConsole,
              fit: BoxFit.contain,
              errorBuilder: (_, error, stack) => Icon(
                Icons.computer_rounded,
                size: compactArtwork ? 28 : 48,
                color: Colors.white,
              ),
            ),
          );

          final ctaButton = ElevatedButton(
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
            child: Text(
              isBn ? 'সার্ভিস রিকোয়েস্ট' : 'Request Service',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          );

          if (compactArtwork) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        isBn
                            ? 'আপনার প্রজেক্ট ও কাজ\nদক্ষ হাতে সমাধান'
                            : 'Turn Your Ideas\nInto Reality',
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.25,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    artwork,
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  isBn
                      ? 'ঢাকার সেরা ভেরিফায়েড কারিগর ও টেকনিক্যাল টিম ডাকুন।'
                      : 'Find skilled workers or teams for your next project.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.88),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 14),
                ctaButton,
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isBn
                          ? 'আপনার প্রজেক্ট ও কাজ\nদক্ষ হাতে সমাধান'
                          : 'Turn Your Ideas\nInto Reality',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isBn
                          ? 'ঢাকার সেরা ভেরিফায়েড কারিগর ও টেকনিক্যাল টিম ডাকুন।'
                          : 'Find skilled workers or teams for your next project.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.88),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ctaButton,
                  ],
                ),
              ),
              const SizedBox(width: 10),
              artwork,
            ],
          );
        },
      ),
    );
  }
}
