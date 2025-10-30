class Wallet {
  final String id;
  String name;
  String type; // 'cash', 'debit', 'credit', ...
  double balance;

  Wallet({
    required this.id,
    required this.name,
    required this.type,
    this.balance = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'balance': balance,
      };

  factory Wallet.fromJson(Map<String, dynamic> j) => Wallet(
        id: j['id'] as String,
        name: j['name'] as String,
        type: j['type'] as String,
        balance: (j['balance'] as num).toDouble(),
      );
}