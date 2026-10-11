import '../repositories/transaction_repository.dart';

class DeleteTransaction {
  final TransactionRepository repository;

  DeleteTransaction(this.repository);

  Future<void> call(String id) {
    if (id.trim().isEmpty) {
      throw ArgumentError('Transaction ID cannot be empty');
    }
    return repository.deleteTransaction(id);
  }
}
