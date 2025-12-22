abstract class TransactionEntity {
  final String publicId;
  final TransactionType type;
  final TransactionStatus status;
  final double amount;
  final String currency;
  final String description;
  final DateTime? postedAt;
  final DateTime createdAt;
  final int? sourceAccountId;
  final int? destinationAccountId;
  final int initiatorUserId;

  TransactionEntity({
    required this.publicId,
    required this.type,
    required this.status,
    required this.amount,
    required this.currency,
    required this.description,
    this.postedAt,
    required this.createdAt,
    this.sourceAccountId,
    this.destinationAccountId,
    required this.initiatorUserId,
  });
}

enum TransactionType {
  DEPOSIT('deposit'),
  WITHDRAW('withdraw'),
  TRANSFER('transfer');

  final String value;

  const TransactionType(this.value);

  static TransactionType fromValue(String value) {
    return values.firstWhere(
          (e) => e.value == value,
      orElse: () => DEPOSIT,
    );
  }
}

enum TransactionStatus {
  PENDING('pending'),
  PENDING_APPROVAL('pending_approval'),
  POSTED('posted'),
  APPROVED('approved'),
  REJECTED('rejected'),
  FAILED('failed'),
  CANCELLED('cancelled');

  final String value;

  const TransactionStatus(this.value);

  static TransactionStatus fromValue(String value) {
    return values.firstWhere(
          (e) => e.value == value,
      orElse: () => PENDING,
    );
  }

  bool get needsApproval => this == PENDING_APPROVAL;
  bool get isApproved => this == APPROVED || this == POSTED;
  bool get isRejected => this == REJECTED;
  bool get isPending => this == PENDING || this == PENDING_APPROVAL;
}