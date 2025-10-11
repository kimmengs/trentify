enum PaymentKind { wallet, card }

class PaymentMethod {
  final String id;
  final PaymentKind kind;
  final String name; // e.g. "PayPal", "Mastercard"
  final String? last4; // for cards
  final String? brand; // "Mastercard" | "Visa" | "AmEx"
  final String? asset; // optional logo asset path

  const PaymentMethod({
    required this.id,
    required this.kind,
    required this.name,
    this.last4,
    this.brand,
    this.asset,
  });
}
