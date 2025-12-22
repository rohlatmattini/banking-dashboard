// lib/domain/patterns/strategy/transaction_strategy.dart
import '../../entities/account_entity.dart';
import '../../entities/transaction_entity.dart';
import '../../dtos/transaction_dto.dart';
import '../../repositories/account_repository.dart';

abstract class TransactionStrategy {
  AccountRepository get repository;

  Future<Map<String, dynamic>> execute({
    required String idempotencyKey,
    Map<String, dynamic>? context,
  });

  Map<String, dynamic> validate(Map<String, dynamic> context);

  Future<void> postProcess(Map<String, dynamic> result, Map<String, dynamic> context);

  TransactionType get type;
}