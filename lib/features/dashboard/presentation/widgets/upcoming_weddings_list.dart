import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
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
        child: Center(
          child: Text(
            'Yaklaşan bir düğün yok.\nSağ alttaki + ile ekleyebilirsin.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
          ),
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
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            wedding.title,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormatter.dayMonthYear(wedding.date),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      DateFormatter.remainingDays(wedding.date),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
