import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../analytics/presentation/widgets/month_selector_header.dart';
import '../blocs/transaction_bloc.dart';
import '../blocs/transaction_event.dart';
import '../blocs/transaction_state.dart';
import '../widgets/balance_hero_card.dart';
import '../widgets/cashflow_spline_chart.dart';
import '../widgets/interactive_numpad_sheet.dart';
import '../widgets/transaction_tile.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        final daysInMonth = DateTime(
          state.selectedMonth.year,
          state.selectedMonth.month + 1,
          0,
        ).day;

        return Scaffold(
          backgroundColor: AppColors.bgDark,
          body: SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Top App Bar
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'MoneyRecord',
                                style: AppTypography.headline.copyWith(
                                  color: AppColors.primaryAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                                maxLines: 1,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Kelola arus kas bulanan',
                                style: AppTypography.caption,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        MonthSelectorHeader(
                          selectedMonth: state.selectedMonth,
                          onMonthChanged: (month) {
                            context.read<TransactionBloc>().add(
                              ChangeMonthEvent(month),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Hero Balance Card
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: BalanceHeroCard(
                      summary: state.summary,
                      isPrivacyMode: state.isPrivacyMode,
                      onTogglePrivacy: () {
                        context.read<TransactionBloc>().add(
                          const TogglePrivacyModeEvent(),
                        );
                      },
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 18)),

                // Spline Area Cashflow Chart
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: CashflowSplineChart(
                      dailyExpenses: state.summary.dailyExpenses,
                      daysInMonth: daysInMonth,
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Transactions Section Title
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Catatan Transaksi',
                          style: AppTypography.subheadline,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.cardDark,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.cardBorderDark),
                          ),
                          child: Text(
                            '${state.transactions.length} item',
                            style: AppTypography.caption,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                // Transactions List
                if (state.transactions.isEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                    sliver: SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.cardDark,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.cardBorderDark),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 44,
                              color: AppColors.textMutedDark.withOpacity(0.5),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Belum ada transaksi di bulan ini',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textSecondaryDark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Tekan tombol + di bawah untuk mencatat pengeluaran atau pemasukan pertama.',
                              textAlign: TextAlign.center,
                              style: AppTypography.caption,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final tx = state.transactions[index];
                        final category = state.categories
                            .where((c) => c.id == tx.categoryId)
                            .firstOrNull;

                        return TransactionTile(
                          transaction: tx,
                          category: category,
                          isPrivacyMode: state.isPrivacyMode,
                          onDelete: () {
                            context.read<TransactionBloc>().add(
                              DeleteTransactionEvent(tx.id),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Transaksi "${tx.title}" berhasil dihapus',
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        );
                      }, childCount: state.transactions.length),
                    ),
                  ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              InteractiveNumpadSheet.show(
                context,
                categories: state.categories,
                onSave: (tx) {
                  context.read<TransactionBloc>().add(AddTransactionEvent(tx));
                },
              );
            },
            backgroundColor: AppColors.primaryAccent,
            foregroundColor: Colors.white,
            elevation: 4,
            icon: const Icon(Icons.add_rounded, size: 24),
            label: Text(
              'Catat Transaksi',
              style: AppTypography.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }
}
