import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_converter.dart';
import '../../domain/budget_summary.dart';

class PersonTotalsList extends StatelessWidget {
  const PersonTotalsList({
    super.key,
    required this.title,
    required this.total,
    required this.people,
  });

  final String title;
  final double total;
  final List<PersonTotal> people;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                ),
              ),
              Text(
                CurrencyConverter.formatTl(total),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          if (people.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Text(
                'Henüz kayıt yok',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13.sp),
              ),
            )
          else
            for (var i = 0; i < people.length; i++)
              Column(
                children: [
                  _personRow(people[i]),
                  if (i != people.length - 1)
                    Divider(
                      height: 1,
                      color: AppColors.textMuted.withValues(alpha: 0.15),
                    ),
                ],
              ),
        ],
      ),
    );
  }

  Widget _personRow(PersonTotal person) {
    final initials = person.name.trim().isEmpty
        ? '?'
        : person.name
            .trim()
            .split(RegExp(r'\s+'))
            .map((part) => part[0])
            .take(2)
            .join()
            .toUpperCase();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18.r,
            backgroundColor: AppColors.primary.withValues(alpha: 0.18),
            child: Text(
              initials,
              style: TextStyle(
                color: AppColors.secondary,
                fontWeight: FontWeight.w700,
                fontSize: 13.sp,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              person.name,
              style: TextStyle(fontSize: 14.sp, color: AppColors.secondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            CurrencyConverter.formatTl(person.totalTl),
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
