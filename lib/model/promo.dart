enum PromoType { percent, cashback, flat }

class Promo {
  final String id;
  final String title; // e.g. "Best Deal: 20% OFF"
  final String code; // e.g. "20DEALS"
  final PromoType type;
  final double value; // 20 (%), 12 (%), 10 (cashback), etc.
  final double minSpend; // minimum order value to apply
  final DateTime validUntil;

  const Promo({
    required this.id,
    required this.title,
    required this.code,
    required this.type,
    required this.value,
    required this.minSpend,
    required this.validUntil,
  });
}
