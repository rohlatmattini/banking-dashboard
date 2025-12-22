// lib/data/repositories/decorators/error_handling_account_repository.dart
import 'package:dio/dio.dart';
import '../../dtos/approval_decision_dto.dart';
import '../../dtos/transaction_dto.dart';
import '../../entities/account_entity.dart';
import '../../entities/transaction_detail_entity.dart';
import '../../entities/transaction_entity.dart';
import '../../enums/account_type_enum.dart';
import '../../repositories/account_repository.dart';

class AppException implements Exception {
  final String message;
  final String code;
  final dynamic data;

  AppException(this.message, {this.code = 'UNKNOWN_ERROR', this.data});

  @override
  String toString() => 'AppException: $message (code: $code)';
}

class NetworkException extends AppException {
  NetworkException(String message, {dynamic data})
      : super(message, code: 'NETWORK_ERROR', data: data);
}

class ValidationException extends AppException {
  ValidationException(String message, {dynamic data})
      : super(message, code: 'VALIDATION_ERROR', data: data);
}

class AuthenticationException extends AppException {
  AuthenticationException(String message, {dynamic data})
      : super(message, code: 'AUTHENTICATION_ERROR', data: data);
}

class BusinessException extends AppException {
  BusinessException(String message, {dynamic data})
      : super(message, code: 'BUSINESS_ERROR', data: data);
}

class ErrorHandlingAccountRepository implements AccountRepository {
  final AccountRepository _repository;

  ErrorHandlingAccountRepository(this._repository);

  Future<T> _handleErrors<T>(Future<T> Function() operation, String operationName) async {
    try {
      return await operation();
    } on DioException catch (e) {
      // معالجة أخطاء Dio
      if (e.response?.statusCode == 401) {
        throw AuthenticationException('Session expired. Please login again.');
      } else if (e.response?.statusCode == 403) {
        throw AuthenticationException('You do not have permission to perform this action.');
      } else if (e.response?.statusCode == 404) {
        throw AppException('Resource not found.', code: 'NOT_FOUND');
      } else if (e.response?.statusCode == 422) {
        throw ValidationException(
          e.response?.data?['message'] ?? 'Validation failed',
          data: e.response?.data,
        );
      } else if (e.response?.statusCode == 500) {
        throw AppException('Server error. Please try again later.', code: 'SERVER_ERROR');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException('Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection. Please check your network settings.');
      } else {
        throw AppException(
          'Operation failed: ${e.message ?? "Unknown error"}',
          code: 'NETWORK_ERROR',
        );
      }
    } on AppException catch (e) {
      rethrow;
    } catch (e) {
      throw AppException(
        '$operationName failed: ${e.toString()}',
        code: 'UNEXPECTED_ERROR',
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getUsersWithAccounts() async {
    return await _handleErrors(
          () => _repository.getUsersWithAccounts(),
      'Fetch users with accounts',
    );
  }

  @override
  Future<AccountEntity> createUserAccount({
    required int userId,
    required AccountTypeEnum type,
    String? dailyLimit,
    String? monthlyLimit,
  }) async {
    return await _handleErrors(
          () => _repository.createUserAccount(
        userId: userId,
        type: type,
        dailyLimit: dailyLimit,
        monthlyLimit: monthlyLimit,
      ),
      'Create user account',
    );
  }

  @override
  Future<AccountEntity?> findByPublicId(String publicId) async {
    return await _handleErrors(
          () => _repository.findByPublicId(publicId),
      'Find account by public ID',
    );
  }

  @override
  Future<AccountEntity> updateStateByPublicId(String publicId, String newState) async {
    final validStates = ['active', 'frozen', 'suspended', 'closed'];
    if (!validStates.contains(newState)) {
      throw ValidationException(
        'Invalid state: $newState. Valid states are: ${validStates.join(", ")}',
      );
    }

    return await _handleErrors(
          () => _repository.updateStateByPublicId(publicId, newState),
      'Update account state',
    );
  }

  @override
  Future<AccountEntity> createGroup(int userId) async {
    return await _handleErrors(
          () => _repository.createGroup(userId),
      'Create group account',
    );
  }

  @override
  Future<Map<String, dynamic>> deposit(DepositData data, String idempotencyKey) async {
    if (data.amount <= 0) {
      throw ValidationException('Deposit amount must be greater than zero.');
    }

    if (data.accountPublicId.isEmpty) {
      throw ValidationException('Account ID is required.');
    }

    return await _handleErrors(
          () => _repository.deposit(data, idempotencyKey),
      'Deposit',
    );
  }

  @override
  Future<Map<String, dynamic>> withdraw(WithdrawData data, String idempotencyKey) async {
    if (data.amount <= 0) {
      throw ValidationException('Withdrawal amount must be greater than zero.');
    }

    if (data.accountPublicId.isEmpty) {
      throw ValidationException('Account ID is required.');
    }

    return await _handleErrors(
          () => _repository.withdraw(data, idempotencyKey),
      'Withdraw',
    );
  }

  @override
  Future<Map<String, dynamic>> transfer(TransferData data, String idempotencyKey) async {
    if (data.amount <= 0) {
      throw ValidationException('Transfer amount must be greater than zero.');
    }

    if (data.sourceAccountPublicId.isEmpty) {
      throw ValidationException('Source account ID is required.');
    }

    if (data.destinationAccountPublicId.isEmpty) {
      throw ValidationException('Destination account ID is required.');
    }

    if (data.sourceAccountPublicId == data.destinationAccountPublicId) {
      throw BusinessException('Cannot transfer to the same account.');
    }

    return await _handleErrors(
          () => _repository.transfer(data, idempotencyKey),
      'Transfer',
    );
  }

  @override
  Future<List<TransactionEntity>> getTransactions({String? scope}) async {
    return await _handleErrors(
          () => _repository.getTransactions(scope: scope),
      'Get transactions',
    );
  }

  @override
  Future<TransactionDetailEntity> getTransactionDetail(
      String transactionId, {
        String? scope,
      }) async {
    if (transactionId.isEmpty) {
      throw ValidationException('Transaction ID is required.');
    }

    return await _handleErrors(
          () => _repository.getTransactionDetail(transactionId, scope: scope),
      'Get transaction detail',
    );
  }

  @override
  Future<List<TransactionEntity>> getPendingApprovals() async {
    return await _handleErrors(
          () => _repository.getPendingApprovals(),
      'Get pending approvals',
    );
  }

  @override
  Future<Map<String, dynamic>> submitApprovalDecision(
      String transactionId,
      ApprovalDecisionData decision,
      ) async {
    if (transactionId.isEmpty) {
      throw ValidationException('Transaction ID is required.');
    }

    final validDecisions = ['approve', 'reject'];
    if (!validDecisions.contains(decision.decision)) {
      throw ValidationException(
        'Invalid decision: ${decision.decision}. Valid decisions are: ${validDecisions.join(", ")}',
      );
    }

    return await _handleErrors(
          () => _repository.submitApprovalDecision(transactionId, decision),
      'Submit approval decision',
    );
  }
}
