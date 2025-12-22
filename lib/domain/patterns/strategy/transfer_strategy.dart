import '../../dtos/transaction_dto.dart';
import '../../entities/transaction_entity.dart';
import '../../enums/account_type_enum.dart';
import '../../repositories/account_repository.dart';
import '../decorators/error_handling_account_repository.dart';
import 'transaction_strategy.dart';
import '../../entities/account_entity.dart';

class TransferStrategy implements TransactionStrategy {
  final TransferData _data;
  final AccountRepository _repository;
  final AccountEntity? _sourceAccount;
  final AccountEntity? _destinationAccount;

  @override
  AccountRepository get repository => _repository;

  @override
  TransactionType get type => TransactionType.TRANSFER;

  TransferStrategy(
      this._data,
      AccountRepository repository, {
        AccountEntity? sourceAccount,
        AccountEntity? destinationAccount,
      }) : _repository = repository,
        _sourceAccount = sourceAccount,
        _destinationAccount = destinationAccount;

  @override
  Map<String, dynamic> validate(Map<String, dynamic> context) {
    final errors = <String, String>{};

    if (_data.amount <= 0) {
      errors['amount'] = 'Amount must be greater than zero';
    }

    if (_data.sourceAccountPublicId.isEmpty) {
      errors['source_account'] = 'Source account ID is required';
    }

    if (_data.destinationAccountPublicId.isEmpty) {
      errors['destination_account'] = 'Destination account ID is required';
    }

    if (_data.sourceAccountPublicId == _data.destinationAccountPublicId) {
      errors['general'] = 'Cannot transfer to the same account';
    }

    if (_sourceAccount != null) {
      if (!_sourceAccount!.canTransfer()) {
        errors['source_account'] = 'Source account is not in a transferable state';
      }

      if (_data.amount > _sourceAccount!.balance) {
        errors['amount'] = 'Insufficient balance in source account';
      }

      // حساب رسوم التحويل
      final fee = _calculateTransferFee();
      final totalAmount = _data.amount + fee;

      if (totalAmount > _sourceAccount!.balance) {
        errors['amount'] = 'Insufficient balance including transfer fee of \$${fee.toStringAsFixed(2)}';
      }
    }

    if (_destinationAccount != null) {
      if (!_destinationAccount!.canDeposit()) {
        errors['destination_account'] = 'Destination account cannot receive transfers';
      }
    }

    final maxDailyTransfer = 50000.0;
    if (_data.amount > maxDailyTransfer) {
      errors['amount'] = 'Amount exceeds maximum daily transfer limit of \$${maxDailyTransfer.toStringAsFixed(2)}';
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
        'Transfer validation failed',
        data: validationErrors,
      );
    }

    // حساب رسوم التحويل وإضافتها للبيانات إذا لزم الأمر
    final fee = _calculateTransferFee();
    final enhancedData = TransferData(
      sourceAccountPublicId: _data.sourceAccountPublicId,
      destinationAccountPublicId: _data.destinationAccountPublicId,
      amount: _data.amount,
      description: '${_data.description} (Fee: \$${fee.toStringAsFixed(2)})',
    );

    final result = await _repository.transfer(enhancedData, idempotencyKey);

    return result;
  }

  @override
  Future<void> postProcess(Map<String, dynamic> result, Map<String, dynamic> context) async {
    print('Transfer post-processing completed');
    print('From: ${_data.sourceAccountPublicId}');
    print('To: ${_data.destinationAccountPublicId}');
    print('Amount: \$${_data.amount}');

    final fee = _calculateTransferFee();
    if (fee > 0) {
      print('Transfer fee applied: \$${fee.toStringAsFixed(2)}');
    }
  }

  double _calculateTransferFee() {
    if (_sourceAccount == null) return 0.0;

    switch (_sourceAccount!.type) {
      case AccountTypeEnum.SAVINGS:
      // لا رسوم لحسابات التوفير
        return 0.0;
      case AccountTypeEnum.CHECKING:
      // 1% رسوم لحسابات الجارية
        return _data.amount * 0.01;
      case AccountTypeEnum.LOAN:
      // 2% رسوم لحسابات القروض
        return _data.amount * 0.02;
      case AccountTypeEnum.INVESTMENT:
      // 0.5% رسوم لحسابات الاستثمار
        return _data.amount * 0.005;
      case AccountTypeEnum.GROUP:
      // لا رسوم لحسابات المجموعة
        return 0.0;
      default:
        return _data.amount * 0.015; // 1.5% رسوم افتراضية
    }
  }
}