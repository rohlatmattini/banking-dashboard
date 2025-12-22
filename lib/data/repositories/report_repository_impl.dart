// lib/data/repositories/report_repository_impl.dart
import 'package:bankingplatform/domain/entities/account_entity.dart';
import 'package:bankingplatform/domain/patterns/composite/account_component.dart';
import 'package:bankingplatform/domain/patterns/composite/account_group.dart';
import 'package:bankingplatform/domain/patterns/composite/account_leaf.dart';
import 'package:bankingplatform/domain/repositories/report_repository.dart';
import '../datasource/api_report_data_source.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ApiReportDataSource _dataSource;

  ReportRepositoryImpl() : _dataSource = ApiReportDataSource();

  @override
  Future<AccountComponent> buildAccountHierarchy(List<AccountEntity> accounts) async {
    final groupAccount = accounts.firstWhere(
          (account) => account.type.value == 'group',
      orElse: () => accounts.first,
    );

    final group = AccountGroup(groupAccount);

    for (var account in accounts) {
      if (account.type.value == 'group') continue;
      if (account.parentId == groupAccount.id) {
        group.add(AccountLeaf(account));
      }
    }

    return group;
  }

  @override
  Future<List<Map<String, dynamic>>> getDailyReport(DateTime date) async {
    try {
      final formattedDate = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final data = await _dataSource.getDailyTransactions(formattedDate);

      if (data.containsKey('rows')) {
        return List<Map<String, dynamic>>.from(data['rows']);
      }

      return [];
    } catch (e) {
      print('Error fetching daily report: $e');
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAccountSummaries() async {
    try {
      return await _dataSource.getAccountSummaries();
    } catch (e) {
      print('Error fetching account summaries: $e');
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAuditLogs() async {
    try {
      return await _dataSource.getAuditLogs();
    } catch (e) {
      print('Error fetching audit logs: $e');
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> getSystemSummary() async {
    try {
      return await _dataSource.getSystemSummary();
    } catch (e) {
      print('Error fetching system summary: $e');
      return {};
    }
  }
}