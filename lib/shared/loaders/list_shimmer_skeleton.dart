import 'package:flutter/material.dart';

import '../../app/theme/app_dimensions.dart';
import '../../core/extensions/context_extensions.dart';

/// Animated shimmer skeleton placeholder adaptive to Light & Dark surface tokens.
class ListShimmerSkeleton extends StatefulWidget {
  final int itemCount;
  final double itemHeight;

  const ListShimmerSkeleton({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 90.0,
  });

  @override
  State<ListShimmerSkeleton> createState() => _ListShimmerSkeletonState();
}

class _ListShimmerSkeletonState extends State<ListShimmerSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.skavia;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final boneColor = Color.lerp(
          tokens.shimmerBase,
          tokens.shimmerHighlight,
          _controller.value,
        )!;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.itemCount,
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          itemBuilder: (context, index) {
            return Container(
              height: widget.itemHeight,
              margin: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              decoration: BoxDecoration(
                color: tokens.cardBg,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                border: Border.all(color: tokens.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: boneColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingMedium),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 14,
                          decoration: BoxDecoration(
                            color: boneColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        FractionallySizedBox(
                          widthFactor: 0.65,
                          child: Container(
                            height: 10,
                            decoration: BoxDecoration(
                              color: boneColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
