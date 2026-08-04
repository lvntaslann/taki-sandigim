import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/database/user_settings_repository.dart';

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
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _errorText = 'Lütfen mail adresinizi giriniz');
      return;
    }
    if (!_emailPattern.hasMatch(email)) {
      setState(() => _errorText = 'Lütfen geçerli bir mail adresi giriniz');
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
    return Scaffold(
      backgroundColor: const Color(0xFFFCF3E7),
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
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 72,
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
                      labelText: 'Mail:',
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
                  left: 207,
                  right: 207,
                  top: 1469,
                  height: 108,
                  child: ElevatedButton(
                    onPressed: _continue,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(54),
                      ),
                      elevation: 0,
                      padding: EdgeInsets.zero,
                    ).copyWith(
                      backgroundColor: WidgetStateProperty.all(Colors.transparent),
                      shadowColor: WidgetStateProperty.all(Colors.transparent),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primaryDark, AppColors.primary],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(54),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Devam Et',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 55,
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
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
