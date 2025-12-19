// lib/data/datasource/api_account_data_source.dart
import 'package:dio/dio.dart';
import '../../domain/dtos/transaction_dto.dart';
import 'account_data_source.dart';
import '../model/account_model.dart';
import '../../domain/entities/account_entity.dart';
import '../../domain/enums/account_type_enum.dart';
import '../../domain/dtos/onboard_customer_dto.dart';

class ApiAccountDataSource implements AccountDataSource {
  final Dio _dio = Dio(BaseOptions(
      baseUrl: 'http://127.0.0.1:8000/api/v1',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',

      }));

  static const String _authToken = '19|NO0RBzShYkdX8fVns3QgEWYXLseUP0wI2ko9UFjK27f982a4';

  ApiAccountDataSource() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers['Authorization'] = 'Bearer $_authToken';
        return handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // معالجة انتهاء صلاحية التوكن
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

  // lib/data/datasource/api_account_data_source.dart

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

// In withdraw function:
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

// In transfer function:
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
}