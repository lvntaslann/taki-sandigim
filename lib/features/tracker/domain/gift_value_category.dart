import 'package:flutter/material.dart';

import '../../dashboard/data/models/gift_enums.dart';
import '../../dashboard/data/models/gift_model.dart';
import '../../../l10n/app_localizations.dart';

/// Groups gifts eligible for value analysis (gold or currency based) into
/// a fixed, small set of categories, so the UI never has to render an
/// ever-growing per-entry list.
class GiftValueCategory {
  const GiftValueCategory({
    required this.key,
    required this.icon,
  });

  /// `'currency'` or a [GiftType] name.
  final String key;
  final IconData icon;

  String localizedLabel(AppLocalizations l10n) => key == 'currency'
      ? l10n.categoryCurrency
      : GiftType.values.byName(key).localizedLabel(l10n);

  /// Returns the category a gift belongs to, or `null` if it has no rate
  /// captured (nothing to analyze).
  static GiftValueCategory? of(GiftModel gift) {
    if (gift.currencyCode != null) {
      return GiftValueCategory(
        key: 'currency',
        icon: Icons.currency_exchange,
      );
    }
    if (gift.goldRateTl == null) return null;

    switch (gift.giftType) {
      case GiftType.quarterGold:
        return const GiftValueCategory(
          key: 'quarterGold',
          icon: Icons.circle,
        );
      case GiftType.halfGold:
        return const GiftValueCategory(
          key: 'halfGold',
          icon: Icons.circle,
        );
      case GiftType.fullGold:
        return const GiftValueCategory(
          key: 'fullGold',
          icon: Icons.circle,
        );
      case GiftType.gremseGold:
        return const GiftValueCategory(
          key: 'gremseGold',
          icon: Icons.circle,
        );
      case GiftType.gramGold:
        return const GiftValueCategory(
          key: 'gramGold',
          icon: Icons.circle,
        );
      case GiftType.bracelet:
        return const GiftValueCategory(
          key: 'bracelet',
          icon: Icons.watch_outlined,
        );
      case GiftType.necklace:
        return const GiftValueCategory(
          key: 'necklace',
          icon: Icons.diamond_outlined,
        );
      case GiftType.cash:
      case GiftType.other:
        return null;
    }
  }

  static List<MapEntry<GiftValueCategory, List<GiftModel>>> groupBy(
    List<GiftModel> gifts,
  ) {
    final grouped = <String, MapEntry<GiftValueCategory, List<GiftModel>>>{};
    for (final gift in gifts) {
      final category = of(gift);
      if (category == null) continue;
      final existing = grouped[category.key];
      if (existing == null) {
        grouped[category.key] = MapEntry(category, [gift]);
      } else {
        existing.value.add(gift);
      }
    }
    final result = grouped.values.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));
    return result;
  }
}
