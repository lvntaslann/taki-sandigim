import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/database/box_names.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/basis_badge.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../dashboard/data/models/gift_enums.dart';
import '../../../dashboard/data/models/gift_model.dart';
import '../../data/tracker_repository.dart';
import '../../domain/gift_value_category.dart';

/// Lists the people who have a gift in a single value-analysis category
/// (e.g. "Çeyrek Altın" or "Döviz"). Scoped to one category so this stays a
/// bounded, searchable list instead of the whole app's entries in one page.
class ValueAnalysisListScreen extends StatefulWidget {
  const ValueAnalysisListScreen({super.key, required this.categoryKey});

  final String categoryKey;

  @override
  State<ValueAnalysisListScreen> createState() =>
      _ValueAnalysisListScreenState();
}

class _ValueAnalysisListScreenState extends State<ValueAnalysisListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Değer Analizi')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (v) =>
                  setState(() => _searchQuery = v.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Kişi adına göre ara...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<Box<GiftModel>>(
              valueListenable: Hive.box<GiftModel>(BoxNames.gifts).listenable(),
              builder: (context, box, _) {
                final gifts =
                    TrackerRepository().getAll()
                        .where(
                          (g) => GiftValueCategory.of(g)?.key == widget.categoryKey,
                        )
                        .where((g) => g.personName.toLowerCase().contains(_searchQuery))
                        .toList()
                      ..sort((a, b) => b.date.compareTo(a.date));

                if (gifts.isEmpty) {
                  return Center(
                    child: Text(
                      _searchQuery.isEmpty
                          ? 'Bu kategoride bir kayıt yok.'
                          : 'Sonuç bulunamadı.',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: gifts.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      _ValueGiftRow(gift: gifts[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ValueGiftRow extends StatelessWidget {
  const _ValueGiftRow({required this.gift});

  final GiftModel gift;

  @override
  Widget build(BuildContext context) {
    final isCurrency = gift.currencyCode != null;
    final basisLabel = isCurrency ? gift.currencyCode! : 'Altın';

    return CustomCard(
      onTap: () => context.push(AppRoutes.giftValueAnalysis, extra: gift),
      child: Row(
        children: [
          Icon(
            isCurrency ? Icons.currency_exchange : Icons.trending_up,
            color: AppColors.primary,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${gift.personName} · ${gift.giftType.label}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  DateFormatter.shortDate(gift.date),
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          BasisBadge(label: basisLabel),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
