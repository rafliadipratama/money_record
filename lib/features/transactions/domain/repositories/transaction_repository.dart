import '../entities/transaction_entity.dart';
import '../entities/monthly_summary.dart';

abstract class TransactionRepository {
  Stream<List<TransactionEntity>> watchTransactionsByMonth(DateTime month);
  Future<List<TransactionEntity>> getTransactionsByMonth(DateTime month);
  Future<MonthlySummary> getMonthlySummary(DateTime month);
  Future<void> saveTransaction(TransactionEntity transaction);
  Future<void> deleteTransaction(String id);
  Future<String> exportTransactionsCsv(DateTime start, DateTime end);
}
