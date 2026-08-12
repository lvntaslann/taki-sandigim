import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/database/box_names.dart';
import '../../../../core/network/gold_rate_service.dart';
import '../../../../core/utils/currency_converter.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../dashboard/data/models/gift_enums.dart';
import '../../../dashboard/data/models/gift_model.dart';
import '../../data/tracker_repository.dart';
import '../../domain/balance_analyzer.dart';
import '../../domain/balance_status.dart';
import '../../domain/gift_value_category.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final _goldRateService = GoldRateService();
  double? _currentGoldRateTl;
  bool _isRateLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRate();
  }

  Future<void> _loadRate() async {
    setState(() => _isRateLoading = true);
    final rate = await _goldRateService.getGoldRateTl();
    if (!mounted) return;
    setState(() {
      _currentGoldRateTl = rate;
      _isRateLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analiz')),
      body: ValueListenableBuilder<Box<GiftModel>>(
        valueListenable: Hive.box<GiftModel>(BoxNames.gifts).listenable(),
        builder: (context, box, _) {
          final entries = TrackerRepository().getAll();

          if (entries.isEmpty) {
            return Center(
              child: Text(
                'Analiz için henüz yeterli kayıt yok.',
                style: TextStyle(
                  color: AppColors.muted(context),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }

          final totalReceived = entries
              .where((e) => e.direction == GiftDirection.received)
              .fold<double>(0, (s, e) => s + e.estimatedValueTl);
          final totalGiven = entries
              .where((e) => e.direction == GiftDirection.given)
              .fold<double>(0, (s, e) => s + e.estimatedValueTl);

          final personCount = entries.map((e) => e.personName).toSet().length;
          final balances = BalanceAnalyzer.calculate(entries);

          final appearanceOrder = <String, int>{};
          for (final e in entries) {
            appearanceOrder.putIfAbsent(
              e.personName,
              () => appearanceOrder.length,
            );
          }
          int orderOf(BalanceStatus b) => appearanceOrder[b.personName] ?? 0;

          final theyOweBalances =
              balances.where((b) => !b.isBalanced && !b.weOwe).toList()
                ..sort((a, b) => a.balanceTl.compareTo(b.balanceTl));
          final weOweBalances =
              balances.where((b) => !b.isBalanced && b.weOwe).toList()
                ..sort((a, b) => a.balanceTl.compareTo(b.balanceTl));
          final balancedBalances = balances.where((b) => b.isBalanced).toList()
            ..sort((a, b) => orderOf(a).compareTo(orderOf(b)));
          final topBalances = [
            ...theyOweBalances,
            ...weOweBalances,
            ...balancedBalances,
          ];

          final categories = GiftValueCategory.groupBy(entries);

          return ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              _goldRateCard(),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: _statTile('Toplam Kayıt', '${entries.length}'),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(child: _statTile('Kişi Sayısı', '$personCount')),
                ],
              ),
              SizedBox(height: 16.h),
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hediye Dağılımı',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _ReceivedGivenBar(
                      received: totalReceived,
                      given: totalGiven,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kişi Bazında Net Bakiye',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    if (topBalances.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Biz borçluyuz',
                            style: TextStyle(
                              fontSize: 15,
                              color: _NetBalanceBarChart._weOweColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Bize borçlu',
                            style: TextStyle(
                              fontSize: 15,
                              color: _NetBalanceBarChart._theyOweColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: 16.h),
                    topBalances.isEmpty
                        ? SizedBox(
                            height: 80.h,
                            child: Center(
                              child: Text(
                                'Herkesle hesap dengede.',
                                style: TextStyle(
                                  color: AppColors.muted(context),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                        : SizedBox(
                            height:
                                topBalances.length * 32.h - 10.h,
                            child: _NetBalanceBarChart(balances: topBalances),
                          ),
                  ],
                ),
              ),
              if (categories.isNotEmpty) ...[
                SizedBox(height: 16.h),
                Text(
                  'Değer Analizi',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                Text(
                  'Bir kategoriye dokun, içindeki kişileri ve değer '
                  'değişimlerini incele.',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.muted(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 12.h),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: categories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.05,
                  ),
                  itemBuilder: (context, index) {
                    final entry = categories[index];
                    return _categoryTile(entry.key, entry.value.length);
                  },
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _goldRateCard() {
    return CustomCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.monetization_on_outlined, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Güncel Gram Altın Kuru',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                _isRateLoading
                    ? Text(
                        'Güncelleniyor...',
                        style: TextStyle(
                          color: AppColors.muted(context),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    : Text(
                        CurrencyConverter.formatTl(_currentGoldRateTl ?? 0),
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
              ],
            ),
          ),
          IconButton(
            onPressed: _isRateLoading ? null : _loadRate,
            icon: Icon(Icons.refresh, color: AppColors.muted(context)),
          ),
        ],
      ),
    );
  }

  Widget _categoryTile(GiftValueCategory category, int count) {
    return CustomCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      onTap: () => context.push(
        AppRoutes.valueAnalysisList,
        extra: category.key,
      ),
      child: Row(
        children: [
          Icon(category.icon, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                Text(
                  '$count kayıt',
                  style: TextStyle(
                    color: AppColors.muted(context),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statTile(String label, String value) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.muted(context),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 23.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

}

class _ReceivedGivenBar extends StatelessWidget {
  const _ReceivedGivenBar({required this.received, required this.given});

  final double received;
  final double given;

  @override
  Widget build(BuildContext context) {
    final total = received + given;
    if (total <= 0) {
      return Center(
        child: Text(
          'Veri yok',
          style: TextStyle(
            color: AppColors.muted(context),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    final receivedRatio = received / total;
    final receivedPercent = (receivedRatio * 100).round();
    final givenPercent = 100 - receivedPercent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _amountColumn(
              context,
              'BİZE GELEN',
              CurrencyConverter.formatTl(received),
              AppColors.primary,
              CrossAxisAlignment.start,
            ),
            _amountColumn(
              context,
              'BİZİM VERDİĞİMİZ',
              CurrencyConverter.formatTl(given),
              AppColors.secondary,
              CrossAxisAlignment.end,
            ),
          ],
        ),
        SizedBox(height: 14.h),
        SizedBox(
          height: 28.h,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final barHeight = 28.h;
              final totalWidth = constraints.maxWidth;
              final splitWidth = totalWidth * receivedRatio;
              final givenWidth = totalWidth - splitWidth;
              final capOverlap = barHeight / 2;
              final receivedOnTop = receivedRatio >= 0.5;

              Widget bar(double width, List<Color> colors) => Container(
                width: width.clamp(0, totalWidth),
                height: barHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: LinearGradient(colors: colors),
                ),
              );

              const receivedColors = [AppColors.primary, Color(0xFFFFD873)];
              const givenColors = [Color(0xFF6B4A26), AppColors.secondary];

              return Stack(
                children: receivedOnTop
                    ? [
                        bar(totalWidth, givenColors),
                        bar(splitWidth + capOverlap, receivedColors),
                      ]
                    : [
                        bar(totalWidth, receivedColors),
                        Positioned(
                          right: 0,
                          child: bar(givenWidth + capOverlap, givenColors),
                        ),
                      ],
              );
            },
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '%$receivedPercent',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.muted(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '%$givenPercent',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.muted(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _amountColumn(
    BuildContext context,
    String label,
    String value,
    Color valueColor,
    CrossAxisAlignment align,
  ) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.muted(context),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _NetBalanceBarChart extends StatelessWidget {
  const _NetBalanceBarChart({required this.balances});

  final List<BalanceStatus> balances;

  static const _theyOweColor = Color(0xFF4A5D5A);
  static const _weOweColor = Color(0xFF964B3B);

  @override
  Widget build(BuildContext context) {
    final maxValue = balances
        .map((b) => b.balanceTl.abs())
        .fold<double>(1, (a, b) => a > b ? a : b);

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: balances.length,
      separatorBuilder: (context, index) => SizedBox(height: 10.h),
      itemBuilder: (context, index) {
        final balance = balances[index];
        final fraction = maxValue <= 0
            ? 0.0
            : (balance.balanceTl.abs() / maxValue).clamp(0.0, 1.0);
        final barColor = balance.isBalanced
            ? AppColors.muted(context)
            : balance.weOwe
            ? _weOweColor
            : _theyOweColor;
        final name = balance.personName;
        final short = name.length > 10 ? '${name.substring(0, 9)}…' : name;

        return InkWell(
          onTap: () => _showBalanceInfo(context, balance),
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 22.h,
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: FractionallySizedBox(
                      alignment: Alignment.centerRight,
                      widthFactor: balance.weOwe ? fraction : 0,
                      child: Container(
                        height: 20.h,
                        decoration: BoxDecoration(
                          color: _weOweColor,
                          borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(999),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 92.w,
                  child: Text(
                    short,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.muted(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: !balance.weOwe && !balance.isBalanced
                          ? fraction
                          : 0,
                      child: Container(
                        height: 20.h,
                        decoration: BoxDecoration(
                          color: barColor,
                          borderRadius: BorderRadius.horizontal(
                            right: Radius.circular(999),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showBalanceInfo(BuildContext context, BalanceStatus balance) {
    final statusText = balance.isBalanced
        ? 'Hesap dengede'
        : balance.weOwe
        ? 'Biz borçluyuz'
        : 'Bize borçlu';
    final statusColor = balance.isBalanced
        ? AppColors.muted(context)
        : balance.weOwe
        ? _weOweColor
        : _theyOweColor;

    final hasBothSides = balance.receivedTl > 0 && balance.givenTl > 0;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(balance.personName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasBothSides) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${balance.personName} taktı',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.muted(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    CurrencyConverter.formatTl(balance.receivedTl),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Biz taktık',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.muted(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    CurrencyConverter.formatTl(balance.givenTl),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
            ],
            Text(
              CurrencyConverter.formatTl(balance.balanceTl.abs()),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              statusText,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }
}
