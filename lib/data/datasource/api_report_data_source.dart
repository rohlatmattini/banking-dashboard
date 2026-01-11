// lib/data/datasource/api_report_data_source.dart
import 'package:dio/dio.dart';

class ApiReportDataSource {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://127.0.0.1:8000/api/v1',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  ));

  static const String _authToken = '9|siYSI26jNISEEdqppbZX7EluSDJrXy76P53W9nPka143975e';

  ApiReportDataSource() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers['Authorization'] = 'Bearer $_authToken';
        return handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          print(" The token has expired");
        }
        return handler.next(error);
      },
    ));
  }

  Future<Map<String, dynamic>> getDailyTransactions(String date) async {
    try {
      final response = await _dio.get('/reports/daily-transactions');

      if (response.data is Map && response.data.containsKey('data')) {
        return response.data['data'];
      }

      return {};
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to fetch daily transactions: ${e.response!.data}');
      } else {
        throw Exception('Failed to fetch daily transactions: ${e.message}');
      }
    }
  }

  Future<List<Map<String, dynamic>>> getAuditLogs() async {
    try {
      final response = await _dio.get('/reports/audit-logs');

      if (response.data is Map && response.data.containsKey('data')) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }

      return [];
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to fetch audit logs: ${e.response!.data}');
      } else {
        throw Exception('Failed to fetch audit logs: ${e.message}');
      }
    }
  }

  Future<Map<String, dynamic>> getSystemSummary() async {
    try {
      final dailyResponse = await getDailyTransactions(DateTime.now().toIso8601String().split('T')[0]);
      final auditLogs = await getAuditLogs();

      return {
        'daily_transactions': dailyResponse,
        'audit_logs_count': auditLogs.length,
        'date': DateTime.now().toIso8601String().split('T')[0],
      };
    } catch (e) {
      throw Exception('Failed to get system summary: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAccountSummaries() async {
    try {
      return [
        {
          'type': 'checking',
          'total': 0,
          'active': 0,
          'balance': 0.0,
        },
        {
          'type': 'savings',
          'total': 0,
          'active': 0,
          'balance': 0.0,
        },
      ];
    } catch (e) {
      throw Exception('Failed to get account summaries: $e');
    }
  }
}