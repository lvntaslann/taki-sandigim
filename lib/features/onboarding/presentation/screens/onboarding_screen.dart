import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../widgets/onboarding_gradient_button.dart';

/// Native pixel size of assets/images/onboarding_bg_new.png.
const double _kBgWidth = 1080;
const double _kBgHeight = 2400;

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF3E7),
      body: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _kBgWidth,
            height: _kBgHeight,
            child: Stack(
              children: [
                Image.asset(
                  'assets/images/onboarding_bg_new.png',
                  width: _kBgWidth,
                  height: _kBgHeight,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 240,
                  child: Text(
                    'Takı Sandığım',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.greatVibes(
                      fontSize: 130,
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Positioned(
                  left: 220,
                  right: 220,
                  top: 740,
                  child: Text(
                    'Düğün, nişan ve kına\nhediyelerini kolayca kaydedin',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.baloo2(
                      fontSize: 48,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                ),
                Positioned(
                  left: 210,
                  right: 210,
                  top: 940,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _BulletItem(
                        'Kimin ne taktığını, ne verdiğinizi tek bir yerde takip edin',
                      ),
                      SizedBox(height: 45),
                      _BulletItem(
                        'Takı defterinizi veya davetiyenizi kamera ile tarayarak bilgileri otomatik olarak sisteme aktarın',
                      ),
                      SizedBox(height: 45),
                      _BulletItem('Takılanlar ve verilenler olarak ayırın'),
                    ],
                  ),
                ),
                Positioned(
                  left: 170,
                  right: 170,
                  top: 1630,
                  height: 150,
                  child: OnboardingGradientButton(
                    label: 'Haydi Başlayalım',
                    fontSize: 48,
                    onPressed: () => context.go(AppRoutes.nameEntry),
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

class _BulletItem extends StatelessWidget {
  const _BulletItem(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 13),
          child: Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.baloo2(
              fontSize: 37,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
