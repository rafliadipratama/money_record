import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class SaveTransaction {
  final TransactionRepository repository;

  SaveTransaction(this.repository);

  Future<void> call(TransactionEntity transaction) async {
    if (transaction.amount <= 0) {
      throw ArgumentError('Nominal transaksi harus lebih dari 0');
    }
    if (transaction.title.trim().isEmpty) {
      throw ArgumentError('Judul transaksi tidak boleh kosong');
    }
    if (transaction.categoryId.trim().isEmpty) {
      throw ArgumentError('Kategori transaksi harus dipilih');
    }

    return repository.saveTransaction(transaction);
  }
}
