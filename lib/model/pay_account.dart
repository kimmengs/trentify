class PayAccount {
  final String id;
  final String label; // e.g., "Main Wallet"
  final String masked; // e.g., "••• 1234"
  final double balance; // optional
  final String currency; // e.g., 'USD'
  const PayAccount(
    this.id,
    this.label,
    this.masked,
    this.balance,
    this.currency,
  );
}
