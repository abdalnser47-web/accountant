class Account {
  final String id;
  final String name;
  final String type; // asset, liability, income, expense, equity
  final double balance;
  final String currency;
  final DateTime createdAt;
  final bool isDefault;

  const Account({
    required this.id,
    required this.name,
    required this.type,
    this.balance = 0.0,
    this.currency = 'SAR',
    required this.createdAt,
    this.isDefault = false,
  });
}
