import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// A small pill-shaped tag (e.g. "Altın", "USD"). Uses a solid, opaque
/// background instead of a translucent tint over the parent surface, so it
/// stays legible regardless of whether the surrounding card is on a light
/// or dark theme.
class BasisBadge extends StatelessWidget {
  const BasisBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.secondary,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }
}
