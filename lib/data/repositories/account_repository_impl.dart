// lib/data/repositories/account_repository_impl.dart
import '../../domain/dtos/transaction_dto.dart';
import '../../domain/repositories/account_repository.dart';
import '../../domain/entities/account_entity.dart';
import '../../domain/enums/account_type_enum.dart';
import '../datasource/api_account_data_source.dart';
import '../model/account_model.dart';

class AccountRepositoryImpl implements AccountRepository {
  final ApiAccountDataSource dataSource;

  AccountRepositoryImpl({required this.dataSource});

  @override
  Future<List<Map<String, dynamic>>> getUsersWithAccounts() async {
    return await dataSource.fetchUsersWithAccounts();
  }

  @override
  Future<AccountEntity> createUserAccount({
    required int userId,
    required AccountTypeEnum type,
    String? dailyLimit,
    String? monthlyLimit,
  }) async {
    return await dataSource.createUserAccount(
      userId: userId,
      type: type,
      dailyLimit: dailyLimit,
      monthlyLimit: monthlyLimit,
    );
  }

  @override
  Future<AccountEntity?> findByPublicId(String publicId) async {
    return await dataSource.fetchAccount(publicId);
  }

  @override
  Future<AccountEntity> updateStateByPublicId(
      String publicId,
      String newState,
      ) async {
    return await dataSource.updateState(publicId, newState);
  }

  @override
  Future<AccountEntity> createGroup(int userId) async {
    final newAccount = AccountModel.createNew(
      userId: userId,
      type: AccountTypeEnum.GROUP,
    );

    return await dataSource.createAccount(newAccount);
  }
  @override
  Future<Map<String, dynamic>> deposit(DepositData data, String idempotencyKey) async {
    return await dataSource.deposit(data, idempotencyKey);
  }

  @override
  Future<Map<String, dynamic>> withdraw(WithdrawData data, String idempotencyKey) async {
    return await dataSource.withdraw(data, idempotencyKey);
  }

  @override
  Future<Map<String, dynamic>> transfer(TransferData data, String idempotencyKey) async {
    return await dataSource.transfer(data, idempotencyKey);
  }

}