import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_converter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../data/models/gift_enums.dart';
import '../../data/repositories/gift_repository.dart';
import '../../domain/budget_summary.dart';

class PersonTotalsList extends StatefulWidget {
  const PersonTotalsList({
    super.key,
    required this.title,
    required this.total,
    required this.people,
    required this.direction,
  });

  final String title;
  final double total;
  final List<PersonTotal> people;
  final GiftDirection direction;

  @override
  State<PersonTotalsList> createState() => _PersonTotalsListState();
}

class _PersonTotalsListState extends State<PersonTotalsList> {
  String? _expandedName;

  @override
  Widget build(BuildContext context) {
    final title = widget.title;
    final total = widget.total;
    final people = widget.people;
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
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                ),
              ),
              Text(
                CurrencyConverter.formatTl(total),
                style: TextStyle(
                  fontSize: 16.sp,
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
                style: TextStyle(
                  color: AppColors.muted(context),
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else
            for (var i = 0; i < people.length; i++)
              Column(
                children: [
                  _personRow(people[i]),
                  if (_expandedName == people[i].name)
                    _personInfoBox(people[i]),
                  if (i != people.length - 1)
                    Divider(
                      height: 1,
                      color: AppColors.muted(context).withValues(alpha: 0.15),
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

    final isExpanded = _expandedName == person.name;

    return InkWell(
      onTap: () => setState(
        () => _expandedName = isExpanded ? null : person.name,
      ),
      child: Padding(
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
                  fontSize: 15.sp,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                person.name,
                style: TextStyle(fontSize: 16.sp, color: AppColors.secondary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              CurrencyConverter.formatTl(person.totalTl),
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.muted(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _personInfoBox(PersonTotal person) {
    final gifts = GiftRepository()
        .getByPerson(person.name)
        .where((g) => g.direction == widget.direction)
        .toList();

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: gifts.isEmpty
          ? Text(
              'Henüz kayıt yok',
              style: TextStyle(
                color: AppColors.muted(context),
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < gifts.length; i++)
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: i == gifts.length - 1 ? 0 : 8.h,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                gifts[i].giftType.label,
                                style: TextStyle(
                                  fontSize: 14.5.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.secondary,
                                ),
                              ),
                              Text(
                                DateFormatter.shortDate(gifts[i].date),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.muted(context),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          CurrencyConverter.formatTl(
                            gifts[i].estimatedValueTl,
                          ),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
