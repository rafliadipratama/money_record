import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/date_utils.dart';

class CalendarMonthHeader extends StatelessWidget {
  final DateTime currentMonth;
  final ValueChanged<DateTime> onMonthChanged;
  final VoidCallback onTodayPressed;

  const CalendarMonthHeader({
    super.key,
    required this.currentMonth,
    required this.onMonthChanged,
    required this.onTodayPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrentMonthNow =
        currentMonth.year == DateTime.now().year &&
        currentMonth.month == DateTime.now().month;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorderDark),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  size: 20,
                  color: AppColors.primaryAccent,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppDateUtils.formatMonthYear(currentMonth),
                    style: AppTypography.headline.copyWith(fontSize: 18),
                  ),
                  Text(
                    'Kalender Finansial',
                    style: AppTypography.caption.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              if (!isCurrentMonthNow) ...[
                InkWell(
                  onTap: onTodayPressed,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.cardBorderDark),
                    ),
                    child: Text(
                      'Hari Ini',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primaryAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              IconButton(
                onPressed: () {
                  final prev = DateTime(
                    currentMonth.year,
                    currentMonth.month - 1,
                    1,
                  );
                  onMonthChanged(prev);
                },
                icon: const Icon(Icons.chevron_left_rounded, size: 22),
                color: AppColors.textPrimaryDark,
                visualDensity: VisualDensity.compact,
                splashRadius: 20,
              ),
              IconButton(
                onPressed: () {
                  final next = DateTime(
                    currentMonth.year,
                    currentMonth.month + 1,
                    1,
                  );
                  onMonthChanged(next);
                },
                icon: const Icon(Icons.chevron_right_rounded, size: 22),
                color: AppColors.textPrimaryDark,
                visualDensity: VisualDensity.compact,
                splashRadius: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
