import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/premium_plan.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  String _selectedPlanId = PremiumPlan.all.last.id;

  static final _priceFormat = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 2,
  );

  double get _monthlyPlanPrice =>
      PremiumPlan.all.firstWhere((p) => p.id == 'monthly').totalPriceTl;

  void _selectPlan(String id) => setState(() => _selectedPlanId = id);

  void _continue() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ödeme entegrasyonu yakında eklenecek.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final muted = AppColors.muted(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: Icon(Icons.close, color: onSurface),
                  ),
                  Text(
                    'Geri Yükle',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: muted,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                children: [
                  Text.rich(
                    TextSpan(
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                        color: onSurface,
                      ),
                      children: [
                        const TextSpan(text: 'Tüm özelliklerin\n'),
                        TextSpan(
                          text: 'keyfini çıkar',
                          style: const TextStyle(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  _feature(
                    context,
                    icon: Icons.block_flipped,
                    title: 'Reklamsız deneyim',
                    subtitle: 'Uygulamayı hiç reklam görmeden kullan.',
                  ),
                  const SizedBox(height: 18),
                  _feature(
                    context,
                    icon: Icons.document_scanner_outlined,
                    title: 'Daha fazla tarama hakkı',
                    subtitle: 'Günlük fotoğraf tarama limitin artar.',
                  ),
                  const SizedBox(height: 18),
                  _feature(
                    context,
                    icon: Icons.file_download_outlined,
                    title: 'Esnek dışa aktarım',
                    subtitle: 'Kayıtlarını dilediğin formatta indir.',
                  ),
                  const SizedBox(height: 28),
                  for (final plan in PremiumPlan.all) ...[
                    _planRow(context, plan),
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: _continue,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primaryDark, AppColors.primary],
                          ),
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Text(
                          'Premium\'a Geç',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _footerLink(context, 'Koşullar'),
                      const SizedBox(width: 16),
                      Text('·', style: TextStyle(color: muted)),
                      const SizedBox(width: 16),
                      _footerLink(context, 'Gizlilik'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _footerLink(BuildContext context, String label) {
    final muted = AppColors.muted(context);
    return Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: muted,
        decoration: TextDecoration.underline,
        decorationColor: muted,
      ),
    );
  }

  Widget _feature(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.muted(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _planRow(BuildContext context, PremiumPlan plan) {
    final isSelected = plan.id == _selectedPlanId;
    final discount = plan.discountPercent(_monthlyPlanPrice);
    final theme = Theme.of(context);
    final muted = AppColors.muted(context);

    return GestureDetector(
      onTap: () => _selectPlan(plan.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.secondary.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  if (discount > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, color: AppColors.primary, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'En Avantajlı · %${discount.round()} indirim',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    const SizedBox(height: 4),
                    Text(
                      'Taahhütsüz',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: muted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _priceFormat.format(plan.totalPriceTl),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  '${_priceFormat.format(plan.monthlyEquivalentTl)}/ay',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: muted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
