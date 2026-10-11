import 'dart:async';

import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database_helper.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/monthly_summary.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../models/transaction_model.dart';
import '../../../categories/domain/entities/category_entity.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final _changeStreamController = StreamController<void>.broadcast();

  void _notifyChanges() {
    _changeStreamController.add(null);
  }

  @override
  Stream<List<TransactionEntity>> watchTransactionsByMonth(
    DateTime month,
  ) async* {
    yield await getTransactionsByMonth(month);
    await for (final _ in _changeStreamController.stream) {
      yield await getTransactionsByMonth(month);
    }
  }

  @override
  Future<List<TransactionEntity>> getTransactionsByMonth(DateTime month) async {
    final db = await DatabaseHelper.database;
    final start = AppDateUtils.startOfMonth(month).toIso8601String();
    final end = AppDateUtils.endOfMonth(month).toIso8601String();

    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'date >= ? AND date <= ?',
      whereArgs: [start, end],
      orderBy: 'date DESC',
    );

    return maps.map((e) => TransactionModel.fromMap(e)).toList();
  }

  @override
  Future<MonthlySummary> getMonthlySummary(DateTime month) async {
    final transactions = await getTransactionsByMonth(month);

    double totalIncome = 0;
    double totalExpense = 0;
    final Map<int, double> dailyExpenses = {};
    final Map<int, double> dailyIncomes = {};
    final Map<String, double> categoryBreakdown = {};

    for (final tx in transactions) {
      final day = tx.date.day;

      if (tx.type == TransactionType.income) {
        totalIncome += tx.amount;
        dailyIncomes[day] = (dailyIncomes[day] ?? 0.0) + tx.amount;
      } else if (tx.type == TransactionType.expense) {
        totalExpense += tx.amount;
        dailyExpenses[day] = (dailyExpenses[day] ?? 0.0) + tx.amount;
        categoryBreakdown[tx.categoryId] =
            (categoryBreakdown[tx.categoryId] ?? 0.0) + tx.amount;
      }
    }

    final netSavings = totalIncome - totalExpense;
    final savingsRate = totalIncome > 0
        ? (netSavings / totalIncome) * 100
        : 0.0;

    return MonthlySummary(
      month: month,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      netSavings: netSavings,
      savingsRate: savingsRate,
      dailyExpenses: dailyExpenses,
      dailyIncomes: dailyIncomes,
      categoryBreakdown: categoryBreakdown,
      transactionCount: transactions.length,
    );
  }

  @override
  Future<void> saveTransaction(TransactionEntity transaction) async {
    final db = await DatabaseHelper.database;
    final model = TransactionModel.fromEntity(transaction);

    await db.insert(
      'transactions',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    _notifyChanges();
  }

  @override
  Future<void> deleteTransaction(String id) async {
    final db = await DatabaseHelper.database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);

    _notifyChanges();
  }

  @override
  Future<String> exportTransactionsCsv(DateTime start, DateTime end) async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'date >= ? AND date <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date ASC',
    );

    final buffer = StringBuffer();
    buffer.writeln('ID,Judul,Tipe,Nominal,KategoriID,Tanggal,Catatan');

    for (final map in maps) {
      final tx = TransactionModel.fromMap(map);
      final cleanTitle = tx.title.replaceAll('"', '""');
      final cleanNote = (tx.note ?? '').replaceAll('"', '""');
      buffer.writeln(
        '${tx.id},"$cleanTitle",${tx.type.name},${tx.amount},${tx.categoryId},${tx.date.toIso8601String()},"$cleanNote"',
      );
    }

    return buffer.toString();
  }
}
