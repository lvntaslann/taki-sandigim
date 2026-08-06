import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';

/// Press-down scale + shadow squash + haptic feedback, so taps feel physical.
class OnboardingGradientButton extends StatefulWidget {
  const OnboardingGradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.fontSize = 40,
  });

  final String label;
  final VoidCallback onPressed;
  final double fontSize;

  @override
  State<OnboardingGradientButton> createState() =>
      _OnboardingGradientButtonState();
}

class _OnboardingGradientButtonState extends State<OnboardingGradientButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onPressed();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryDark, AppColors.primary],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark
                    .withValues(alpha: _pressed ? 0.18 : 0.38),
                blurRadius: _pressed ? 6 : 18,
                offset: Offset(0, _pressed ? 2 : 8),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: GoogleFonts.baloo2(
              fontSize: widget.fontSize,
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
