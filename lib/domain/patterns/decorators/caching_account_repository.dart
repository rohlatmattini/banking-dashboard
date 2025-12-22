import 'dart:collection';

import '../../dtos/approval_decision_dto.dart';
import '../../dtos/transaction_dto.dart';
import '../../entities/account_entity.dart';
import '../../entities/transaction_detail_entity.dart';
import '../../entities/transaction_entity.dart';
import '../../enums/account_type_enum.dart';
import '../../repositories/account_repository.dart';

class CachingAccountRepository implements AccountRepository {
  final AccountRepository _repository;
  final Duration _cacheDuration;

  final Map<String, AccountEntity> _accountCache = {};
  final Map<String, List<TransactionEntity>> _transactionsCache = {};
  final Map<String, TransactionDetailEntity> _transactionDetailCache = {};
  final Map<String, List<TransactionEntity>> _pendingApprovalsCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};

  CachingAccountRepository(
      this._repository, {
        Duration cacheDuration = const Duration(minutes: 5),
      }) : _cacheDuration = cacheDuration;

  void _cleanExpiredCache() {
    final now = DateTime.now();
    _cacheTimestamps.removeWhere((key, timestamp) {
      if (now.difference(timestamp) > _cacheDuration) {
        _accountCache.remove(key);
        _transactionsCache.remove(key);
        _transactionDetailCache.remove(key);
        _pendingApprovalsCache.remove(key);
        return true;
      }
      return false;
    });
  }

  bool _isCacheValid(String key) {
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return false;

    return DateTime.now().difference(timestamp) <= _cacheDuration;
  }

  void _updateCacheTimestamp(String key) {
    _cacheTimestamps[key] = DateTime.now();
  }

  void invalidateCache({String? key}) {
    if (key != null) {
      _accountCache.remove(key);
      _transactionsCache.remove(key);
      _transactionDetailCache.remove(key);
      _pendingApprovalsCache.remove(key);
      _cacheTimestamps.remove(key);
    } else {
      _accountCache.clear();
      _transactionsCache.clear();
      _transactionDetailCache.clear();
      _pendingApprovalsCache.clear();
      _cacheTimestamps.clear();
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getUsersWithAccounts() async {
    return await _repository.getUsersWithAccounts();
  }

  @override
  Future<AccountEntity?> findByPublicId(String publicId) async {
    _cleanExpiredCache();

    final cacheKey = 'account_$publicId';

    if (_isCacheValid(cacheKey) && _accountCache.containsKey(cacheKey)) {
      return _accountCache[cacheKey];
    }

    final account = await _repository.findByPublicId(publicId);

    if (account != null) {
      _accountCache[cacheKey] = account;
      _updateCacheTimestamp(cacheKey);
    }

    return account;
  }

  @override
  Future<List<TransactionEntity>> getTransactions({String? scope}) async {
    _cleanExpiredCache();

    final cacheKey = 'transactions_${scope ?? 'all'}';

    if (_isCacheValid(cacheKey) && _transactionsCache.containsKey(cacheKey)) {
      return List.from(_transactionsCache[cacheKey]!);
    }

    final transactions = await _repository.getTransactions(scope: scope);

    _transactionsCache[cacheKey] = List.from(transactions);
    _updateCacheTimestamp(cacheKey);

    return transactions;
  }

  @override
  Future<TransactionDetailEntity> getTransactionDetail(
      String transactionId, {
        String? scope,
      }) async {
    _cleanExpiredCache();

    final cacheKey = 'transaction_detail_${transactionId}_${scope ?? 'all'}';

    if (_isCacheValid(cacheKey) && _transactionDetailCache.containsKey(cacheKey)) {
      return _transactionDetailCache[cacheKey]!;
    }

    final detail = await _repository.getTransactionDetail(transactionId, scope: scope);

    _transactionDetailCache[cacheKey] = detail;
    _updateCacheTimestamp(cacheKey);

    return detail;
  }

  @override
  Future<List<TransactionEntity>> getPendingApprovals() async {
    _cleanExpiredCache();

    final cacheKey = 'pending_approvals';

    if (_isCacheValid(cacheKey) && _pendingApprovalsCache.containsKey(cacheKey)) {
      return List.from(_pendingApprovalsCache[cacheKey]!);
    }

    final approvals = await _repository.getPendingApprovals();

    _pendingApprovalsCache[cacheKey] = List.from(approvals);
    _updateCacheTimestamp(cacheKey);

    return approvals;
  }

  @override
  Future<AccountEntity> createUserAccount({
    required int userId,
    required AccountTypeEnum type,
    String? dailyLimit,
    String? monthlyLimit,
  }) async {
    final account = await _repository.createUserAccount(
      userId: userId,
      type: type,
      dailyLimit: dailyLimit,
      monthlyLimit: monthlyLimit,
    );

    invalidateCache();

    return account;
  }

  @override
  Future<AccountEntity> updateStateByPublicId(String publicId, String newState) async {
    final account = await _repository.updateStateByPublicId(publicId, newState);

    invalidateCache(key: 'account_$publicId');
    invalidateCache();

    return account;
  }

  @override
  Future<Map<String, dynamic>> deposit(DepositData data, String idempotencyKey) async {
    final result = await _repository.deposit(data, idempotencyKey);

    invalidateCache(key: 'account_${data.accountPublicId}');

    return result;
  }

  @override
  Future<Map<String, dynamic>> withdraw(WithdrawData data, String idempotencyKey) async {
    final result = await _repository.withdraw(data, idempotencyKey);

    invalidateCache(key: 'account_${data.accountPublicId}');

    return result;
  }

  @override
  Future<Map<String, dynamic>> transfer(TransferData data, String idempotencyKey) async {
    final result = await _repository.transfer(data, idempotencyKey);

    invalidateCache(key: 'account_${data.sourceAccountPublicId}');
    invalidateCache(key: 'account_${data.destinationAccountPublicId}');

    return result;
  }

  @override
  Future<Map<String, dynamic>> submitApprovalDecision(
      String transactionId,
      ApprovalDecisionData decision,
      ) async {
    final result = await _repository.submitApprovalDecision(transactionId, decision);

    invalidateCache(key: 'pending_approvals');

    return result;
  }

  @override
  Future<AccountEntity> createGroup(int userId) async {
    final account = await _repository.createGroup(userId);

    invalidateCache();

    return account;
  }
}