class BankInfo {
  final String code;
  final String name;
  final String logoAsset; // <- use local asset (recommended for speed)
  const BankInfo(this.code, this.name, this.logoAsset);
}
