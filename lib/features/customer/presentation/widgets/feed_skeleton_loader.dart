import 'package:flutter/material.dart';

/// Shimmering skeleton loader for the feed during data fetching.
class FeedSkeletonLoader extends StatelessWidget {
  const FeedSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 12,
                        color: colorScheme.surfaceContainerHighest,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 70,
                        height: 10,
                        color: colorScheme.surfaceContainerHighest,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 14,
                color: colorScheme.surfaceContainerHighest,
              ),
              const SizedBox(height: 8),
              Container(
                width: 200,
                height: 12,
                color: colorScheme.surfaceContainerHighest,
              ),
            ],
          ),
        );
      },
    );
  }
}
