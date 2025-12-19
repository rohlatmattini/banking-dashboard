// lib/domain/repositories/account_repository.dart
import '../dtos/transaction_dto.dart';
import '../entities/account_entity.dart';
import '../enums/account_type_enum.dart';

abstract class AccountRepository {
  // New method to get users with their accounts
  Future<List<Map<String, dynamic>>> getUsersWithAccounts();

  Future<AccountEntity> createUserAccount({
    required int userId,
    required AccountTypeEnum type,
    String? dailyLimit,
    String? monthlyLimit,
  });

  Future<AccountEntity?> findByPublicId(String publicId);
  Future<AccountEntity> updateStateByPublicId(String publicId, String newState);
  Future<AccountEntity> createGroup(int userId);
  Future<Map<String, dynamic>> deposit(DepositData data, String idempotencyKey);
  Future<Map<String, dynamic>> withdraw(WithdrawData data, String idempotencyKey);
  Future<Map<String, dynamic>> transfer(TransferData data, String idempotencyKey);
}