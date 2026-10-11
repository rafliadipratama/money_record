import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:money_record/features/categories/domain/entities/category_entity.dart';
import 'package:money_record/features/calendar/presentation/widgets/calendar_grid_view.dart';
import 'package:money_record/features/calendar/presentation/widgets/daily_breakdown_section.dart';
import 'package:money_record/features/transactions/domain/entities/transaction_entity.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });
  group('CalendarGridView Widget Tests', () {
    testWidgets('renders days and fires onDateSelected when tapped', (
      tester,
    ) async {
      final month = DateTime(2026, 10, 1);
      DateTime selected = DateTime(2026, 10, 11);
      final transactions = [
        TransactionEntity(
          id: '1',
          title: 'Gaji Pokok',
          amount: 5000000,
          type: TransactionType.income,
          categoryId: 'cat_income',
          date: DateTime(2026, 10, 11, 10, 0),
        ),
        TransactionEntity(
          id: '2',
          title: 'Belanja Sayur',
          amount: 45000,
          type: TransactionType.expense,
          categoryId: 'cat_food',
          date: DateTime(2026, 10, 11, 12, 0),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarGridView(
              currentMonth: month,
              selectedDate: selected,
              transactions: transactions,
              onDateSelected: (newDate) {
                selected = newDate;
              },
            ),
          ),
        ),
      );

      // Verify weekdays headers exist
      expect(find.text('Sen'), findsOneWidget);
      expect(find.text('Min'), findsOneWidget);

      // Verify day 11 is rendered
      expect(find.text('11'), findsOneWidget);

      // Tap on day 15
      await tester.tap(find.text('15'));
      await tester.pump();

      expect(selected.day, 15);
    });
  });

  group('DailyBreakdownSection Widget Tests', () {
    testWidgets('renders daily income, expense, and net amounts', (
      tester,
    ) async {
      final date = DateTime(2026, 10, 11);
      final transactions = [
        TransactionEntity(
          id: '1',
          title: 'Freelance Design',
          amount: 750000,
          type: TransactionType.income,
          categoryId: 'cat_income',
          date: date,
        ),
        TransactionEntity(
          id: '2',
          title: 'Kopi Kenangan',
          amount: 30000,
          type: TransactionType.expense,
          categoryId: 'cat_food',
          date: date,
        ),
      ];

      final category = CategoryEntity(
        id: 'cat_food',
        name: 'Makan & Minum',
        iconName: 'restaurant',
        colorValue: 0xFFEF4444,
        type: TransactionType.expense,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DailyBreakdownSection(
                selectedDate: date,
                transactions: transactions,
                categories: [category],
                isPrivacyMode: false,
                onDeleteTransaction: (_) {},
                onAddTransaction: () {},
              ),
            ),
          ),
        ),
      );

      // Verify titles and totals
      expect(find.text('Freelance Design'), findsOneWidget);
      expect(find.text('Kopi Kenangan'), findsOneWidget);
      expect(find.text('2 Transaksi Tercatat'), findsOneWidget);
    });
  });
}
