class LedgerEntryEntity {
  final String accountPublicId;
  final EntryDirection direction;
  final double amount;
  final String currency;
  final double balanceBefore;
  final double balanceAfter;
  final DateTime createdAt;

  LedgerEntryEntity({
    required this.accountPublicId,
    required this.direction,
    required this.amount,
    required this.currency,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.createdAt,
  });
}

enum EntryDirection {
  DEBIT('debit'),
  CREDIT('credit');

  final String value;

  const EntryDirection(this.value);

  static EntryDirection fromValue(String value) {
    return values.firstWhere(
          (e) => e.value == value,
      orElse: () => DEBIT,
    );
  }
}