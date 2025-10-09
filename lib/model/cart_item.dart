import 'dart:ui';

class CartItem {
  final String id;
  final String title;
  final double price;
  final List<String> sizes;
  final List<Color> colors;

  int qty;
  String selectedSize;
  Color selectedColor;

  CartItem({
    required this.id,
    required this.title,
    required this.price,
    required this.sizes,
    required this.colors,
    required this.qty,
    required this.selectedSize,
    required this.selectedColor,
  });

  CartItem copyWith({int? qty, String? selectedSize, Color? selectedColor}) =>
      CartItem(
        id: id,
        title: title,
        price: price,
        sizes: sizes,
        colors: colors,
        qty: qty ?? this.qty,
        selectedSize: selectedSize ?? this.selectedSize,
        selectedColor: selectedColor ?? this.selectedColor,
      );
}
