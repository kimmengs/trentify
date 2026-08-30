class ShopProfile {
  final String id;
  String name;
  String handle;
  String logoUrl;
  String bannerUrl;
  String bio;
  String email;
  String phone;
  String address;
  double rating;
  int reviewCount;
  int totalSales;
  int followerCount;
  String returnPolicy;
  String payoutBankName;
  String payoutAccountNumber;
  String payoutAccountHolder;

  ShopProfile({
    required this.id,
    required this.name,
    required this.handle,
    required this.logoUrl,
    required this.bannerUrl,
    required this.bio,
    required this.email,
    required this.phone,
    required this.address,
    this.rating = 4.9,
    this.reviewCount = 128,
    this.totalSales = 342,
    this.followerCount = 1840,
    required this.returnPolicy,
    required this.payoutBankName,
    required this.payoutAccountNumber,
    required this.payoutAccountHolder,
  });

  ShopProfile copyWith({
    String? name,
    String? handle,
    String? logoUrl,
    String? bannerUrl,
    String? bio,
    String? email,
    String? phone,
    String? address,
    double? rating,
    int? reviewCount,
    int? totalSales,
    int? followerCount,
    String? returnPolicy,
    String? payoutBankName,
    String? payoutAccountNumber,
    String? payoutAccountHolder,
  }) {
    return ShopProfile(
      id: id,
      name: name ?? this.name,
      handle: handle ?? this.handle,
      logoUrl: logoUrl ?? this.logoUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      bio: bio ?? this.bio,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      totalSales: totalSales ?? this.totalSales,
      followerCount: followerCount ?? this.followerCount,
      returnPolicy: returnPolicy ?? this.returnPolicy,
      payoutBankName: payoutBankName ?? this.payoutBankName,
      payoutAccountNumber: payoutAccountNumber ?? this.payoutAccountNumber,
      payoutAccountHolder: payoutAccountHolder ?? this.payoutAccountHolder,
    );
  }
}
