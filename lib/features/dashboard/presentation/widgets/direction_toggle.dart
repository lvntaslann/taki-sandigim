import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_colors.dart';
import '../../data/models/gift_enums.dart';

class DirectionToggle extends StatelessWidget {
  const DirectionToggle({
    super.key,
    required this.selected,
    required this.onChanged,
    this.receivedLabel = 'Bize Takılanlar',
    this.givenLabel = 'Bizim Taktığımız',
  });

  final GiftDirection selected;
  final ValueChanged<GiftDirection> onChanged;
  final String receivedLabel;
  final String givenLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(28.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: _segment(
              label: receivedLabel,
              isSelected: selected == GiftDirection.received,
              onTap: () => onChanged(GiftDirection.received),
            ),
          ),
          Expanded(
            child: _segment(
              label: givenLabel,
              isSelected: selected == GiftDirection.given,
              onTap: () => onChanged(GiftDirection.given),
            ),
          ),
        ],
      ),
    );
  }

  Widget _segment({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(24.r),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppColors.primaryDark,
          ),
        ),
      ),
    );
  }
}
