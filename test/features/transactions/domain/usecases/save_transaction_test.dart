import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:money_record/features/categories/domain/entities/category_entity.dart';
import 'package:money_record/features/transactions/domain/entities/transaction_entity.dart';
import 'package:money_record/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:money_record/features/transactions/domain/usecases/save_transaction.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

class FakeTransactionEntity extends Fake implements TransactionEntity {}

void main() {
  late SaveTransaction useCase;
  late MockTransactionRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeTransactionEntity());
  });

  setUp(() {
    mockRepository = MockTransactionRepository();
    useCase = SaveTransaction(mockRepository);
  });

  final validTx = TransactionEntity(
    id: 'tx_123',
    title: 'Makan Siang',
    amount: 35000,
    type: TransactionType.expense,
    categoryId: 'cat_food',
    date: DateTime(2026, 10, 11),
  );

  test('successfully calls repository.saveTransaction for valid input', () async {
    when(() => mockRepository.saveTransaction(any()))
        .thenAnswer((_) async {});

    await useCase(validTx);

    verify(() => mockRepository.saveTransaction(validTx)).called(1);
  });

  test('throws ArgumentError when amount is zero or negative', () async {
    final invalidTx = validTx.copyWith(amount: 0);

    expect(() => useCase(invalidTx), throwsArgumentError);
    verifyNever(() => mockRepository.saveTransaction(any()));
  });

  test('throws ArgumentError when title is empty or blank', () async {
    final invalidTx = validTx.copyWith(title: '   ');

    expect(() => useCase(invalidTx), throwsArgumentError);
    verifyNever(() => mockRepository.saveTransaction(any()));
  });

  test('throws ArgumentError when categoryId is empty', () async {
    final invalidTx = validTx.copyWith(categoryId: '');

    expect(() => useCase(invalidTx), throwsArgumentError);
    verifyNever(() => mockRepository.saveTransaction(any()));
  });
}
