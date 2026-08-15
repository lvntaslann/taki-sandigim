import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/purchase_service.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  // TEMP: Test Store product prices only show in USD (no TL support there).
  // Blocks the purchase flow behind a blurred "coming soon" overlay until
  // real Play Store/App Store products (with TL pricing) are wired up —
  // flip to false then.
  static const bool _comingSoon = true;

  List<Package> _packages = [];
  Package? _selectedPackage;
  bool _loading = true;
  bool _purchasing = false;
  bool _restoring = false;
  bool _purchaseSucceeded = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final offering = (await PurchaseService.instance.getOfferings()).current;
      final packages = <Package>[
        if (offering?.monthly != null) offering!.monthly!,
        if (offering?.threeMonth != null) offering!.threeMonth!,
        if (offering?.sixMonth != null) offering!.sixMonth!,
        if (offering?.annual != null) offering!.annual!,
      ];
      if (!mounted) return;
      setState(() {
        _packages = packages;
        _selectedPackage = packages.isEmpty
            ? null
            : packages.firstWhere(
                (p) => p.packageType == PackageType.annual,
                orElse: () => packages.last,
              );
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Planlar yüklenemedi. Bağlantını kontrol edip tekrar dene.';
        _loading = false;
      });
    }
  }

  void _selectPackage(Package package) => setState(() => _selectedPackage = package);

  Future<void> _continue() async {
    final package = _selectedPackage;
    if (package == null || _purchasing) return;
    setState(() => _purchasing = true);
    try {
      await PurchaseService.instance.purchasePackage(package);
      if (!mounted) return;
      setState(() {
        _purchasing = false;
        _purchaseSucceeded = true;
      });
    } on PlatformException catch (e) {
      if (PurchasesErrorHelper.getErrorCode(e) ==
          PurchasesErrorCode.purchaseCancelledError) {
        if (mounted) setState(() => _purchasing = false);
        return;
      }
      if (!mounted) return;
      setState(() => _purchasing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Satın alma başarısız oldu, tekrar dene.')),
      );
    }
  }

  Future<void> _restore() async {
    if (_restoring) return;
    setState(() => _restoring = true);
    try {
      final info = await PurchaseService.instance.restorePurchases();
      if (!mounted) return;
      final restored = info.entitlements.active.containsKey(
        PurchaseService.premiumEntitlementId,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            restored
                ? 'Satın alman geri yüklendi.'
                : 'Geri yüklenecek aktif bir satın alma bulunamadı.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geri yükleme başarısız oldu.')),
      );
    } finally {
      if (mounted) setState(() => _restoring = false);
    }
  }

  static String _labelFor(PackageType type) => switch (type) {
    PackageType.monthly => 'Aylık',
    PackageType.threeMonth => '3 Aylık',
    PackageType.sixMonth => '6 Aylık',
    PackageType.annual => 'Yıllık',
    _ => 'Plan',
  };

  static int _monthsFor(PackageType type) => switch (type) {
    PackageType.monthly => 1,
    PackageType.threeMonth => 3,
    PackageType.sixMonth => 6,
    PackageType.annual => 12,
    _ => 1,
  };

  double? get _monthlyUnitPrice {
    for (final package in _packages) {
      if (package.packageType == PackageType.monthly) {
        return package.storeProduct.price;
      }
    }
    return null;
  }

  double _discountPercent(Package package) {
    final monthlyPrice = _monthlyUnitPrice;
    if (monthlyPrice == null || monthlyPrice <= 0) return 0;
    final months = _monthsFor(package.packageType);
    final fullPrice = monthlyPrice * months;
    if (fullPrice <= 0) return 0;
    return (1 - (package.storeProduct.price / fullPrice)) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final muted = AppColors.muted(context);

    return Scaffold(
      body: SafeArea(
        child: _comingSoon
            ? _buildComingSoon(context, onSurface, muted)
            : Column(
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
                        if (!_purchaseSucceeded)
                          GestureDetector(
                            onTap: _restoring ? null : _restore,
                            child: _restoring
                                ? SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: muted,
                                    ),
                                  )
                                : Text(
                                    'Geri Yükle',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: muted,
                                    ),
                                  ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(child: _buildBody(context, onSurface, muted)),
                ],
              ),
      ),
    );
  }

  Widget _buildComingSoon(BuildContext context, Color onSurface, Color muted) {
    return Stack(
      children: [
        Positioned.fill(
          child: AbsorbPointer(child: _buildBody(context, onSurface, muted)),
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(color: Colors.black.withValues(alpha: 0.25)),
          ),
        ),
        Positioned(
          top: 4,
          left: 8,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: Icon(Icons.arrow_back, color: onSurface),
            ),
          ),
        ),
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 28),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primaryDark, AppColors.primary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -28,
                    right: -18,
                    child: Icon(
                      Icons.workspace_premium,
                      size: 120,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.hourglass_top_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Çok Yakında',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Premium abonelik yakında burada olacak.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.92),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, Color onSurface, Color muted) {
    if (_purchaseSucceeded) {
      return _successView(context, onSurface, muted);
    }
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: muted)),
              const SizedBox(height: 16),
              TextButton(onPressed: _loadOfferings, child: const Text('Tekrar Dene')),
            ],
          ),
        ),
      );
    }

    return ListView(
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
        if (_packages.isEmpty)
          Text('Şu anda uygun bir plan bulunamadı.', style: TextStyle(color: muted))
        else ...[
          for (final package in _packages) ...[
            _planRow(context, package),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: _purchasing ? null : _continue,
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
                child: _purchasing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
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
        ],
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

  Widget _planRow(BuildContext context, Package package) {
    final isSelected = package.identifier == _selectedPackage?.identifier;
    final discount = _discountPercent(package);
    final months = _monthsFor(package.packageType);
    final theme = Theme.of(context);
    final muted = AppColors.muted(context);
    final storeProduct = package.storeProduct;
    final monthlyEquivalent = NumberFormat.simpleCurrency(
      name: storeProduct.currencyCode,
    ).format(storeProduct.price / months);

    return GestureDetector(
      onTap: () => _selectPackage(package),
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
                    _labelFor(package.packageType),
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
                  storeProduct.priceString,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  '$monthlyEquivalent/ay',
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

  Widget _successView(BuildContext context, Color onSurface, Color muted) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 450),
            curve: Curves.elasticOut,
            builder: (context, value, child) => Transform.scale(scale: value, child: child),
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: AppColors.success, size: 56),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Premium\'a Hoş Geldin!',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Reklamsız deneyim, daha fazla tarama hakkı ve esnek dışa aktarım artık senin.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
              color: muted,
              height: 1.4,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
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
                  'Devam Et',
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
        ],
      ),
    );
  }
}
