import 'package:equatable/equatable.dart';

import '../../domain/entities/transaction_entity.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransactionsEvent extends TransactionEvent {
  final DateTime month;

  const LoadTransactionsEvent(this.month);

  @override
  List<Object?> get props => [month];
}

class AddTransactionEvent extends TransactionEvent {
  final TransactionEntity transaction;

  const AddTransactionEvent(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class DeleteTransactionEvent extends TransactionEvent {
  final String id;

  const DeleteTransactionEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class ChangeMonthEvent extends TransactionEvent {
  final DateTime month;

  const ChangeMonthEvent(this.month);

  @override
  List<Object?> get props => [month];
}

class TogglePrivacyModeEvent extends TransactionEvent {
  const TogglePrivacyModeEvent();
}
