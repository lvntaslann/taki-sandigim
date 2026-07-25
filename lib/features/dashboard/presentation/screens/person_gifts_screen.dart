import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_converter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../data/models/gift_enums.dart';
import '../../data/models/gift_model.dart';
import '../../data/repositories/gift_repository.dart';

class PersonGiftsScreen extends StatelessWidget {
  const PersonGiftsScreen({
    super.key,
    required this.personName,
    required this.direction,
  });

  final String personName;
  final GiftDirection direction;

  @override
  Widget build(BuildContext context) {
    final gifts = GiftRepository()
        .getByPerson(personName)
        .where((g) => g.direction == direction)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(personName),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.secondary,
        elevation: 0,
      ),
      body: gifts.isEmpty
          ? Center(
              child: Text(
                'Henüz kayıt yok',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13.sp),
              ),
            )
          : ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: gifts.length,
              separatorBuilder: (_, _) => SizedBox(height: 10.h),
              itemBuilder: (context, index) => _GiftTile(gift: gifts[index]),
            ),
    );
  }
}

class _GiftTile extends StatelessWidget {
  const _GiftTile({required this.gift});

  final GiftModel gift;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.card_giftcard_outlined,
              color: AppColors.primary,
              size: 18.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gift.giftType.label,
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  DateFormatter.shortDate(gift.date),
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    color: AppColors.textMuted,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  gift.eventType?.locationLabel ?? 'Etkinlik belirtilmemiş',
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            CurrencyConverter.formatTl(gift.estimatedValueTl),
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
