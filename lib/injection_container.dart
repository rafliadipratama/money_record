import 'package:get_it/get_it.dart';
import 'features/categories/data/repositories/category_repository_impl.dart';
import 'features/categories/domain/repositories/category_repository.dart';
import 'features/transactions/data/repositories/transaction_repository_impl.dart';
import 'features/transactions/domain/repositories/transaction_repository.dart';
import 'features/transactions/domain/usecases/delete_transaction.dart';
import 'features/transactions/domain/usecases/get_monthly_summary.dart';
import 'features/transactions/domain/usecases/get_transactions_by_month.dart';
import 'features/transactions/domain/usecases/save_transaction.dart';
import 'features/transactions/presentation/blocs/transaction_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Blocs
  sl.registerFactory(
    () => TransactionBloc(
      transactionRepository: sl(),
      categoryRepository: sl(),
      saveTransactionUseCase: sl(),
      deleteTransactionUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SaveTransaction(sl()));
  sl.registerLazySingleton(() => DeleteTransaction(sl()));
  sl.registerLazySingleton(() => GetTransactionsByMonth(sl()));
  sl.registerLazySingleton(() => GetMonthlySummary(sl()));

  // Repositories
  sl.registerLazySingleton<CategoryRepository>(() => CategoryRepositoryImpl());
  sl.registerLazySingleton<TransactionRepository>(() => TransactionRepositoryImpl());
}
