import '../../../categories/domain/entities/category_entity.dart';
import '../../domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.title,
    required super.amount,
    required super.type,
    required super.categoryId,
    required super.date,
    super.note,
    super.tags,
    super.isRecurring,
    super.recurrenceInterval,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: TransactionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TransactionType.expense,
      ),
      categoryId: map['category_id'] as String,
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String?,
      tags: (map['tags'] as String?)?.isNotEmpty == true
          ? (map['tags'] as String).split(',')
          : const [],
      isRecurring: (map['is_recurring'] as int?) == 1,
      recurrenceInterval: map['recurrence_interval'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type.name,
      'category_id': categoryId,
      'date': date.toIso8601String(),
      'note': note,
      'tags': tags.join(','),
      'is_recurring': isRecurring ? 1 : 0,
      'recurrence_interval': recurrenceInterval,
    };
  }

  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      title: entity.title,
      amount: entity.amount,
      type: entity.type,
      categoryId: entity.categoryId,
      date: entity.date,
      note: entity.note,
      tags: entity.tags,
      isRecurring: entity.isRecurring,
      recurrenceInterval: entity.recurrenceInterval,
    );
  }
}
