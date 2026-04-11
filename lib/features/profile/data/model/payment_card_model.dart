// ─────────────────────────────────────────────
// PAYMENT CARD MODEL
// ─────────────────────────────────────────────

class PaymentCardModel {
  final String id;
  final String type; // 'VISA' | 'MC' | 'AMEX' | 'RuPay'
  final String lastFour;
  final String holderName;
  final String expiry;
  final bool isPrimary;

  const PaymentCardModel({
    required this.id,
    required this.type,
    required this.lastFour,
    required this.holderName,
    required this.expiry,
    this.isPrimary = false,
  });

  PaymentCardModel copyWith({
    String? id,
    String? type,
    String? lastFour,
    String? holderName,
    String? expiry,
    bool? isPrimary,
  }) {
    return PaymentCardModel(
      id: id ?? this.id,
      type: type ?? this.type,
      lastFour: lastFour ?? this.lastFour,
      holderName: holderName ?? this.holderName,
      expiry: expiry ?? this.expiry,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }

  factory PaymentCardModel.fromJson(Map<String, dynamic> json) => PaymentCardModel(
    id: json['id'] as String? ?? '',
    type: json['type'] as String? ?? 'VISA',
    lastFour: json['lastFour'] as String? ?? '',
    holderName: json['holderName'] as String? ?? '',
    expiry: json['expiry'] as String? ?? '',
    isPrimary: json['primaryMethod'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'lastFour': lastFour,
    'holderName': holderName,
    'expiry': expiry,
    'primaryMethod': isPrimary,
  };
}
