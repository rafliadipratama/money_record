import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../transactions/presentation/widgets/transaction_tile.dart';

class DailyBreakdownSection extends StatelessWidget {
  final DateTime selectedDate;
  final List<TransactionEntity> transactions;
  final List<CategoryEntity> categories;
  final bool isPrivacyMode;
  final ValueChanged<String> onDeleteTransaction;
  final VoidCallback onAddTransaction;

  const DailyBreakdownSection({
    super.key,
    required this.selectedDate,
    required this.transactions,
    required this.categories,
    required this.isPrivacyMode,
    required this.onDeleteTransaction,
    required this.onAddTransaction,
  });

  @override
  Widget build(BuildContext context) {
    final dayTxs = transactions
        .where((tx) => AppDateUtils.isSameDay(tx.date, selectedDate))
        .toList();

    final dayIncome = dayTxs
        .where((tx) => tx.type == TransactionType.income)
        .fold(0.0, (sum, tx) => sum + tx.amount);

    final dayExpense = dayTxs
        .where((tx) => tx.type == TransactionType.expense)
        .fold(0.0, (sum, tx) => sum + tx.amount);

    final dayNet = dayIncome - dayExpense;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppDateUtils.formatFullDate(selectedDate),
                    style: AppTypography.subheadline.copyWith(
                      color: AppColors.textPrimaryDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${dayTxs.length} Transaksi Tercatat',
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onAddTransaction,
              icon: const Icon(Icons.add_circle_outline_rounded),
              color: AppColors.primaryAccent,
              tooltip: 'Tambah transaksi pada tanggal ini',
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Bento Daily Mini-KPIs
        Row(
          children: [
            Expanded(
              child: _buildMiniKpi(
                label: 'Pemasukan',
                amount: dayIncome,
                color: AppColors.income,
                icon: Icons.arrow_downward_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMiniKpi(
                label: 'Pengeluaran',
                amount: dayExpense,
                color: AppColors.expense,
                icon: Icons.arrow_upward_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMiniKpi(
                label: 'Selisih',
                amount: dayNet,
                color: dayNet >= 0
                    ? AppColors.primaryAccent
                    : AppColors.expense,
                icon: Icons.account_balance_wallet_outlined,
                showSign: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Daily Transaction List
        if (dayTxs.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cardBorderDark),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.event_busy_rounded,
                  size: 40,
                  color: AppColors.textMutedDark.withOpacity(0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  'Belum ada transaksi di tanggal ini',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: onAddTransaction,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Catat Transaksi Hari Ini'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryAccent,
                    side: const BorderSide(color: AppColors.primaryAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ...dayTxs.map((tx) {
            final category = categories
                .where((c) => c.id == tx.categoryId)
                .firstOrNull;

            return TransactionTile(
              transaction: tx,
              category: category,
              isPrivacyMode: isPrivacyMode,
              onDelete: () => onDeleteTransaction(tx.id),
            );
          }),
      ],
    );
  }

  Widget _buildMiniKpi({
    required String label,
    required double amount,
    required Color color,
    required IconData icon,
    bool showSign = false,
  }) {
    final prefix = showSign && amount > 0 ? '+' : '';
    final formatted = isPrivacyMode
        ? '••••••••'
        : '$prefix${CurrencyFormatter.format(amount)}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              formatted,
              style: AppTypography.balanceDisplay.copyWith(
                fontSize: 13,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
