import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_record/core/utils/currency_formatter.dart';
import 'package:money_record/features/categories/domain/entities/category_entity.dart';
import 'package:money_record/features/transactions/domain/entities/monthly_summary.dart';
import 'package:money_record/features/transactions/domain/entities/transaction_entity.dart';
import 'package:money_record/features/transactions/presentation/widgets/balance_hero_card.dart';
import 'package:money_record/features/transactions/presentation/widgets/transaction_tile.dart';

void main() {
  group('Widget Tests', () {
    testWidgets(
      'BalanceHeroCard renders net savings and triggers privacy toggle',
      (tester) async {
        bool toggled = false;
        final summary = MonthlySummary(
          month: DateTime(2026, 10, 1),
          totalIncome: 10000000,
          totalExpense: 4000000,
          netSavings: 6000000,
          savingsRate: 60,
          dailyExpenses: const {1: 4000000},
          dailyIncomes: const {1: 10000000},
          categoryBreakdown: const {'cat_food': 4000000},
          transactionCount: 2,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BalanceHeroCard(
                summary: summary,
                isPrivacyMode: false,
                onTogglePrivacy: () {
                  toggled = true;
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify net savings display
        expect(find.text(CurrencyFormatter.format(6000000)), findsOneWidget);
        expect(find.text('Saldo Bersih Bulan Ini'), findsOneWidget);

        // Tap privacy icon
        await tester.tap(find.byType(IconButton));
        await tester.pumpAndSettle();

        expect(toggled, isTrue);
      },
    );

    testWidgets(
      'TransactionTile displays title, category, and formatted amount',
      (tester) async {
        final tx = TransactionEntity(
          id: 'tx_1',
          title: 'Kopi Kenangan',
          amount: 25000,
          type: TransactionType.expense,
          categoryId: 'cat_food',
          date: DateTime(2026, 10, 11),
        );

        const category = CategoryEntity(
          id: 'cat_food',
          name: 'Makanan & Minuman',
          iconName: 'restaurant',
          colorValue: 0xFFF59E0B,
          type: TransactionType.expense,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TransactionTile(
                transaction: tx,
                category: category,
                isPrivacyMode: false,
                onDelete: () {},
              ),
            ),
          ),
        );

        expect(find.text('Kopi Kenangan'), findsOneWidget);
        expect(find.text('Makanan & Minuman'), findsOneWidget);
        expect(find.text('- Rp 25.000'), findsOneWidget);
      },
    );
  });
}
