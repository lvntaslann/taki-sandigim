import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_converter.dart';
import '../../data/models/gift_enums.dart';

class BalanceBreakdownCard extends StatelessWidget {
  const BalanceBreakdownCard({super.key, required this.breakdown});

  final Map<GiftType, double> breakdown;

  static const List<Color> _palette = [
    AppColors.primary,
    AppColors.accent,
    AppColors.secondary,
    AppColors.textMuted,
    Color(0xFF7C6A9C),
    Color(0xFFB98A4A),
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
            'Toplam bakiye',
            style: TextStyle(fontSize: 14.sp, color: AppColors.textMuted),
          ),
          SizedBox(height: 6.h),
          Text(
            CurrencyConverter.formatTl(total),
            style: TextStyle(
              fontSize: 30.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.secondary,
            ),
          ),
          SizedBox(height: 20.h),
          if (entries.isEmpty || total <= 0)
            _emptyState()
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: SizedBox(
                    width: 110.w,
                    height: 110.w,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 34.r,
                        startDegreeOffset: -90,
                        sections: [
                          for (var i = 0; i < entries.length; i++)
                            PieChartSectionData(
                              value: entries[i].value,
                              color: _palette[i % _palette.length],
                              radius: 20.r,
                              showTitle: false,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                for (var i = 0; i < entries.length; i++)
                  Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: _legendRow(
                      color: _palette[i % _palette.length],
                      label: entries[i].key.label,
                      percent: (entries[i].value / total * 100).round(),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _legendRow({
    required Color color,
    required String label,
    required int percent,
  }) {
    return Row(
      children: [
        Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 13.sp, color: AppColors.secondary),
          ),
        ),
        Text(
          '%$percent',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.h),
      child: Center(
        child: Text(
          'Henüz kayıt yok',
          style: TextStyle(color: AppColors.textMuted, fontSize: 13.sp),
        ),
      ),
    );
  }
}
