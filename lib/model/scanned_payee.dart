// models/scanned_payee.dart
class ScannedPayee {
  final String name;
  final String email;
  final String? avatarUrl;
  ScannedPayee({required this.name, required this.email, this.avatarUrl});
}
