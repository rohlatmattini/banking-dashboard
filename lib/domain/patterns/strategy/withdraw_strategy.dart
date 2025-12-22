import '../../dtos/transaction_dto.dart';
import '../../entities/transaction_entity.dart';
import '../../repositories/account_repository.dart';
import '../decorators/error_handling_account_repository.dart';
import 'transaction_strategy.dart';
import '../../entities/account_entity.dart';

class WithdrawStrategy implements TransactionStrategy {
  final WithdrawData _data;
  final AccountRepository _repository;
  final AccountEntity? _account;

  @override
  AccountRepository get repository => _repository;

  @override
  TransactionType get type => TransactionType.WITHDRAW;

  WithdrawStrategy(
      this._data,
      AccountRepository repository, {
        AccountEntity? account,
      }) : _repository = repository,
        _account = account;

  @override
  Map<String, dynamic> validate(Map<String, dynamic> context) {
    final errors = <String, String>{};

    if (_data.amount <= 0) {
      errors['amount'] = 'Amount must be greater than zero';
    }

    if (_data.accountPublicId.isEmpty) {
      errors['account'] = 'Account ID is required';
    }

    if (_account != null) {
      if (!_account!.canWithdraw()) {
        errors['account'] = 'Account is not in a withdrawable state';
      }

      if (_data.amount > _account!.balance) {
        errors['amount'] = 'Insufficient balance';
      }

      final dailyLimit = _getDailyLimit();
      if (dailyLimit != null && _data.amount > dailyLimit) {
        errors['amount'] = 'Amount exceeds daily withdrawal limit of \$${dailyLimit.toStringAsFixed(2)}';
      }
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
        'Withdrawal validation failed',
        data: validationErrors,
      );
    }

    final result = await _repository.withdraw(_data, idempotencyKey);

    return result;
  }

  @override
  Future<void> postProcess(Map<String, dynamic> result, Map<String, dynamic> context) async {
    print('Withdrawal post-processing completed for account: ${_data.accountPublicId}');

    if (_data.amount > 10000) {
      print('Large withdrawal alert: \$${_data.amount} from account ${_data.accountPublicId}');
    }
  }

  double? _getDailyLimit() {
    if (_account?.dailyLimit != null) {
      return double.tryParse(_account!.dailyLimit!);
    }
    return null;
  }
}