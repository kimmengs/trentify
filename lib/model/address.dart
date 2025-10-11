class Address {
  final String id;
  final String label; // e.g. "Home", "Apartment"
  final String fullName; // e.g. "Andrew Ainsley"
  final String phone; // formatted string
  final String line1; // street + city, state, zip
  final bool isMain; // show "Main Address" chip

  const Address({
    required this.id,
    required this.label,
    required this.fullName,
    required this.phone,
    required this.line1,
    this.isMain = false,
  });
}
