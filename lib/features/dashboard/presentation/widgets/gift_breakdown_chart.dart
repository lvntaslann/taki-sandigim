import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_converter.dart';
import '../../data/models/gift_enums.dart';

class GiftBreakdownChart extends StatelessWidget {
  const GiftBreakdownChart({super.key, required this.breakdown});

  final Map<GiftType, double> breakdown;

  static const List<Color> _palette = [
    AppColors.primary,
    AppColors.primaryDark,
    AppColors.accent,
    AppColors.secondary,
    Color(0xFF7C6A9C),
    AppColors.textMuted,
  ];

  @override
  Widget build(BuildContext context) {
    final total = breakdown.values.fold<double>(0, (a, b) => a + b);
    final entries = breakdown.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Takılanların Dağılımı',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 16.h),
          if (entries.isEmpty || total <= 0)
            _emptyState(context)
          else ...[
            SizedBox(
              height: 200.h,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 62.r,
                      startDegreeOffset: -90,
                      sections: [
                        for (var i = 0; i < entries.length; i++)
                          PieChartSectionData(
                            value: entries[i].value,
                            color: _palette[i % _palette.length],
                            radius: 34.r,
                            showTitle: true,
                            title:
                                '${(entries[i].value / total * 100).round()}%',
                            titleStyle: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            titlePositionPercentageOffset: 0.6,
                          ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        CurrencyConverter.formatTl(total),
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.secondary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Toplam Takılan',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Wrap(
              spacing: 16.w,
              runSpacing: 8.h,
              children: [
                for (var i = 0; i < entries.length; i++)
                  _legendItem(
                    color: _palette[i % _palette.length],
                    label: entries[i].key.label,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _legendItem({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 6.w),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: AppColors.secondary),
        ),
      ],
    );
  }

  Widget _emptyState(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.h),
      child: Center(
        child: Text(
          'Henüz takı kaydı yok',
          style: TextStyle(color: AppColors.textMuted, fontSize: 13.sp),
        ),
      ),
    );
  }
}
