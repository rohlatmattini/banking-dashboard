class DepositData {
  final String accountPublicId;
  final double amount;
  final String description;

  DepositData({
    required this.accountPublicId,
    required this.amount,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'account_public_id': accountPublicId,
      'amount': amount,
      'description': description,
    };
  }
}

class WithdrawData {
  final String accountPublicId;
  final double amount;
  final String description;

  WithdrawData({
    required this.accountPublicId,
    required this.amount,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'account_public_id': accountPublicId,
      'amount': amount,
      'description': description,
    };
  }
}

class TransferData {
  final String sourceAccountPublicId;
  final String destinationAccountPublicId;
  final double amount;
  final String description;

  TransferData({
    required this.sourceAccountPublicId,
    required this.destinationAccountPublicId,
    required this.amount,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'source_account_public_id': sourceAccountPublicId,
      'destination_account_public_id': destinationAccountPublicId,
      'amount': amount,
      'description': description,
    };
  }
}