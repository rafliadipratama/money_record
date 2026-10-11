import '../entities/monthly_summary.dart';
import '../repositories/transaction_repository.dart';

class GetMonthlySummary {
  final TransactionRepository repository;

  GetMonthlySummary(this.repository);

  Future<MonthlySummary> call(DateTime month) {
    return repository.getMonthlySummary(month);
  }
}
