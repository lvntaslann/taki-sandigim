import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/database/user_settings_repository.dart';
import '../widgets/onboarding_gradient_button.dart';

/// Native pixel size shared with name_entry_screen.dart so both screens
/// scale identically on every device.
const double _kCanvasWidth = 1080;
const double _kCanvasHeight = 1920;

class EmailEntryScreen extends StatefulWidget {
  const EmailEntryScreen({super.key});

  @override
  State<EmailEntryScreen> createState() => _EmailEntryScreenState();
}

class _EmailEntryScreenState extends State<EmailEntryScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _settingsRepository = UserSettingsRepository();
  bool _skipHovered = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _continue() {
    final email = _emailController.text.trim();
    if (email.isNotEmpty) {
      _settingsRepository.setEmail(email);
    }
    _settingsRepository.setOnboardingComplete();
    context.go(AppRoutes.dashboard);
  }

  void _skip() {
    _settingsRepository.setOnboardingComplete();
    context.go(AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF3E7),
      resizeToAvoidBottomInset: false,
      body: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: _kCanvasWidth,
            height: _kCanvasHeight,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: 478,
                  child: Text(
                    'Yedekleme için mail adresinizi\ngiriniz...',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.greatVibes(
                      fontSize: 76,
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Positioned(
                  left: 130,
                  right: 130,
                  top: 800,
                  child: TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textAlign: TextAlign.start,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 48,
                      color: AppColors.primaryDark,
                    ),
                    cursorColor: AppColors.primary,
                    decoration: InputDecoration(
                      filled: false,
                      border: InputBorder.none,
                      labelText: 'Mail:',
                      labelStyle: GoogleFonts.playfairDisplay(
                        fontSize: 48,
                        color: AppColors.primary,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: AppColors.primaryDark, width: 2),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 220,
                  right: 220,
                  top: 1440,
                  height: 115,
                  child: OnboardingGradientButton(
                    label: 'Devam Et',
                    fontSize: 40,
                    onPressed: _continue,
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 1600,
                  child: Center(
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      onEnter: (_) => setState(() => _skipHovered = true),
                      onExit: (_) => setState(() => _skipHovered = false),
                      child: GestureDetector(
                        onTap: _skip,
                        child: Text(
                          'ATLA',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 30,
                            color: _skipHovered
                                ? AppColors.primaryDark
                                : AppColors.primary,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                            decoration: _skipHovered
                                ? TextDecoration.underline
                                : TextDecoration.none,
                            decorationColor: AppColors.primaryDark,
                          ),
                        ),
                      ),
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
