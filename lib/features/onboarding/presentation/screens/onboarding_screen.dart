import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes/app_routes.dart';

/// Native pixel size of assets/images/onboarding_background.png.
const double _kBgWidth = 1080;
const double _kBgHeight = 1920;

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF3E7),
      body: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: _kBgWidth,
            height: _kBgHeight,
            child: Stack(
              children: [
                Image.asset(
                  'assets/images/onboarding_background.png',
                  width: _kBgWidth,
                  height: _kBgHeight,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  left: 262,
                  right: 262,
                  top: 1478,
                  height: 90,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(45),
                      onTap: () => context.go(AppRoutes.nameEntry),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
