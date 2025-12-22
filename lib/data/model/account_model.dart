// lib/data/model/account_model.dart
import '../../domain/entities/account_entity.dart';
import '../../domain/enums/account_type_enum.dart';
import '../../domain/patterns/states/account_state_factory.dart';

class AccountModel extends AccountEntity {
  AccountModel({
    required int id,
    required String publicId,
    required int userId,
    required int? parentId,
    required AccountTypeEnum type,
    required double balance,
    required String state,
    String? dailyLimit,
    String? monthlyLimit,
    String? closedAt,
    required String createdAt,
    required String updatedAt,
    String? userName,
    String? userEmail,
    String? userPhone,
  }) : super(
    id: id,
    publicId: publicId,
    userId: userId,
    parentId: parentId,
    type: type,
    balance: balance,
    state: AccountStateFactory.from(state),
    dailyLimit: dailyLimit,
    monthlyLimit: monthlyLimit,
    closedAt: closedAt != null ? DateTime.parse(closedAt) : null,
    createdAt: DateTime.parse(createdAt),
    updatedAt: DateTime.parse(updatedAt),
    userName: userName,
    userEmail: userEmail,
    userPhone: userPhone,
  );

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final intId = id is int ? id : (id is String ? int.tryParse(id) ?? 0 : 0);

    String publicId;
    if (json['public_id'] != null) {
      publicId = json['public_id'].toString();
    } else if (json['id'] != null) {
      publicId = json['id'].toString();
    } else {
      publicId = '';
    }

    final parentId = json['parent_public_id']?.toString();

    return AccountModel(
      id: intId,
      publicId: publicId,
      userId: 0,
      parentId: parentId != null ? int.tryParse(parentId) : null,
      type: AccountTypeEnum.fromValue(json['type'] as String? ?? 'checking'),
      balance: (json['balance'] is String
          ? double.tryParse(json['balance'])
          : (json['balance'] as num?)?.toDouble()) ?? 0.0,
      state: json['state'] as String? ?? 'active',
      dailyLimit: json['daily_limit']?.toString(),
      monthlyLimit: json['monthly_limit']?.toString(),
      closedAt: json['closed_at'] as String?,
      createdAt: json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      updatedAt: json['updated_at'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  factory AccountModel.fromUserAccountData(Map<String, dynamic> accountData, Map<String, dynamic> userData) {
    final model = AccountModel.fromJson(accountData);

    return AccountModel(
      id: model.id,
      publicId: model.publicId,
      userId: userData['id'] is int ? userData['id'] : 0,
      parentId: model.parentId,
      type: model.type,
      balance: model.balance,
      state: model.state.name,
      dailyLimit: model.dailyLimit,
      monthlyLimit: model.monthlyLimit,
      closedAt: model.closedAt?.toIso8601String(),
      createdAt: model.createdAt.toIso8601String(),
      updatedAt: model.updatedAt.toIso8601String(),
      userName: userData['name'] as String?,
      userEmail: userData['email'] as String?,
      userPhone: userData['phone'] as String?,
    );
  }

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

  factory AccountModel.createNew({
    required int userId,
    required AccountTypeEnum type,
    double initialBalance = 0.0,
    String? dailyLimit,
    String? monthlyLimit,
    String? userName,
    String? userEmail,
    String? userPhone,
  }) {
    return AccountModel(
      id: 0,
      publicId: '',
      userId: userId,
      parentId: null,
      type: type,
      balance: initialBalance,
      state: 'active',
      dailyLimit: dailyLimit,
      monthlyLimit: monthlyLimit,
      closedAt: null,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
      userName: userName,
      userEmail: userEmail,
      userPhone: userPhone,
    );
  }

  AccountModel copyWith({
    int? id,
    String? publicId,
    int? userId,
    int? parentId,
    AccountTypeEnum? type,
    double? balance,
    String? state,
    String? dailyLimit,
    String? monthlyLimit,
    String? closedAt,
    String? createdAt,
    String? updatedAt,
    String? userName,
    String? userEmail,
    String? userPhone,
  }) {
    return AccountModel(
      id: id ?? this.id,
      publicId: publicId ?? this.publicId,
      userId: userId ?? this.userId,
      parentId: parentId ?? this.parentId,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      state: state ?? this.state.name,
      dailyLimit: dailyLimit ?? this.dailyLimit,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      closedAt: closedAt ?? this.closedAt?.toIso8601String(),
      createdAt: createdAt ?? this.createdAt.toIso8601String(),
      updatedAt: updatedAt ?? this.updatedAt.toIso8601String(),
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userPhone: userPhone ?? this.userPhone,
    );
  }
}