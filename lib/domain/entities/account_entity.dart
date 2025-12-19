// lib/domain/entities/account_entity.dart
import '../enums/account_type_enum.dart';
import '../patterns/states/account_state.dart';

abstract class AccountEntity {
  final int id;
  final String publicId;
  final int userId;
  final int? parentId;
  final AccountTypeEnum type;
  double balance;
  AccountState state;
  final String? dailyLimit;
  final String? monthlyLimit;
  final DateTime? closedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  // إضافة بيانات المستخدم
  final String? userName;
  final String? userEmail;
  final String? userPhone;

  AccountEntity({
    required this.id,
    required this.publicId,
    required this.userId,
    this.parentId,
    required this.type,
    required this.balance,
    required this.state,
    this.dailyLimit,
    this.monthlyLimit,
    this.closedAt,
    required this.createdAt,
    required this.updatedAt,
    this.userName,
    this.userEmail,
    this.userPhone,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'public_id': publicId,
      'user_id': userId,
      'parent_id': parentId,
      'type': type.value,
      'state': state.name,
      'balance': balance,
      'daily_limit': dailyLimit,
      'monthly_limit': monthlyLimit,
      'closed_at': closedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user_name': userName,
      'user_email': userEmail,
      'user_phone': userPhone,
    };
  }


  bool get isGroup => type == AccountTypeEnum.GROUP;

  bool canTransitionTo(String targetState) {
    return state.canTransitionTo(targetState);
  }

  String transitionError(String targetState) {
    return state.transitionError(targetState);
  }

  void changeState(String newState) {
    if (!canTransitionTo(newState)) {
      throw StateError(transitionError(newState));
    }
  }

  String deposit(double amount) {
    if (!state.canDeposit) {
      throw StateError('لا يمكن الإيداع: الحساب ${state}');
    }

    balance += amount;

    return 'تم إيداع \$${amount.toStringAsFixed(2)} بنجاح';
  }

  String withdraw(double amount) {
    if (!state.canWithdraw) {
      throw StateError('لا يمكن السحب: الحساب ${state}');
    }

    if (amount > balance) {
      throw StateError('رصيد غير كافي');
    }

    balance -= amount;
    return 'تم سحب \$${amount.toStringAsFixed(2)} بنجاح';
  }

  String get holderName => userName ?? 'User $userId';
  String get statusColorHex => state.colorHex;

  bool get canDelete => state.name == 'closed';

  // In AccountEntity class, add these methods:
  bool canDeposit() {
    return state.name == 'active';
  }

  bool canWithdraw() {
    if (state.name != 'active') return false;
    return balance > 0;
  }

  bool canTransfer() {
    return state.name == 'active';
  }

  String? validateDeposit(double amount) {
    if (!canDeposit()) {
      return 'Cannot deposit: Account is ${state.name}';
    }
    if (amount <= 0) {
      return 'Amount must be greater than zero';
    }
    return null;
  }

  String? validateWithdraw(double amount) {
    if (!canWithdraw()) {
      return 'Cannot withdraw: Account is ${state.name}';
    }
    if (amount <= 0) {
      return 'Amount must be greater than zero';
    }
    if (amount > balance) {
      return 'Insufficient balance. Current balance: \$${balance.toStringAsFixed(2)}';
    }
    return null;
  }

  String? validateTransfer(double amount, AccountEntity destinationAccount) {
    final withdrawError = validateWithdraw(amount);
    if (withdrawError != null) return withdrawError;

    if (!destinationAccount.canDeposit()) {
      return 'Cannot transfer to destination account: ${destinationAccount.state.name}';
    }

    return null;
  }
}