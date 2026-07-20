import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';

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

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _continue() {
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
                    'Size Nasıl Hitap Edelim?',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 64,
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
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 48,
                      color: AppColors.primaryDark,
                    ),
                    cursorColor: AppColors.primary,
                    decoration: InputDecoration(
                      filled: false,
                      border: InputBorder.none,
                      labelText: 'İsim:',
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
                  left: 262,
                  right: 262,
                  top: 1478,
                  height: 90,
                  child: ElevatedButton(
                    onPressed: _continue,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(45),
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
                        borderRadius: BorderRadius.circular(45),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          'Devam Et',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 36,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
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
