import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_converter.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../data/models/gift_enums.dart';
import '../../data/models/gift_model.dart';

class RecentEntriesList extends StatelessWidget {
  const RecentEntriesList({super.key, required this.entries});

  final List<GiftModel> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return CustomCard(
        child: Center(
          child: Text(
            'Henüz kayıt yok.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.textMuted),
          ),
        ),
      );
    }

    return Column(
      children: entries
          .map(
            (gift) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: CustomCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor:
                          AppColors.primary.withValues(alpha: 0.18),
                      child: Text(
                        gift.personName.isNotEmpty
                            ? gift.personName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            gift.personName,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            gift.giftType.label,
                            style: const TextStyle(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      CurrencyConverter.formatTl(gift.estimatedValueTl),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: gift.direction == GiftDirection.received
                            ? AppColors.success
                            : AppColors.accent,
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
