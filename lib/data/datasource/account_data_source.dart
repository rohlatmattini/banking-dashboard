// lib/data/datasource/account_data_source.dart
import '../../domain/dtos/onboard_customer_dto.dart';
import '../../domain/entities/account_entity.dart';
import '../../domain/enums/account_type_enum.dart';

abstract class AccountDataSource {
  Future<List<Map<String, dynamic>>> fetchUsersWithAccounts();
  Future<AccountEntity?> fetchAccount(String publicId);
  Future<AccountEntity> createAccount(AccountEntity account);
  Future<AccountEntity> updateState(String publicId, String newState);
  Future<AccountEntity> createUserAccount({
    required int userId,
    required AccountTypeEnum type,
    String? dailyLimit,
    String? monthlyLimit,
  });
  Future<Map<String, dynamic>> onboardCustomer(OnboardCustomerData data); // تغيير النوع هنا
}