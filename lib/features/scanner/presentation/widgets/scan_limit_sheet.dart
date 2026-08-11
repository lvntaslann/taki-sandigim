import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';

Future<void> showScanLimitSheet(BuildContext context, {required Duration? resetIn}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _ScanLimitSheet(resetIn: resetIn),
  );
}

String _formatResetIn(Duration? duration) {
  if (duration == null || duration <= Duration.zero) return 'birazdan';
  final hours = duration.inHours;
  final minutes = duration.inMinutes % 60;
  if (hours <= 0) return '$minutes dk';
  return '$hours sa $minutes dk';
}

class _ScanLimitSheet extends StatelessWidget {
  const _ScanLimitSheet({required this.resetIn});

  final Duration? resetIn;

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.muted(context);
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_clock_outlined, color: AppColors.primary, size: 28),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tarama hakkın doldu',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Ücretsiz tarama hakkın ${_formatResetIn(resetIn)} sonra yenilenecek. '
              'Premium ile sınırsız tara.',
              style: TextStyle(color: muted, fontSize: 13.5, height: 1.4),
            ),
            const SizedBox(height: 20),
            CustomButton(
              label: 'Premium\'a Geç',
              icon: Icons.workspace_premium,
              onPressed: () {
                Navigator.of(context).pop();
                context.push(AppRoutes.premium);
              },
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Kapat'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
