// lib/presentation/controller/account_controller.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../domain/dtos/transaction_dto.dart';
import '../../domain/entities/account_entity.dart';
import '../../domain/repositories/account_repository.dart';
import '../../domain/dtos/open_account_dto.dart';
import '../../domain/enums/account_type_enum.dart';
import 'package:uuid/uuid.dart';

class AccountController extends GetxController {
  final AccountRepository repository;
  final Uuid uuid = const Uuid();

  AccountController({required this.repository});

  final usersWithAccounts = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;
  final selectedAccount = Rxn<AccountEntity>();
  final selectedUserId = Rxn<int>();
  String? currentIdempotencyKey;
  final isProcessingTransaction = false.obs;

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

      // Update list after creation
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

      // Update via repository
      final updated = await repository.updateStateByPublicId(publicId, newState);

      // Update list
      await fetchUsersWithAccounts();

      _showSuccess('Account status changed successfully');
    } catch (e) {
      _showError('Failed to change account status', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Generate new key
  String generateIdempotencyKey() {
    currentIdempotencyKey = uuid.v4();
    return currentIdempotencyKey!;
  }

  // Clear key after operation completion
  void clearIdempotencyKey() {
    currentIdempotencyKey = null;
  }

  // Helper function to find account
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

  // Helper function to validate account conditions
  bool _validateAccountForOperation(Map<String, dynamic> account, String operationType) {
    final state = account['state'] as String? ?? 'active';
    final balance = double.tryParse(account['balance']?.toString() ?? '0') ?? 0.0;

    // Check account state
    if (state != 'active') {
      final stateName = _getStateName(state);
      _showInfo('Operation not allowed', 'Cannot $operationType because account is $stateName');
      return false;
    }

    return true;
  }

  // Helper function to get account state name
  String _getStateName(String state) {
    switch (state) {
      case 'active':
        return 'Active';
      case 'frozen':
        return 'Frozen';
      case 'suspended':
        return 'Suspended';
      case 'closed':
        return 'Closed';
      default:
        return state;
    }
  }

  // Deposit function with validations
  Future<void> deposit({
    required String accountPublicId,
    required double amount,
    String description = '',
  }) async {
    try {
      // Find the account
      final account = findAccount(accountPublicId);
      if (account == null) {
        _showError('Error', 'Account not found');
        return;
      }

      // Validate account conditions
      if (!_validateAccountForOperation(account, 'deposit')) {
        return;
      }

      // Validate amount is positive
      if (amount <= 0) {
        _showError('Error', 'Amount must be greater than zero');
        return;
      }

      isProcessingTransaction.value = true;
      final idempotencyKey = generateIdempotencyKey();

      final data = DepositData(
        accountPublicId: accountPublicId,
        amount: amount,
        description: description,
      );

      final result = await repository.deposit(data, idempotencyKey);

      // Update list after successful operation
      await fetchUsersWithAccounts();

      _showSuccess('Deposit successful: \$${amount.toStringAsFixed(2)}');
      clearIdempotencyKey();
    } catch (e) {
      _showError('Deposit failed', e.toString());
    } finally {
      isProcessingTransaction.value = false;
    }
  }

  // Withdraw function with validations
  Future<void> withdraw({
    required String accountPublicId,
    required double amount,
    String description = '',
  }) async {
    try {
      // Find the account
      final account = findAccount(accountPublicId);
      if (account == null) {
        _showError('Error', 'Account not found');
        return;
      }

      // Validate account conditions
      if (!_validateAccountForOperation(account, 'withdraw')) {
        return;
      }

      // Get current balance
      final balance = double.tryParse(account['balance']?.toString() ?? '0') ?? 0.0;

      // Validate amount is positive
      if (amount <= 0) {
        _showError('Error', 'Amount must be greater than zero');
        return;
      }

      // Validate sufficient balance
      if (amount > balance) {
        _showError('Insufficient balance', 'Current balance: \$${balance.toStringAsFixed(2)}\nRequested amount: \$${amount.toStringAsFixed(2)}');
        return;
      }

      // Check daily limit (if exists)
      final dailyLimit = account['daily_limit'] != null ? double.tryParse(account['daily_limit']) : null;
      if (dailyLimit != null && amount > dailyLimit) {
        _showInfo('Daily limit exceeded', 'Amount exceeds daily limit (\$${dailyLimit.toStringAsFixed(2)})');
        return;
      }

      isProcessingTransaction.value = true;
      final idempotencyKey = generateIdempotencyKey();

      final data = WithdrawData(
        accountPublicId: accountPublicId,
        amount: amount,
        description: description,
      );

      final result = await repository.withdraw(data, idempotencyKey);

      // Update list after successful operation
      await fetchUsersWithAccounts();

      _showSuccess('Withdrawal successful: \$${amount.toStringAsFixed(2)}');
      clearIdempotencyKey();
    } catch (e) {
      _showError('Withdrawal failed', e.toString());
    } finally {
      isProcessingTransaction.value = false;
    }
  }

  // Transfer function with validations
  Future<void> transfer({
    required String sourceAccountPublicId,
    required String destinationAccountPublicId,
    required double amount,
    String description = '',
  }) async {
    try {
      // Find source account
      final sourceAccount = findAccount(sourceAccountPublicId);
      if (sourceAccount == null) {
        _showError('Error', 'Source account not found');
        return;
      }

      // Find destination account
      final destinationAccount = findAccount(destinationAccountPublicId);
      if (destinationAccount == null) {
        _showError('Error', 'Destination account not found');
        return;
      }

      // Validate accounts are not the same
      if (sourceAccountPublicId == destinationAccountPublicId) {
        _showError('Error', 'Cannot transfer to the same account');
        return;
      }

      // Validate source account conditions
      if (!_validateAccountForOperation(sourceAccount, 'transfer')) {
        return;
      }

      // Validate destination account conditions
      if (!_validateAccountForOperation(destinationAccount, 'transfer')) {
        return;
      }

      // Get current balance of source account
      final sourceBalance = double.tryParse(sourceAccount['balance']?.toString() ?? '0') ?? 0.0;

      // Validate amount is positive
      if (amount <= 0) {
        _showError('Error', 'Amount must be greater than zero');
        return;
      }

      // Validate sufficient balance in source account
      if (amount > sourceBalance) {
        _showError('Insufficient balance', 'Current balance: \$${sourceBalance.toStringAsFixed(2)}\nRequested amount: \$${amount.toStringAsFixed(2)}');
        return;
      }

      // Check daily limit for source account (if exists)
      final sourceDailyLimit = sourceAccount['daily_limit'] != null ? double.tryParse(sourceAccount['daily_limit']) : null;
      if (sourceDailyLimit != null && amount > sourceDailyLimit) {
        _showInfo('Daily limit exceeded', 'Amount exceeds daily limit (\$${sourceDailyLimit.toStringAsFixed(2)})');
        return;
      }

      isProcessingTransaction.value = true;
      final idempotencyKey = generateIdempotencyKey();

      final data = TransferData(
        sourceAccountPublicId: sourceAccountPublicId,
        destinationAccountPublicId: destinationAccountPublicId,
        amount: amount,
        description: description,
      );

      final result = await repository.transfer(data, idempotencyKey);

      // Update list after successful operation
      await fetchUsersWithAccounts();

      _showSuccess('Transfer successful: \$${amount.toStringAsFixed(2)}');
      clearIdempotencyKey();
    } catch (e) {
      _showError('Transfer failed', e.toString());
    } finally {
      isProcessingTransaction.value = false;
    }
  }

  void selectUserId(int userId) {
    selectedUserId.value = userId;
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

  // New function to show informational messages (gray)
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

  // Helper function to get statistics
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