import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/monthly_summary.dart';

class BalanceHeroCard extends StatelessWidget {
  final MonthlySummary summary;
  final bool isPrivacyMode;
  final VoidCallback onTogglePrivacy;

  const BalanceHeroCard({
    super.key,
    required this.summary,
    required this.isPrivacyMode,
    required this.onTogglePrivacy,
  });

  @override
  Widget build(BuildContext context) {
    final netSavings = summary.netSavings;
    final isPositive = netSavings >= 0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.cardDark.withOpacity(0.85),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.cardBorderDark,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primaryAccent.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          'Saldo Bersih Bulan Ini',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.primaryAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: onTogglePrivacy,
                    icon: Icon(
                      isPrivacyMode ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      color: AppColors.textSecondaryDark,
                      size: 22,
                    ),
                    tooltip: isPrivacyMode ? 'Tampilkan Saldo' : 'Sembunyikan Saldo',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  isPrivacyMode
                      ? '••••••••••'
                      : CurrencyFormatter.format(netSavings),
                  key: ValueKey(isPrivacyMode ? 'hidden' : netSavings),
                  style: AppTypography.balanceDisplay.copyWith(
                    color: isPositive ? AppColors.textPrimaryDark : AppColors.expense,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Split Income and Expense Tiles
              Row(
                children: [
                  Expanded(
                    child: _buildFlowTile(
                      label: 'Pemasukan',
                      amount: summary.totalIncome,
                      icon: Icons.arrow_downward_rounded,
                      color: AppColors.income,
                      bgColor: AppColors.income.withOpacity(0.12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildFlowTile(
                      label: 'Pengeluaran',
                      amount: summary.totalExpense,
                      icon: Icons.arrow_upward_rounded,
                      color: AppColors.expense,
                      bgColor: AppColors.expense.withOpacity(0.12),
                    ),
                  ),
                ],
              ),
              if (summary.totalIncome > 0) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (summary.totalExpense / summary.totalIncome).clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: AppColors.income.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      (summary.totalExpense / summary.totalIncome) > 0.85
                          ? AppColors.expense
                          : AppColors.primaryAccent,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tingkat Tabungan: ${summary.savingsRate.toStringAsFixed(0)}%',
                      style: AppTypography.caption.copyWith(
                        color: summary.savingsRate >= 20
                            ? AppColors.income
                            : AppColors.textMutedDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Pengeluaran ${((summary.totalExpense / summary.totalIncome) * 100).toStringAsFixed(0)}%',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildFlowTile({
    required String label,
    required double amount,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.caption.copyWith(color: AppColors.textSecondaryDark),
                ),
                const SizedBox(height: 2),
                Text(
                  isPrivacyMode ? '••••••' : CurrencyFormatter.formatCompact(amount),
                  style: AppTypography.numberBold.copyWith(
                    fontSize: 14,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
