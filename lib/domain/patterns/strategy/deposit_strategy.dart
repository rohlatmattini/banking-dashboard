// lib/domain/patterns/strategy/deposit_strategy.dart
import '../../dtos/transaction_dto.dart';
import '../../entities/transaction_entity.dart';
import '../../repositories/account_repository.dart';
import '../decorators/error_handling_account_repository.dart';
import 'transaction_strategy.dart';

class DepositStrategy implements TransactionStrategy {
  final DepositData _data;
  final AccountRepository _repository;

  @override
  AccountRepository get repository => _repository;

  @override
  TransactionType get type => TransactionType.DEPOSIT;

  DepositStrategy(this._data, AccountRepository repository)
      : _repository = repository;

  @override
  Map<String, dynamic> validate(Map<String, dynamic> context) {
    final errors = <String, String>{};

    if (_data.amount <= 0) {
      errors['amount'] = 'Amount must be greater than zero';
    }

    if (_data.accountPublicId.isEmpty) {
      errors['account'] = 'Account ID is required';
    }

    final maxDeposit = 1000000.0;
    if (_data.amount > maxDeposit) {
      errors['amount'] = 'Amount exceeds maximum deposit limit of \$${maxDeposit.toStringAsFixed(2)}';
    }

    return errors;
  }

  @override
  Future<Map<String, dynamic>> execute({
    required String idempotencyKey,
    Map<String, dynamic>? context,
  }) async {
    final validationErrors = validate(context ?? {});
    if (validationErrors.isNotEmpty) {
      throw ValidationException(
        'Deposit validation failed',
        data: validationErrors,
      );
    }

    final result = await _repository.deposit(_data, idempotencyKey);

    return result;
  }

  @override
  Future<void> postProcess(Map<String, dynamic> result, Map<String, dynamic> context) async {
    print('Deposit post-processing completed for account: ${_data.accountPublicId}');
  }
}