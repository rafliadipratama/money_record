import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class GetTransactionsByMonth {
  final TransactionRepository repository;

  GetTransactionsByMonth(this.repository);

  Stream<List<TransactionEntity>> call(DateTime month) {
    return repository.watchTransactionsByMonth(month);
  }
}
