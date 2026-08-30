import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:trentify/l10n/app_localizations.dart';
import 'package:trentify/model/seller_product.dart';
import 'package:trentify/provider/seller_provider.dart';
import 'package:trentify/widgets/pressable_scale.dart';

class AddEditProductPage extends StatefulWidget {
  final SellerProduct? initialProduct;

  const AddEditProductPage({super.key, this.initialProduct});

  @override
  State<AddEditProductPage> createState() => _AddEditProductPageState();
}

class _AddEditProductPageState extends State<AddEditProductPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleCtl;
  late TextEditingController _descCtl;
  late TextEditingController _brandCtl;
  late TextEditingController _priceCtl;
  late TextEditingController _origPriceCtl;
  late TextEditingController _costCtl;
  late TextEditingController _stockCtl;

  String _category = 'Women';
  SellerProductStatus _status = SellerProductStatus.active;
  final List<String> _images = [];
  final List<String> _selectedSizes = [];
  final List<String> _colors = [];

  final List<String> _categories = [
    'Women',
    'Men',
    'Shoes',
    'Bags',
    'Accessories',
    'Luxury',
  ];

  final List<String> _allSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL', '30', '32', '34', 'One Size'];

  final List<String> _sampleImagePool = [
    'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=800&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1576566588028-4147f3842f27?w=800&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=800&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=800&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1556905055-8f358a7a47b2?w=800&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=800&auto=format&fit=crop&q=80',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.initialProduct;
    _titleCtl = TextEditingController(text: p?.title ?? '');
    _descCtl = TextEditingController(text: p?.description ?? '');
    _brandCtl = TextEditingController(text: p?.brand ?? 'Maison Trentify');
    _priceCtl = TextEditingController(text: p != null ? p.price.toStringAsFixed(2) : '');
    _origPriceCtl = TextEditingController(text: p?.originalPrice != null ? p!.originalPrice!.toStringAsFixed(2) : '');
    _costCtl = TextEditingController(text: p != null && p.costPrice > 0 ? p.costPrice.toStringAsFixed(2) : '');
    _stockCtl = TextEditingController(text: p != null ? p.stock.toString() : '10');

    if (p != null) {
      _category = p.category;
      _status = p.status;
      _images.addAll(p.images);
      _selectedSizes.addAll(p.sizes);
      _colors.addAll(p.colors);
    } else {
      _images.add(_sampleImagePool[0]);
      _selectedSizes.addAll(['S', 'M', 'L']);
      _colors.addAll(['Black', 'Cream']);
    }
  }

  @override
  void dispose() {
    _titleCtl.dispose();
    _descCtl.dispose();
    _brandCtl.dispose();
    _priceCtl.dispose();
    _origPriceCtl.dispose();
    _costCtl.dispose();
    _stockCtl.dispose();
    super.dispose();
  }

  void _saveProduct() {
    if (!_formKey.currentState!.validate()) return;
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least 1 product image.')),
      );
      return;
    }

    final price = double.tryParse(_priceCtl.text.trim()) ?? 0.0;
    final origPrice = double.tryParse(_origPriceCtl.text.trim());
    final cost = double.tryParse(_costCtl.text.trim()) ?? 0.0;
    final stock = int.tryParse(_stockCtl.text.trim()) ?? 0;

    final product = SellerProduct(
      id: widget.initialProduct?.id ?? 'sp_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleCtl.text.trim(),
      description: _descCtl.text.trim(),
      brand: _brandCtl.text.trim(),
      category: _category,
      price: price,
      originalPrice: origPrice,
      costPrice: cost,
      images: List.from(_images),
      sizes: List.from(_selectedSizes),
      colors: List.from(_colors),
      stock: stock,
      status: _status,
      salesCount: widget.initialProduct?.salesCount ?? 0,
      viewsCount: widget.initialProduct?.viewsCount ?? 0,
      createdAt: widget.initialProduct?.createdAt ?? DateTime.now(),
    );

    if (widget.initialProduct != null) {
      SellerProvider.instance.updateProduct(product);
    } else {
      SellerProvider.instance.addProduct(product);
    }

    HapticFeedback.mediumImpact();
    context.pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.initialProduct != null
              ? 'Product updated successfully.'
              : 'Product published to store catalog.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final cardBg = isDark ? const Color(0xFF161B22) : Colors.white;
    final borderColor = isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B);

    final isEdit = widget.initialProduct != null;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(isEdit ? context.tr('edit_product_title') : context.tr('new_product_title')),
        actions: [
          TextButton(
            onPressed: _saveProduct,
            child: Text(
              isEdit ? context.tr('save') : context.tr('publish_listing'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 60),
            children: [
              // Photos Gallery Header
              _sectionHeader('PRODUCT PHOTOS', textSecondary),
              const SizedBox(height: 10),

              SizedBox(
                height: 110,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length + 1,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    if (index == _images.length) {
                      // Add Photo Button
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          final nextImg = _sampleImagePool[_images.length % _sampleImagePool.length];
                          setState(() => _images.add(nextImg));
                        },
                        child: Container(
                          width: 100,
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: primaryColor.withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(CupertinoIcons.camera_fill, color: primaryColor, size: 28),
                              const SizedBox(height: 4),
                              Text(
                                '+ Add Photo',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final img = _images[index];
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            img,
                            width: 100,
                            height: 110,
                            fit: BoxFit.cover,
                          ),
                        ),
                        if (index == 0)
                          Positioned(
                            bottom: 6,
                            left: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Cover',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => setState(() => _images.removeAt(index)),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                CupertinoIcons.xmark,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Basic Info Card
              _sectionHeader('BASIC DETAILS', textSecondary),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _inputLabel('Product Title *', textPrimary),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _titleCtl,
                      hint: 'e.g. Oversized Silk Blend Blazer',
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
                      isDark: isDark,
                      borderColor: borderColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const SizedBox(height: 14),

                    _inputLabel('Brand / Label', textPrimary),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _brandCtl,
                      hint: 'e.g. Maison Trentify',
                      isDark: isDark,
                      borderColor: borderColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const SizedBox(height: 14),

                    _inputLabel('Category *', textPrimary),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categories.map((cat) {
                        final isSel = _category == cat;
                        return GestureDetector(
                          onTap: () => setState(() => _category = cat),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSel ? primaryColor : (isDark ? const Color(0xFF0D1117) : const Color(0xFFF1F5F9)),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSel ? primaryColor : borderColor,
                              ),
                            ),
                            child: Text(
                              cat,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isSel ? Colors.white : textSecondary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    _inputLabel('Description', textPrimary),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _descCtl,
                      hint: 'Describe materials, fit, craftsmanship, and styling tips...',
                      maxLines: 4,
                      isDark: isDark,
                      borderColor: borderColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Pricing & Inventory Card
              _sectionHeader('PRICING & INVENTORY', textSecondary),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _inputLabel('Selling Price (\$) *', textPrimary),
                              const SizedBox(height: 6),
                              _buildTextField(
                                controller: _priceCtl,
                                hint: '289.00',
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Price required' : null,
                                isDark: isDark,
                                borderColor: borderColor,
                                textPrimary: textPrimary,
                                textSecondary: textSecondary,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _inputLabel('Original Price (\$) (opt)', textPrimary),
                              const SizedBox(height: 6),
                              _buildTextField(
                                controller: _origPriceCtl,
                                hint: '349.00',
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                isDark: isDark,
                                borderColor: borderColor,
                                textPrimary: textPrimary,
                                textSecondary: textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _inputLabel('Cost per Item (\$) (private)', textPrimary),
                              const SizedBox(height: 6),
                              _buildTextField(
                                controller: _costCtl,
                                hint: '95.00',
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                isDark: isDark,
                                borderColor: borderColor,
                                textPrimary: textPrimary,
                                textSecondary: textSecondary,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _inputLabel('Total Stock *', textPrimary),
                              const SizedBox(height: 6),
                              _buildTextField(
                                controller: _stockCtl,
                                hint: '20',
                                keyboardType: TextInputType.number,
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Stock required' : null,
                                isDark: isDark,
                                borderColor: borderColor,
                                textPrimary: textPrimary,
                                textSecondary: textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Variants (Sizes & Colors)
              _sectionHeader('VARIANTS & SIZES', textSecondary),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _inputLabel('Available Sizes', textPrimary),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _allSizes.map((sz) {
                        final isSel = _selectedSizes.contains(sz);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSel) {
                                _selectedSizes.remove(sz);
                              } else {
                                _selectedSizes.add(sz);
                              }
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSel ? primaryColor : (isDark ? const Color(0xFF0D1117) : const Color(0xFFF1F5F9)),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: isSel ? primaryColor : borderColor),
                            ),
                            child: Text(
                              sz,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isSel ? Colors.white : textSecondary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    _inputLabel('Colors (${_colors.join(", ")})', textPrimary),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ..._colors.map((c) => Chip(
                              label: Text(c),
                              onDeleted: () => setState(() => _colors.remove(c)),
                            )),
                        ActionChip(
                          avatar: const Icon(Icons.add, size: 16),
                          label: const Text('Add Color'),
                          onPressed: () => _promptAddColor(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Publish Status
              _sectionHeader('PUBLISH STATUS', textSecondary),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(
                      _status == SellerProductStatus.active
                          ? CupertinoIcons.checkmark_seal_fill
                          : CupertinoIcons.eye_slash_fill,
                      color: _status == SellerProductStatus.active
                          ? const Color(0xFF10B981)
                          : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _status == SellerProductStatus.active
                                ? 'Published (Active)'
                                : 'Draft (Hidden from Store)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                          Text(
                            _status == SellerProductStatus.active
                                ? 'Visible to all customers on Trentify'
                                : 'Only visible to shop manager',
                            style: TextStyle(fontSize: 12, color: textSecondary),
                          ),
                        ],
                      ),
                    ),
                    CupertinoSwitch(
                      value: _status == SellerProductStatus.active,
                      activeTrackColor: primaryColor,
                      onChanged: (val) {
                        setState(() {
                          _status = val
                              ? SellerProductStatus.active
                              : SellerProductStatus.draft;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Bottom Submit CTA Button
              PressableScale(
                onTap: _saveProduct,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      isEdit ? 'Update Product Listing' : 'Publish Product to Store',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _promptAddColor() {
    final ctl = TextEditingController();
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Add Color Variant'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: CupertinoTextField(
            controller: ctl,
            placeholder: 'e.g. Midnight Blue, Sage Green',
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Add'),
            onPressed: () {
              if (ctl.text.trim().isNotEmpty) {
                setState(() => _colors.add(ctl.text.trim()));
              }
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, Color textSecondary) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.0,
        color: textSecondary,
      ),
    );
  }

  Widget _inputLabel(String label, Color textPrimary) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    required bool isDark,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(fontSize: 14, color: textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 13, color: textSecondary),
        filled: true,
        fillColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF1F5F9),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
        ),
      ),
    );
  }
}
