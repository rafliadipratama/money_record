import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../injection_container.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../../../transactions/presentation/blocs/transaction_bloc.dart';
import '../../../transactions/presentation/blocs/transaction_event.dart';
import '../../../transactions/presentation/blocs/transaction_state.dart';
import '../widgets/category_donut_chart.dart';
import '../widgets/month_selector_header.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  Future<void> _exportCsv(BuildContext context, DateTime month) async {
    final start = AppDateUtils.startOfMonth(month);
    final end = AppDateUtils.endOfMonth(month);
    final repo = sl<TransactionRepository>();

    try {
      final csvData = await repo.exportTransactionsCsv(start, end);
      await Clipboard.setData(ClipboardData(text: csvData));

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.cardDark,
            title: Text('Export CSV Berhasil', style: AppTypography.headline),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Data CSV transaksi periode ${AppDateUtils.formatMonthYear(month)} telah disalin ke Clipboard.',
                  style: AppTypography.body,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.bgDark,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    csvData.length > 200 ? '${csvData.substring(0, 200)}...' : csvData,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Tutup', style: TextStyle(color: AppColors.primaryAccent)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal export CSV: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        final summary = state.summary;

        return Scaffold(
          backgroundColor: AppColors.bgDark,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              physics: const BouncingScrollPhysics(),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Analisis Keuangan',
                            style: AppTypography.headline,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Evaluasi pengeluaran & tabungan',
                            style: AppTypography.caption,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    MonthSelectorHeader(
                      selectedMonth: state.selectedMonth,
                      onMonthChanged: (m) =>
                          context.read<TransactionBloc>().add(ChangeMonthEvent(m)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // KPI Overview Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Tingkat Tabungan',
                        value: '${summary.savingsRate.toStringAsFixed(0)}%',
                        color: summary.savingsRate >= 20
                            ? AppColors.income
                            : AppColors.textSecondaryDark,
                        subtitle: summary.savingsRate >= 20 ? 'Kondisi Sehat' : 'Perlu Dihemat',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Total Transaksi',
                        value: '${summary.transactionCount}',
                        color: AppColors.primaryAccent,
                        subtitle: 'Aktivitas bulanan',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Donut Chart Breakdown
                CategoryDonutChart(
                  categoryBreakdown: summary.categoryBreakdown,
                  categories: state.categories,
                  totalExpense: summary.totalExpense,
                ),
                const SizedBox(height: 20),

                // Export Data Section
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.cardBorderDark),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Export Laporan (CSV)', style: AppTypography.subheadline),
                          const SizedBox(height: 2),
                          Text('Salin rekap data ke spreadsheet', style: AppTypography.caption),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _exportCsv(context, state.selectedMonth),
                        icon: const Icon(Icons.file_download_outlined, size: 18),
                        label: const Text('Export'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryLight,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: AppColors.cardBorderDark),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.caption),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTypography.balanceDisplay.copyWith(
              fontSize: 24,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: AppTypography.caption.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}
