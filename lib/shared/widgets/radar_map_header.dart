import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/services/app_language_service.dart';

/// Top grabber and header bar for RadarMapSheet.
class RadarMapHeader extends StatelessWidget {
  final String locationZone;
  final VoidCallback onClose;

  const RadarMapHeader({
    super.key,
    required this.locationZone,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final isBn = AppLanguageService.isBengali;
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = context.skavia;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 12, 10),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: tokens.softBlueBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.map_rounded,
                  color: tokens.brandAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isBn
                          ? 'লাইভ স্ট্রিট ম্যাপ ও রাডার'
                          : 'Live Street Map & Radar',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      isBn
                          ? 'দেশব্যাপী যাচাইকৃত টেকনিশিয়ান • $locationZone'
                          : 'Nationwide Verified Technicians • $locationZone',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: isBn ? 'বন্ধ করুন' : 'Close map',
                icon: Icon(
                  Icons.close_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
                onPressed: onClose,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
