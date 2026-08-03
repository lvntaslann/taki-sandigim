import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/database/box_names.dart';
import '../../../../core/utils/currency_converter.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../dashboard/data/models/gift_enums.dart';
import '../../../dashboard/data/models/gift_model.dart';
import '../../data/tracker_repository.dart';
import '../../domain/balance_analyzer.dart';
import '../../domain/balance_status.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analiz')),
      body: ValueListenableBuilder<Box<GiftModel>>(
        valueListenable: Hive.box<GiftModel>(BoxNames.gifts).listenable(),
        builder: (context, box, _) {
          final entries = TrackerRepository().getAll();

          if (entries.isEmpty) {
            return const Center(
              child: Text(
                'Analiz için henüz yeterli kayıt yok.',
                style: TextStyle(color: AppColors.textMuted),
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

          return ListView(
            padding: EdgeInsets.all(16.w),
            children: [
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
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    const Text(
                      'Yeşil: bize borçlu · Kırmızı: biz borçluyuz',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    SizedBox(
                      height: 220.h,
                      child: topBalances.isEmpty
                          ? const Center(
                              child: Text(
                                'Herkesle hesap dengede.',
                                style: TextStyle(color: AppColors.textMuted),
                              ),
                            )
                          : _NetBalanceBarChart(balances: topBalances),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _statTile(String label, String value) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted)),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 22.sp,
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
            Text(label, style: const TextStyle(color: AppColors.textMuted)),
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
      return const Center(
        child: Text('Veri yok', style: TextStyle(color: AppColors.textMuted)),
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
              fontSize: 12,
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
              fontSize: 12,
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
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
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
                      ? AppColors.textMuted
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
