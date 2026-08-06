import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../data/models/wedding_model.dart';

class UpcomingWeddingsList extends StatelessWidget {
  const UpcomingWeddingsList({super.key, required this.weddings, this.onTap});

  final List<WeddingModel> weddings;
  final ValueChanged<WeddingModel>? onTap;

  @override
  Widget build(BuildContext context) {
    if (weddings.isEmpty) {
      return CustomCard(
        child: Column(
          children: [
            Icon(
              Icons.mail_outline,
              size: 24,
              color: AppColors.primary.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 6),
            Text(
              'Yaklaşan bir düğün yok.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'Bir davetiye tarayarak otomatik ekleyebilirsin.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: AppColors.muted(context),
              ),
            ),
            const SizedBox(height: 10),
            CustomButton(
              label: 'Davetiye Tara',
              icon: Icons.document_scanner_outlined,
              variant: CustomButtonVariant.outline,
              onPressed: () => context.push(AppRoutes.addGift, extra: 1),
            ),
          ],
        ),
      );
    }

    return Column(
      children: weddings
          .map(
            (wedding) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CustomCard(
                onTap: onTap == null ? null : () => onTap!(wedding),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _dateBadge(wedding.date),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            wedding.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            DateFormatter.dayMonthYear(wedding.date),
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              color: AppColors.muted(context),
                            ),
                          ),
                          if ((wedding.location ?? '').isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 14,
                                  color: AppColors.muted(context),
                                ),
                                const SizedBox(width: 3),
                                Expanded(
                                  child: Text(
                                    wedding.location!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: AppColors.muted(context),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _countdownBadge(context, wedding.date),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _dateBadge(DateTime date) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${date.day}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              height: 1.1,
            ),
          ),
          Text(
            DateFormat('MMM', 'tr_TR').format(date).toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _countdownBadge(BuildContext context, DateTime date) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        DateFormatter.remainingDays(date),
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.accent,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
