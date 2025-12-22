// lib/data/datasource/api_account_data_source.dart
import 'package:dio/dio.dart';
import '../../domain/dtos/approval_decision_dto.dart';
import '../../domain/dtos/transaction_dto.dart';
import '../../domain/dtos/transaction_query_dto.dart';
import '../../domain/entities/transaction_detail_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../model/transaction_detail_model.dart';
import '../model/transaction_model.dart';
import 'account_data_source.dart';
import '../model/account_model.dart';
import '../../domain/entities/account_entity.dart';
import '../../domain/enums/account_type_enum.dart';
import '../../domain/dtos/onboard_customer_dto.dart';

class ApiAccountDataSource implements AccountDataSource {
  final Dio _dio = Dio(BaseOptions(
      baseUrl: 'http://127.0.0.1:8000/api/v1',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',

      }));

  static const String _authToken = '1|8d9DxyeC3oYBWMONOzpOJYBozOspoVy9EUzgnVkbf028fb46';

  ApiAccountDataSource() {
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

  @override
  Future<List<Map<String, dynamic>>> fetchUsersWithAccounts() async {
    try {
      final response = await _dio.get('/accounts/admin/users-with-accounts');

      if (response.data is Map && response.data.containsKey('data')) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }

      return [];
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to fetch users: ${e.response!.data}');
      } else {
        throw Exception('Failed to fetch users: ${e.message}');
      }
    }
  }

  @override
  Future<AccountEntity?> fetchAccount(String publicId) async {
    try {
      final response = await _dio.get('/accounts/$publicId');

      if (response.data is Map && response.data.containsKey('data')) {
        return AccountModel.fromJson(response.data['data']);
      }

      return AccountModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw Exception('Failed to fetch account: $e');
    }
  }

  @override
  Future<AccountEntity> createAccount(AccountEntity account) async {
    try {
      final response = await _dio.post('/accounts', data: {
        'type': account.type.value,
        'daily_limit': account.dailyLimit,
        'monthly_limit': account.monthlyLimit,
      });

      if (response.data is Map && response.data.containsKey('data')) {
        return AccountModel.fromJson(response.data['data']);
      }

      return AccountModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to create account: ${e.response!.data}');
      } else {
        throw Exception('Failed to create account: ${e.message}');
      }
    }
  }

  @override
  Future<AccountEntity> createUserAccount({
    required int userId,
    required AccountTypeEnum type,
    String? dailyLimit,
    String? monthlyLimit,
  }) async {
    try {
      final response = await _dio.post('/accounts/users/$userId', data: {
        'type': type.value,
        'daily_limit': dailyLimit,
        'monthly_limit': monthlyLimit,
      });

      if (response.data is Map && response.data.containsKey('data')) {
        return AccountModel.fromJson(response.data['data']);
      }

      return AccountModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to create user account: ${e.response!.data}');
      } else {
        throw Exception('Failed to create user account: ${e.message}');
      }
    }
  }


  @override
  Future<Map<String, dynamic>> onboardCustomer(OnboardCustomerData data) async {
    try {
      final Map<String, dynamic> requestData = {
        'customer': {
          'name': data.customer.name,
          'email': data.customer.email,
          'phone': data.customer.phone,
        },
        'accounts': data.accounts.map((account) {
          final Map<String, dynamic> accountData = {
            'type': account.type.value,
          };

          if (account.dailyLimit != null && account.dailyLimit!.isNotEmpty) {
            try {
              accountData['daily_limit'] = double.parse(account.dailyLimit!);
            } catch (e) {
              accountData['daily_limit'] = account.dailyLimit;
            }
          }

          if (account.monthlyLimit != null && account.monthlyLimit!.isNotEmpty) {
            try {
              accountData['monthly_limit'] = double.parse(account.monthlyLimit!);
            } catch (e) {
              accountData['monthly_limit'] = account.monthlyLimit;
            }
          }

          return accountData;
        }).toList(),
      };

      print('Sending data to API: $requestData');
      final response = await _dio.post('/accounts/onboard', data: requestData);

      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response!.data;
        final errorMessage = errorData is Map &&
            errorData.containsKey('message')
            ? errorData['message']
            : 'Failed to onboard customer';
        throw Exception('$errorMessage (${e.response!.statusCode})');
      } else {
        throw Exception('Failed to onboard customer: ${e.message}');
      }
    }

  }

  @override
  Future<AccountEntity> updateState(String publicId, String newState) async {
    try {
      final response = await _dio.patch(
        '/accounts/$publicId/state',
        data: {'state': newState},
      );

      if (response.data is Map && response.data.containsKey('data')) {
        return AccountModel.fromJson(response.data['data']);
      }

      return AccountModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to update state: ${e.response!.data}');
      } else {
        throw Exception('Failed to update state: ${e.message}');
      }
    }
  }

// In deposit function:
  @override
  Future<Map<String, dynamic>> deposit(DepositData data, String idempotencyKey) async {
    try {
      final response = await _dio.post(
        '/transactions/deposit',
        data: data.toJson(),
        options: Options(
          headers: {
            'Idempotency-Key': idempotencyKey,
            'Authorization': 'Bearer $_authToken',
          },
        ),
      );

      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception('Request conflict detected. Please try again.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Account is not active. Cannot deposit.');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Invalid data: ${e.response!.data}');
      } else if (e.response != null) {
        final errorData = e.response!.data;
        final errorMessage = errorData is Map && errorData.containsKey('message')
            ? errorData['message']
            : 'Deposit failed: ${e.response!.statusCode}';
        throw Exception(errorMessage);
      } else {
        throw Exception('Deposit failed: ${e.message}');
      }
    }
  }

  @override
  Future<Map<String, dynamic>> withdraw(WithdrawData data, String idempotencyKey) async {
    try {
      final response = await _dio.post(
        '/transactions/withdraw',
        data: data.toJson(),
        options: Options(
          headers: {
            'Idempotency-Key': idempotencyKey,
            'Authorization': 'Bearer $_authToken',
          },
        ),
      );

      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception('Request conflict detected. Please try again.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Account is not active. Cannot withdraw.');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Invalid data: ${e.response!.data}');
      } else if (e.response?.statusCode == 422) {
        throw Exception('Insufficient balance.');
      } else if (e.response != null) {
        final errorData = e.response!.data;
        final errorMessage = errorData is Map && errorData.containsKey('message')
            ? errorData['message']
            : 'Withdrawal failed: ${e.response!.statusCode}';
        throw Exception(errorMessage);
      } else {
        throw Exception('Withdrawal failed: ${e.message}');
      }
    }
  }


  @override
  Future<Map<String, dynamic>> transfer(TransferData data, String idempotencyKey) async {
    try {
      final response = await _dio.post(
        '/transactions/transfer',
        data: data.toJson(),
        options: Options(
          headers: {
            'Idempotency-Key': idempotencyKey,
          },
        ),
      );

      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception('Request conflict detected. Please try again.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('One or both accounts are not active. Cannot transfer.');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Invalid data: ${e.response!.data}');
      } else if (e.response?.statusCode == 422) {
        throw Exception('Insufficient balance or transfer limit exceeded.');
      } else if (e.response != null) {
        final errorData = e.response!.data;
        final errorMessage = errorData is Map && errorData.containsKey('message')
            ? errorData['message']
            : 'Transfer failed: ${e.response!.statusCode}';
        throw Exception(errorMessage);
      } else {
        throw Exception('Transfer failed: ${e.message}');
      }
    }
  }




  @override
  Future<List<TransactionEntity>> fetchTransactions({String? scope}) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (scope != null) {
        queryParams['scope'] = scope;
      }

      final response = await _dio.get(
        '/transactions',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.data is Map && response.data.containsKey('items')) {
        final items = List<Map<String, dynamic>>.from(response.data['items']);
        return items.map((item) => TransactionModel.fromJson(item)).toList();
      }

      return [];
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to fetch transactions: ${e.response!.data}');
      } else {
        throw Exception('Failed to fetch transactions: ${e.message}');
      }
    }
  }

  @override
  Future<TransactionDetailEntity> fetchTransactionDetail(String transactionId, {String? scope}) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (scope != null) {
        queryParams['scope'] = scope;
      }

      final response = await _dio.get(
        '/transactions/$transactionId',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      return TransactionDetailModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Transaction not found');
      } else if (e.response != null) {
        throw Exception('Failed to fetch transaction details: ${e.response!.data}');
      } else {
        throw Exception('Failed to fetch transaction details: ${e.message}');
      }
    }
  }

  @override
  Future<List<TransactionEntity>> fetchPendingApprovals() async {
    try {
      final response = await _dio.get('/transactions/pending-approvals');

      print('Pending Approvals API Response: ${response.data}'); // للتصحيح

      if (response.data is Map && response.data.containsKey('items')) {
        final items = List<Map<String, dynamic>>.from(response.data['items']);

        final List<TransactionModel> transactions = [];

        for (var item in items) {
          try {
            final transaction = TransactionModel.fromJson(item);
            transactions.add(transaction);
          } catch (e) {
            print('Error parsing transaction item: $e');
            print('Problematic item: $item');
          }
        }

        return transactions;
      }

      return [];
    } on DioException catch (e) {
      print('DioException in fetchPendingApprovals: $e');
      print('Response: ${e.response?.data}');

      if (e.response != null) {
        throw Exception('Failed to fetch pending approvals: ${e.response!.data}');
      } else {
        throw Exception('Failed to fetch pending approvals: ${e.message}');
      }
    } catch (e) {
      print('General error in fetchPendingApprovals: $e');
      throw Exception('Failed to fetch pending approvals: $e');
    }
  }
  @override
  Future<Map<String, dynamic>> submitApprovalDecision(
      String transactionId,
      ApprovalDecisionData decision
      ) async {
    try {
      final response = await _dio.post(
        '/transactions/$transactionId/decision',
        data: decision.toJson(),
      );

      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Transaction not found');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Invalid decision data: ${e.response!.data}');
      } else if (e.response != null) {
        throw Exception('Failed to submit approval decision: ${e.response!.data}');
      } else {
        throw Exception('Failed to submit approval decision: ${e.message}');
      }
    }
  }
}