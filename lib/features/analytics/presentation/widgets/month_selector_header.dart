import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/date_utils.dart';

class MonthSelectorHeader extends StatelessWidget {
  final DateTime selectedMonth;
  final ValueChanged<DateTime> onMonthChanged;

  const MonthSelectorHeader({
    super.key,
    required this.selectedMonth,
    required this.onMonthChanged,
  });

  void _previousMonth() {
    onMonthChanged(DateTime(selectedMonth.year, selectedMonth.month - 1, 1));
  }

  void _nextMonth() {
    onMonthChanged(DateTime(selectedMonth.year, selectedMonth.month + 1, 1));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorderDark),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: _previousMonth,
            icon: const Icon(
              Icons.chevron_left_rounded,
              color: AppColors.textPrimaryDark,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            tooltip: 'Bulan Sebelumnya',
          ),
          const SizedBox(width: 8),
          Text(
            AppDateUtils.formatMonthYear(selectedMonth),
            style: AppTypography.subheadline.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _nextMonth,
            icon: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textPrimaryDark,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            tooltip: 'Bulan Berikutnya',
          ),
        ],
      ),
    );
  }
}
