import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/database/user_settings_repository.dart';
import '../../../../l10n/app_localizations.dart';
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
  String? _errorText;

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _continue() {
    final l10n = AppLocalizations.of(context);
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _errorText = l10n.emailRequiredError);
      return;
    }
    if (!_emailPattern.hasMatch(email)) {
      setState(() => _errorText = l10n.emailInvalidError);
      return;
    }
    _settingsRepository.setEmail(email);
    _settingsRepository.setOnboardingComplete();
    context.go(AppRoutes.dashboard);
  }

  void _skip() {
    _settingsRepository.setOnboardingComplete();
    context.go(AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFFCF3E7),
      // Shrinks the canvas above the keyboard so "Devam Et" and the skip
      // link stay visible and tappable while typing.
      resizeToAvoidBottomInset: true,
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
                    l10n.emailEntryTitle,
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
                    textInputAction: TextInputAction.done,
                    onTapOutside: (_) => FocusScope.of(context).unfocus(),
                    textAlign: TextAlign.start,
                    onChanged: (_) {
                      if (_errorText != null) setState(() => _errorText = null);
                    },
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 54,
                      color: AppColors.primaryDark,
                    ),
                    cursorColor: AppColors.primary,
                    decoration: InputDecoration(
                      filled: false,
                      border: InputBorder.none,
                      labelText: l10n.emailLabel,
                      labelStyle: GoogleFonts.playfairDisplay(
                        fontSize: 54,
                        color: AppColors.primary,
                      ),
                      errorText: _errorText,
                      errorStyle: GoogleFonts.playfairDisplay(
                        fontSize: 24,
                        color: AppColors.error,
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
                    label: l10n.continueButton,
                    fontSize: 40,
                    onPressed: _continue,
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  // 40 above the label's original 1600 to offset the tap padding.
                  top: 1560,
                  child: Center(
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      onEnter: (_) => setState(() => _skipHovered = true),
                      onExit: (_) => setState(() => _skipHovered = false),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _skip,
                        // The bare label is only ~10pt tall on a phone; the
                        // padding widens the tap target without moving it.
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 80,
                            vertical: 40,
                          ),
                          child: Text(
                            l10n.skipButton,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
