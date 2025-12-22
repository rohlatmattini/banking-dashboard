import '../dtos/approval_decision_dto.dart';
import '../dtos/transaction_dto.dart';
import '../entities/account_entity.dart';
import '../entities/transaction_detail_entity.dart';
import '../entities/transaction_entity.dart';
import '../enums/account_type_enum.dart';

abstract class AccountRepository {
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

  Future<List<TransactionEntity>> getTransactions({String? scope});
  Future<TransactionDetailEntity> getTransactionDetail(String transactionId, {String? scope});

  Future<List<TransactionEntity>> getPendingApprovals();
  Future<Map<String, dynamic>> submitApprovalDecision(
      String transactionId,
      ApprovalDecisionData decision
      );
}

