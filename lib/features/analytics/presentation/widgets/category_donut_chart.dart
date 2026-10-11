import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../categories/domain/entities/category_entity.dart';

class CategoryDonutChart extends StatefulWidget {
  final Map<String, double> categoryBreakdown;
  final List<CategoryEntity> categories;
  final double totalExpense;

  const CategoryDonutChart({
    super.key,
    required this.categoryBreakdown,
    required this.categories,
    required this.totalExpense,
  });

  @override
  State<CategoryDonutChart> createState() => _CategoryDonutChartState();
}

class _CategoryDonutChartState extends State<CategoryDonutChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.totalExpense <= 0 || widget.categoryBreakdown.isEmpty) {
      return Container(
        height: 220,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.cardBorderDark),
        ),
        child: Text(
          'Belum ada data pengeluaran untuk dianalisis',
          style: AppTypography.caption,
        ),
      );
    }

    final entries = widget.categoryBreakdown.entries.toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Proporsi Pengeluaran per Kategori',
            style: AppTypography.subheadline,
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            _touchedIndex = -1;
                            return;
                          }
                          _touchedIndex =
                              pieTouchResponse.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 3,
                    centerSpaceRadius: 65,
                    sections: List.generate(entries.length, (i) {
                      final isTouched = i == _touchedIndex;
                      final radius = isTouched ? 34.0 : 28.0;
                      final entry = entries[i];
                      final cat = widget.categories
                              .where((c) => c.id == entry.key)
                              .firstOrNull ??
                          CategoryEntity(
                            id: entry.key,
                            name: 'Lainnya',
                            iconName: 'category',
                            colorValue: 0xFF64748B,
                            type: TransactionType.expense,
                          );

                      final percentage = (entry.value / widget.totalExpense) * 100;

                      return PieChartSectionData(
                        color: Color(cat.colorValue),
                        value: entry.value,
                        title: isTouched ? '${percentage.toStringAsFixed(0)}%' : '',
                        radius: radius,
                        titleStyle: AppTypography.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }),
                  ),
                ),
                // Center text displaying Total
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Total Keluar',
                      style: AppTypography.caption.copyWith(fontSize: 11),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.formatCompact(widget.totalExpense),
                      style: AppTypography.numberBold.copyWith(
                        fontSize: 16,
                        color: AppColors.expense,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Category Legend list
          ...entries.map((entry) {
            final cat = widget.categories
                    .where((c) => c.id == entry.key)
                    .firstOrNull ??
                CategoryEntity(
                  id: entry.key,
                  name: 'Lainnya',
                  iconName: 'category',
                  colorValue: 0xFF64748B,
                  type: TransactionType.expense,
                );
            final percentage = (entry.value / widget.totalExpense) * 100;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Color(cat.colorValue),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      cat.name,
                      style: AppTypography.bodyMedium.copyWith(fontSize: 13),
                    ),
                  ),
                  Text(
                    '${percentage.toStringAsFixed(1)}% (${CurrencyFormatter.formatCompact(entry.value)})',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondaryDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
