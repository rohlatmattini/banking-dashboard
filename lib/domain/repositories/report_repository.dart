import '../entities/account_entity.dart';
import '../patterns/composite/account_component.dart';

abstract class ReportRepository {
  Future<AccountComponent> buildAccountHierarchy(List<AccountEntity> accounts);

  Future<List<Map<String, dynamic>>> getDailyReport(DateTime date);
  Future<List<Map<String, dynamic>>> getAccountSummaries();
  Future<List<Map<String, dynamic>>> getAuditLogs();
  Future<Map<String, dynamic>> getSystemSummary();
}