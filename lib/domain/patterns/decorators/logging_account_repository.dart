import '../../../presentation/helpers/logger.dart';
import '../../dtos/approval_decision_dto.dart';
import '../../dtos/transaction_dto.dart';
import '../../entities/account_entity.dart';
import '../../entities/transaction_detail_entity.dart';
import '../../entities/transaction_entity.dart';
import '../../enums/account_type_enum.dart';
import '../../repositories/account_repository.dart';
import 'package:flutter/material.dart';

class LoggingAccountRepository implements AccountRepository {
  final AccountRepository _repository;
  final Logger _logger;

  LoggingAccountRepository(this._repository, [Logger? logger])
      : _logger = logger ?? Logger();

  @override
  Future<List<Map<String, dynamic>>> getUsersWithAccounts() async {
    _logger.log('AccountRepository.getUsersWithAccounts - Start');
    final startTime = DateTime.now();

    try {
      final result = await _repository.getUsersWithAccounts();
      final duration = DateTime.now().difference(startTime);

      _logger.log('AccountRepository.getUsersWithAccounts - Success');
      _logger.log('Fetched ${result.length} users with accounts');
      _logger.log('Operation took ${duration.inMilliseconds}ms');

      return result;
    } catch (e) {
      _logger.error('AccountRepository.getUsersWithAccounts - Error: $e');
      rethrow;
    }
  }

  @override
  Future<AccountEntity> createUserAccount({
    required int userId,
    required AccountTypeEnum type,
    String? dailyLimit,
    String? monthlyLimit,
  }) async {
    _logger.log('AccountRepository.createUserAccount - Start');
    _logger.log('User ID: $userId, Type: $type');

    final startTime = DateTime.now();

    try {
      final result = await _repository.createUserAccount(
        userId: userId,
        type: type,
        dailyLimit: dailyLimit,
        monthlyLimit: monthlyLimit,
      );

      final duration = DateTime.now().difference(startTime);

      _logger.log('AccountRepository.createUserAccount - Success');
      _logger.log('Created account: ${result.publicId}');
      _logger.log('Operation took ${duration.inMilliseconds}ms');

      return result;
    } catch (e) {
      _logger.error('AccountRepository.createUserAccount - Error: $e');
      rethrow;
    }
  }

  @override
  Future<AccountEntity?> findByPublicId(String publicId) async {
    _logger.log('AccountRepository.findByPublicId - Start: $publicId');
    final startTime = DateTime.now();

    try {
      final result = await _repository.findByPublicId(publicId);
      final duration = DateTime.now().difference(startTime);

      _logger.log('AccountRepository.findByPublicId - ${result != null ? 'Found' : 'Not Found'}');
      _logger.log('Operation took ${duration.inMilliseconds}ms');

      return result;
    } catch (e) {
      _logger.error('AccountRepository.findByPublicId - Error: $e');
      rethrow;
    }
  }

  @override
  Future<AccountEntity> updateStateByPublicId(String publicId, String newState) async {
    _logger.log('AccountRepository.updateStateByPublicId - Start');
    _logger.log('Account: $publicId, New State: $newState');

    final startTime = DateTime.now();

    try {
      final result = await _repository.updateStateByPublicId(publicId, newState);
      final duration = DateTime.now().difference(startTime);

      _logger.log('AccountRepository.updateStateByPublicId - Success');
      _logger.log('Account ${result.publicId} state updated to ${result.state.name}');
      _logger.log('Operation took ${duration.inMilliseconds}ms');

      return result;
    } catch (e) {
      _logger.error('AccountRepository.updateStateByPublicId - Error: $e');
      rethrow;
    }
  }

  @override
  Future<AccountEntity> createGroup(int userId) async {
    _logger.log('AccountRepository.createGroup - Start for user: $userId');
    final startTime = DateTime.now();

    try {
      final result = await _repository.createGroup(userId);
      final duration = DateTime.now().difference(startTime);

      _logger.log('AccountRepository.createGroup - Success');
      _logger.log('Created group account: ${result.publicId}');
      _logger.log('Operation took ${duration.inMilliseconds}ms');

      return result;
    } catch (e) {
      _logger.error('AccountRepository.createGroup - Error: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> deposit(DepositData data, String idempotencyKey) async {
    _logger.log('AccountRepository.deposit - Start');
    _logger.log('Account: ${data.accountPublicId}, Amount: \$${data.amount}');
    _logger.log('Idempotency Key: $idempotencyKey');

    final startTime = DateTime.now();

    try {
      final result = await _repository.deposit(data, idempotencyKey);
      final duration = DateTime.now().difference(startTime);

      _logger.log('AccountRepository.deposit - Success');
      _logger.log('Operation took ${duration.inMilliseconds}ms');

      return result;
    } catch (e) {
      _logger.error('AccountRepository.deposit - Error: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> withdraw(WithdrawData data, String idempotencyKey) async {
    _logger.log('AccountRepository.withdraw - Start');
    _logger.log('Account: ${data.accountPublicId}, Amount: \$${data.amount}');
    _logger.log('Idempotency Key: $idempotencyKey');

    final startTime = DateTime.now();

    try {
      final result = await _repository.withdraw(data, idempotencyKey);
      final duration = DateTime.now().difference(startTime);

      _logger.log('AccountRepository.withdraw - Success');
      _logger.log('Operation took ${duration.inMilliseconds}ms');

      return result;
    } catch (e) {
      _logger.error('AccountRepository.withdraw - Error: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> transfer(TransferData data, String idempotencyKey) async {
    _logger.log('AccountRepository.transfer - Start');
    _logger.log('From: ${data.sourceAccountPublicId}');
    _logger.log('To: ${data.destinationAccountPublicId}');
    _logger.log('Amount: \$${data.amount}');
    _logger.log('Idempotency Key: $idempotencyKey');

    final startTime = DateTime.now();

    try {
      final result = await _repository.transfer(data, idempotencyKey);
      final duration = DateTime.now().difference(startTime);

      _logger.log('AccountRepository.transfer - Success');
      _logger.log('Operation took ${duration.inMilliseconds}ms');

      return result;
    } catch (e) {
      _logger.error('AccountRepository.transfer - Error: $e');
      rethrow;
    }
  }

  @override
  Future<List<TransactionEntity>> getTransactions({String? scope}) async {
    _logger.log('AccountRepository.getTransactions - Start');
    _logger.log('Scope: ${scope ?? "all"}');

    final startTime = DateTime.now();

    try {
      final result = await _repository.getTransactions(scope: scope);
      final duration = DateTime.now().difference(startTime);

      _logger.log('AccountRepository.getTransactions - Success');
      _logger.log('Fetched ${result.length} transactions');
      _logger.log('Operation took ${duration.inMilliseconds}ms');

      return result;
    } catch (e) {
      _logger.error('AccountRepository.getTransactions - Error: $e');
      rethrow;
    }
  }

  @override
  Future<TransactionDetailEntity> getTransactionDetail(String transactionId, {String? scope}) async {
    _logger.log('AccountRepository.getTransactionDetail - Start');
    _logger.log('Transaction ID: $transactionId');
    _logger.log('Scope: ${scope ?? "all"}');

    final startTime = DateTime.now();

    try {
      final result = await _repository.getTransactionDetail(transactionId, scope: scope);
      final duration = DateTime.now().difference(startTime);

      _logger.log('AccountRepository.getTransactionDetail - Success');
      _logger.log('Operation took ${duration.inMilliseconds}ms');

      return result;
    } catch (e) {
      _logger.error('AccountRepository.getTransactionDetail - Error: $e');
      rethrow;
    }
  }

  @override
  Future<List<TransactionEntity>> getPendingApprovals() async {
    _logger.log('AccountRepository.getPendingApprovals - Start');
    final startTime = DateTime.now();

    try {
      final result = await _repository.getPendingApprovals();
      final duration = DateTime.now().difference(startTime);

      _logger.log('AccountRepository.getPendingApprovals - Success');
      _logger.log('Found ${result.length} pending approvals');
      _logger.log('Operation took ${duration.inMilliseconds}ms');

      return result;
    } catch (e) {
      _logger.error('AccountRepository.getPendingApprovals - Error: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> submitApprovalDecision(
      String transactionId,
      ApprovalDecisionData decision,
      ) async {
    _logger.log('AccountRepository.submitApprovalDecision - Start');
    _logger.log('Transaction ID: $transactionId');
    _logger.log('Decision: ${decision.decision}');
    if (decision.note != null) {
      _logger.log('Note: ${decision.note}');
    }

    final startTime = DateTime.now();

    try {
      final result = await _repository.submitApprovalDecision(transactionId, decision);
      final duration = DateTime.now().difference(startTime);

      _logger.log('AccountRepository.submitApprovalDecision - Success');
      _logger.log('Operation took ${duration.inMilliseconds}ms');

      return result;
    } catch (e) {
      _logger.error('AccountRepository.submitApprovalDecision - Error: $e');
      rethrow;
    }
  }
}
