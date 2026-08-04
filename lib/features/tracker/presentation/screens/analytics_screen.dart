import 'package:fl_chart/fl_chart.dart';
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
          final balances = BalanceAnalyzer.calculate(entries)
            ..sort((a, b) => b.balanceTl.abs().compareTo(a.balanceTl.abs()));
          final topBalances = balances.take(6).toList();

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
                      'Bize Gelen / Bizim Verdiğimiz',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    SizedBox(
                      height: 180.h,
                      child: _ReceivedGivenDonut(
                        received: totalReceived,
                        given: totalGiven,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _legendItem(
                          AppColors.success,
                          'Bize Gelen',
                          CurrencyConverter.formatTl(totalReceived),
                        ),
                        _legendItem(
                          AppColors.accent,
                          'Bizim Verdiğimiz',
                          CurrencyConverter.formatTl(totalGiven),
                        ),
                      ],
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
                    Text(
                      'Yeşil: bize borçlu · Kırmızı: biz borçluyuz',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.muted(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    SizedBox(
                      height: 220.h,
                      child: topBalances.isEmpty
                          ? Center(
                              child: Text(
                                'Herkesle hesap dengede.',
                                style: TextStyle(
                                  color: AppColors.muted(context),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                          : _NetBalanceBarChart(balances: topBalances),
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

  Widget _legendItem(Color color, String label, String value) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: AppColors.muted(context),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _ReceivedGivenDonut extends StatelessWidget {
  const _ReceivedGivenDonut({required this.received, required this.given});

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

    return PieChart(
      PieChartData(
        sectionsSpace: 3,
        centerSpaceRadius: 46,
        sections: [
          PieChartSectionData(
            value: received,
            color: AppColors.success,
            title: '${(received / total * 100).round()}%',
            titleStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
            radius: 42,
          ),
          PieChartSectionData(
            value: given,
            color: AppColors.accent,
            title: '${(given / total * 100).round()}%',
            titleStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
            radius: 42,
          ),
        ],
      ),
    );
  }
}

class _NetBalanceBarChart extends StatelessWidget {
  const _NetBalanceBarChart({required this.balances});

  final List<BalanceStatus> balances;

  @override
  Widget build(BuildContext context) {
    final maxValue = balances
        .map((b) => b.balanceTl.abs())
        .fold<double>(1, (a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        maxY: maxValue * 1.2,
        minY: -maxValue * 1.2,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= balances.length) {
                  return const SizedBox.shrink();
                }
                final name = balances[index].personName;
                final short = name.length > 8
                    ? '${name.substring(0, 7)}…'
                    : name;
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    short,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.muted(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < balances.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: balances[i].balanceTl,
                  width: 22,
                  borderRadius: BorderRadius.circular(6),
                  color: balances[i].isBalanced
                      ? AppColors.muted(context)
                      : balances[i].weOwe
                      ? AppColors.error
                      : AppColors.success,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
