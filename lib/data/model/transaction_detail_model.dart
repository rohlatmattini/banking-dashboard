// lib/data/model/transaction_detail_model.dart
import '../../domain/entities/transaction_detail_entity.dart';
import '../../domain/entities/ledger_entry_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import 'ledger_entry_model.dart';

class TransactionDetailModel extends TransactionDetailEntity {
  TransactionDetailModel({
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
    required super.ledgerEntries,
    super.approval,
  });

  factory TransactionDetailModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;

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

    List<LedgerEntryModel> parseLedgerEntries(dynamic entries) {
      if (entries == null || entries is! List) {
        return [];
      }
      return entries.map((entry) {
        try {
          return LedgerEntryModel.fromJson(entry);
        } catch (e) {
          return LedgerEntryModel(
            accountPublicId: '',
            direction: EntryDirection.DEBIT,
            amount: 0.0,
            currency: 'USD',
            balanceBefore: 0.0,
            balanceAfter: 0.0,
            createdAt: DateTime.now(),
          );
        }
      }).toList();
    }

    return TransactionDetailModel(
      publicId: data['public_id'] as String? ?? '',
      type: TransactionType.fromValue(data['type']?.toString() ?? ''),
      status: TransactionStatus.fromValue(data['status']?.toString() ?? ''),
      amount: double.tryParse(data['amount']?.toString() ?? '0') ?? 0.0,
      currency: data['currency'] as String? ?? 'USD',
      description: data['description'] as String? ?? '',
      postedAt: parseNullableDateTime(data['posted_at']), // ✅ يتعامل مع null
      createdAt: parseNullableDateTime(data['created_at']) ?? DateTime.now(),
      sourceAccountId: data['source_account_id'] as int?,
      destinationAccountId: data['destination_account_id'] as int?,
      initiatorUserId: data['initiator_user_id'] as int? ?? 0,
      ledgerEntries: parseLedgerEntries(data['ledger_entries']),
      approval: data['approval'],
    );
  }}