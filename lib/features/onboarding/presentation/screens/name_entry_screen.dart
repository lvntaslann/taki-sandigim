import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/database/user_settings_repository.dart';
import '../../../../core/utils/name_capitalization_formatter.dart';
import '../widgets/onboarding_gradient_button.dart';

/// Native pixel size shared with onboarding_screen.dart so both screens
/// scale identically on every device.
const double _kCanvasWidth = 1080;
const double _kCanvasHeight = 1920;

class NameEntryScreen extends StatefulWidget {
  const NameEntryScreen({super.key});

  @override
  State<NameEntryScreen> createState() => _NameEntryScreenState();
}

class _NameEntryScreenState extends State<NameEntryScreen> {
  final TextEditingController _nameController = TextEditingController();
  final _settingsRepository = UserSettingsRepository();
  String? _errorText;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _continue() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorText = 'Lütfen isminizi giriniz');
      return;
    }
    _settingsRepository.setName(name);
    context.go(AppRoutes.emailEntry);
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
                    'Size Nasıl Hitap Edelim?',
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
                    controller: _nameController,
                    textAlign: TextAlign.start,
                    inputFormatters: const [NameCapitalizationFormatter()],
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
                      labelText: 'İsim:',
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
                  top: 1450,
                  height: 115,
                  child: OnboardingGradientButton(
                    label: 'Devam Et',
                    fontSize: 40,
                    onPressed: _continue,
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
