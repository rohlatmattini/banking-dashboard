// lib/data/model/transaction_model.dart
import '../../domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  TransactionModel({
    required super.publicId,
    required super.type,
    required super.status,
    required super.amount,
    required super.currency,
    required super.description,
    required super.postedAt,
    required super.createdAt,
    super.sourceAccountId,
    super.destinationAccountId,
    required super.initiatorUserId,
  });


  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseNullableDateTime(dynamic value) {
      if (value == null || value.toString().isEmpty) {
        return null;
      }
      try {
        return DateTime.parse(value.toString());
      } catch (e) {
        return null;
      }
    }

    int? parseAccountId(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) {
        return int.tryParse(value);
      }
      return null;
    }

    return TransactionModel(
      publicId: json['public_id'] as String? ?? '',
      type: TransactionType.fromValue(json['type']?.toString() ?? ''),
      status: TransactionStatus.fromValue(json['status']?.toString() ?? ''),
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      currency: json['currency'] as String? ?? 'USD',
      description: json['description'] as String? ?? '',
      postedAt: parseNullableDateTime(json['posted_at']), // ✅ يستخدم الدالة المشتركة
      createdAt: parseNullableDateTime(json['created_at']) ?? DateTime.now(),
      sourceAccountId: parseAccountId(json['source_account_id']),
      destinationAccountId: parseAccountId(json['destination_account_id']),
      initiatorUserId: json['initiator_user_id'] as int? ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'public_id': publicId,
      'type': type.value,
      'status': status.value,
      'amount': amount,
      'currency': currency,
      'description': description,
      'posted_at': postedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'source_account_id': sourceAccountId,
      'destination_account_id': destinationAccountId,
      'initiator_user_id': initiatorUserId,
    };
  }
}