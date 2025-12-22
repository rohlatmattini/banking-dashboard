// lib/domain/patterns/strategy/transaction_strategy_factory.dart
import '../../entities/transaction_entity.dart';
import 'transaction_strategy.dart';
import 'deposit_strategy.dart';
import 'withdraw_strategy.dart';
import 'transfer_strategy.dart';
import '../../dtos/transaction_dto.dart';
import '../../repositories/account_repository.dart';
import '../../entities/account_entity.dart';

class TransactionStrategyFactory {
  final AccountRepository _repository;

  TransactionStrategyFactory(this._repository);

  Future<TransactionStrategy> createStrategy({
    required TransactionType type,
    required dynamic data,
    String? sourceAccountId,
    String? destinationAccountId,
  }) async {
    AccountEntity? sourceAccount;
    AccountEntity? destinationAccount;

    if (sourceAccountId != null) {
      sourceAccount = await _repository.findByPublicId(sourceAccountId);
    }

    if (destinationAccountId != null) {
      destinationAccount = await _repository.findByPublicId(destinationAccountId);
    }

    switch (type) {
      case TransactionType.DEPOSIT:
        return DepositStrategy(data as DepositData, _repository);

      case TransactionType.WITHDRAW:
        return WithdrawStrategy(
          data as WithdrawData,
          _repository,
          account: sourceAccount,
        );

      case TransactionType.TRANSFER:
        return TransferStrategy(
          data as TransferData,
          _repository,
          sourceAccount: sourceAccount,
          destinationAccount: destinationAccount,
        );

      default:
        throw ArgumentError('Unknown transaction type: $type');
    }
  }
}