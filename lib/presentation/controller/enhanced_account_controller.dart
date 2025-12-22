import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/patterns/strategy/transaction_strategy_factory.dart';
import '../../domain/repositories/account_repository.dart';
import '../../domain/dtos/transaction_dto.dart';
import '../../domain/patterns/decorators/error_handling_account_repository.dart';
import '../../domain/dtos/open_account_dto.dart';

class EnhancedAccountController extends GetxController {
  final AccountRepository repository;
  final TransactionStrategyFactory strategyFactory;
  final Uuid uuid = const Uuid();

  EnhancedAccountController({required this.repository})
      : strategyFactory = TransactionStrategyFactory(repository);

  final usersWithAccounts = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;
  final isProcessingTransaction = false.obs;
  String? currentIdempotencyKey;

  @override
  void onInit() {
    fetchUsersWithAccounts();
    super.onInit();
  }

  Future<void> fetchUsersWithAccounts() async {
    isLoading.value = true;
    try {
      final result = await repository.getUsersWithAccounts();
      usersWithAccounts.assignAll(result);
    } catch (e) {
      _showError('Failed to load users', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createUserAccount(int userId, OpenAccountData data) async {
    try {
      isLoading.value = true;

      final newAccount = await repository.createUserAccount(
        userId: userId,
        type: data.type,
        dailyLimit: data.dailyLimit,
        monthlyLimit: data.monthlyLimit,
      );

      await fetchUsersWithAccounts();

      _showSuccess('Account created successfully');
    } catch (e) {
      _showError('Failed to create account', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changeAccountState(String publicId, String newState) async {
    try {
      isLoading.value = true;

      final updated = await repository.updateStateByPublicId(publicId, newState);

      await fetchUsersWithAccounts();

      _showSuccess('Account status changed successfully');
    } catch (e) {
      _showError('Failed to change account status', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deposit({
    required String accountPublicId,
    required double amount,
    String description = '',
  }) async {
    await _processTransaction(
      type: TransactionType.DEPOSIT,
      data: DepositData(
        accountPublicId: accountPublicId,
        amount: amount,
        description: description,
      ),
      sourceAccountId: accountPublicId,
    );
  }

  Future<void> withdraw({
    required String accountPublicId,
    required double amount,
    String description = '',
  }) async {
    await _processTransaction(
      type: TransactionType.WITHDRAW,
      data: WithdrawData(
        accountPublicId: accountPublicId,
        amount: amount,
        description: description,
      ),
      sourceAccountId: accountPublicId,
    );
  }

  Future<void> transfer({
    required String sourceAccountPublicId,
    required String destinationAccountPublicId,
    required double amount,
    String description = '',
  }) async {
    await _processTransaction(
      type: TransactionType.TRANSFER,
      data: TransferData(
        sourceAccountPublicId: sourceAccountPublicId,
        destinationAccountPublicId: destinationAccountPublicId,
        amount: amount,
        description: description,
      ),
      sourceAccountId: sourceAccountPublicId,
      destinationAccountId: destinationAccountPublicId,
    );
  }

  Future<void> _processTransaction({
    required TransactionType type,
    required dynamic data,
    String? sourceAccountId,
    String? destinationAccountId,
  }) async {
    try {
      isProcessingTransaction.value = true;
      currentIdempotencyKey = uuid.v4();

      final strategy = await strategyFactory.createStrategy(
        type: type,
        data: data,
        sourceAccountId: sourceAccountId,
        destinationAccountId: destinationAccountId,
      );

      final validationErrors = strategy.validate({
        'user_id': _getCurrentUserId(),
        'timestamp': DateTime.now().toIso8601String(),
      });

      if (validationErrors.isNotEmpty) {
        throw ValidationException(
          'Transaction validation failed',
          data: validationErrors,
        );
      }

      final result = await strategy.execute(
        idempotencyKey: currentIdempotencyKey!,
        context: {
          'user_id': _getCurrentUserId(),
          'ip_address': _getUserIp(),
          'device_info': _getDeviceInfo(),
        },
      );

      await strategy.postProcess(result, {
        'transaction_type': type.value,
        'amount': _getAmountFromData(data),
        'timestamp': DateTime.now().toIso8601String(),
      });

      await fetchUsersWithAccounts();

      _showSuccess('${_capitalizeFirst(type.value)} successful');

    } on AppException catch (e) {
      _showError(_capitalizeFirst(e.code.replaceAll('_', ' ')), e.message);
    } catch (e) {
      _showError('Transaction Failed', e.toString());
    } finally {
      isProcessingTransaction.value = false;
      currentIdempotencyKey = null;
    }
  }

  Map<String, dynamic>? findAccount(String publicId) {
    for (var user in usersWithAccounts) {
      final accounts = List<Map<String, dynamic>>.from(user['accounts'] ?? []);
      for (var account in accounts) {
        if (account['public_id'] == publicId) {
          return account;
        }
      }
    }
    return null;
  }

  int _getCurrentUserId() {
    return 1;
  }

  String _getUserIp() {
    return '127.0.0.1';
  }

  String _getDeviceInfo() {
    return 'Flutter Web';
  }

  double _getAmountFromData(dynamic data) {
    if (data is DepositData) return data.amount;
    if (data is WithdrawData) return data.amount;
    if (data is TransferData) return data.amount;
    return 0.0;
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.teal,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void _showError(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }

  void _showInfo(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.grey[700],
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  Map<String, int> getUserStatistics(Map<String, dynamic> userData) {
    final accounts = List<Map<String, dynamic>>.from(userData['accounts'] ?? []);

    Map<String, int> stats = {
      'total': accounts.length,
      'active': 0,
      'frozen': 0,
      'suspended': 0,
      'closed': 0,
    };

    for (var account in accounts) {
      final state = account['state'] as String? ?? 'active';
      switch (state) {
        case 'active':
          stats['active'] = stats['active']! + 1;
          break;
        case 'frozen':
          stats['frozen'] = stats['frozen']! + 1;
          break;
        case 'suspended':
          stats['suspended'] = stats['suspended']! + 1;
          break;
        case 'closed':
          stats['closed'] = stats['closed']! + 1;
          break;
      }
    }

    return stats;
  }
}