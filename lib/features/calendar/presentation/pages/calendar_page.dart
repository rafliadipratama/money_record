import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../transactions/presentation/blocs/transaction_bloc.dart';
import '../../../transactions/presentation/blocs/transaction_event.dart';
import '../../../transactions/presentation/blocs/transaction_state.dart';
import '../../../transactions/presentation/widgets/interactive_numpad_sheet.dart';
import '../widgets/calendar_grid_view.dart';
import '../widgets/calendar_month_header.dart';
import '../widgets/daily_breakdown_section.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  void _onMonthChanged(BuildContext context, DateTime newMonth) {
    context.read<TransactionBloc>().add(ChangeMonthEvent(newMonth));
    setState(() {
      // If today is in the new month, default to today; otherwise, 1st of month
      final now = DateTime.now();
      if (now.year == newMonth.year && now.month == newMonth.month) {
        _selectedDate = now;
      } else {
        _selectedDate = DateTime(newMonth.year, newMonth.month, 1);
      }
    });
  }

  void _onTodayPressed(BuildContext context) {
    final now = DateTime.now();
    context.read<TransactionBloc>().add(
      ChangeMonthEvent(DateTime(now.year, now.month, 1)),
    );
    setState(() {
      _selectedDate = now;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state.status == TransactionStatus.loading &&
            state.transactions.isEmpty) {
          return const Scaffold(
            backgroundColor: AppColors.bgDark,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primaryAccent),
            ),
          );
        }

        final currentMonth = state.selectedMonth;

        return Scaffold(
          backgroundColor: AppColors.bgDark,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                // Top App Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kalender Finansial',
                              style: AppTypography.headline,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Kontrol & lacak cashflow harian',
                              style: AppTypography.caption,
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () {
                            context.read<TransactionBloc>().add(
                              const TogglePrivacyModeEvent(),
                            );
                          },
                          icon: Icon(
                            state.isPrivacyMode
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.textSecondaryDark,
                            size: 22,
                          ),
                          tooltip: 'Mode Privasi',
                        ),
                      ],
                    ),
                  ),
                ),

                // Calendar Content
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Month Switcher Header
                      CalendarMonthHeader(
                        currentMonth: currentMonth,
                        onMonthChanged: (m) => _onMonthChanged(context, m),
                        onTodayPressed: () => _onTodayPressed(context),
                      ),
                      const SizedBox(height: 16),

                      // Monthly Interactive Calendar Grid
                      CalendarGridView(
                        currentMonth: currentMonth,
                        selectedDate: _selectedDate,
                        transactions: state.transactions,
                        onDateSelected: (date) {
                          setState(() => _selectedDate = date);
                        },
                      ),
                      const SizedBox(height: 24),

                      // Daily Breakdown & Transaction List
                      DailyBreakdownSection(
                        selectedDate: _selectedDate,
                        transactions: state.transactions,
                        categories: state.categories,
                        isPrivacyMode: state.isPrivacyMode,
                        onDeleteTransaction: (id) {
                          final tx = state.transactions
                              .where((t) => t.id == id)
                              .firstOrNull;
                          context.read<TransactionBloc>().add(
                            DeleteTransactionEvent(id),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Transaksi "${tx?.title ?? ''}" dihapus',
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        onAddTransaction: () {
                          InteractiveNumpadSheet.show(
                            context,
                            categories: state.categories,
                            initialDate: _selectedDate,
                            onSave: (tx) {
                              context.read<TransactionBloc>().add(
                                AddTransactionEvent(tx),
                              );
                            },
                          );
                        },
                      ),
                    ]),
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
                initialDate: _selectedDate,
                onSave: (tx) {
                  context.read<TransactionBloc>().add(AddTransactionEvent(tx));
                },
              );
            },
            backgroundColor: AppColors.primaryAccent,
            foregroundColor: Colors.black,
            icon: const Icon(Icons.add_rounded, size: 22),
            label: Text(
              'Catat (${AppDateUtils.formatRelativeDate(_selectedDate)})',
              style: AppTypography.bodyMedium.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      },
    );
  }
}
