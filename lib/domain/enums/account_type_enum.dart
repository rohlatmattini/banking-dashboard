enum AccountTypeEnum {
  GROUP('group', 'Group', 'مجموعة', '#009688'),
  SAVINGS('savings', 'Savings', 'توفير', '#4CAF50'),
  CHECKING('checking', 'Checking', 'جاري', '#2196F3'),
  LOAN('loan', 'Loan', 'قرض', '#FF9800'),
  INVESTMENT('investment', 'Investment', 'استثمار', '#9C27B0');

  final String value;
  final String englishName;
  final String arabicName;
  final String colorHex;

  const AccountTypeEnum(this.value, this.englishName, this.arabicName, this.colorHex);

  static AccountTypeEnum fromValue(String value) {
    return values.firstWhere(
          (e) => e.value == value,
      orElse: () => SAVINGS,
    );
  }

  // Add toString method to display English name
  @override
  String toString() => englishName;
}