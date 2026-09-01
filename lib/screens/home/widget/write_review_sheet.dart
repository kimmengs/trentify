import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trentify/screens/home/product_detail.dart';
import 'package:trentify/widgets/app_haptics.dart';
import 'package:trentify/widgets/pressable_scale.dart';

class WriteReviewSheet extends StatefulWidget {
  final String productTitle;
  final ValueChanged<ReviewData>? onReviewSubmitted;

  const WriteReviewSheet({
    super.key,
    required this.productTitle,
    this.onReviewSubmitted,
  });

  static Future<void> show(
    BuildContext context, {
    required String productTitle,
    ValueChanged<ReviewData>? onReviewSubmitted,
  }) {
    AppHaptics.light();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WriteReviewSheet(
        productTitle: productTitle,
        onReviewSubmitted: onReviewSubmitted,
      ),
    );
  }

  @override
  State<WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends State<WriteReviewSheet> {
  final TextEditingController _reviewCtl = TextEditingController();
  double _rating = 5.0;
  int _selectedFit = 1; // 0: Runs Small, 1: True to Size, 2: Runs Large
  final List<String> _attachedPhotos = [];
  bool _isSubmitting = false;

  final List<String> _demoPhotoUrls = [
    'https://images.unsplash.com/photo-1544441893-675973e31985?w=400&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=400&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1576566588028-4147f3842f27?w=400&auto=format&fit=crop&q=80',
  ];

  @override
  void dispose() {
    _reviewCtl.dispose();
    super.dispose();
  }

  void _addPhoto() {
    AppHaptics.light();
    if (_attachedPhotos.length < _demoPhotoUrls.length) {
      setState(() {
        _attachedPhotos.add(_demoPhotoUrls[_attachedPhotos.length]);
      });
    }
  }

  void _submitReview() async {
    if (_reviewCtl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Please write a few words about your experience'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    AppHaptics.heavy();

    await Future.delayed(const Duration(milliseconds: 1200));

    final review = ReviewData(
      author: 'Alex Rivera (Verified Buyer)',
      ago: 'Just now',
      stars: _rating,
      variant: 'L, Black • ${_selectedFit == 0 ? "Runs Small" : _selectedFit == 1 ? "True to Size" : "Runs Large"}',
      text: _reviewCtl.text.trim(),
      photos: List.from(_attachedPhotos),
    );

    widget.onReviewSubmitted?.call(review);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          backgroundColor: const Color(0xFF10B981),
          content: Row(
            children: const [
              Icon(CupertinoIcons.checkmark_seal_fill, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Review published! Earned +50 VIP Reward Points ⭐',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B);
    final bgCard = isDark ? const Color(0xFF161B22) : Colors.white;
    final borderColor = isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF090D14).withValues(alpha: 0.95)
                  : const Color(0xFFF8FAFC).withValues(alpha: 0.95),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.8),
              ),
            ),
            child: ListView(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 44,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF30363D) : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rate & Review',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: Icon(CupertinoIcons.xmark, size: 18, color: textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Text(
                  widget.productTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: textSecondary),
                ),

                const SizedBox(height: 20),

                // Interactive Star Rating Bar
                Center(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          final starVal = index + 1.0;
                          final isFilled = _rating >= starVal;
                          return GestureDetector(
                            onTap: () {
                              AppHaptics.selection();
                              setState(() => _rating = starVal);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Icon(
                                isFilled ? CupertinoIcons.star_fill : CupertinoIcons.star,
                                size: 36,
                                color: isFilled ? const Color(0xFFF59E0B) : (isDark ? const Color(0xFF30363D) : const Color(0xFFCBD5E1)),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _rating == 5.0
                            ? 'Excellent Quality & Style'
                            : _rating == 4.0
                                ? 'Very Good Fit'
                                : _rating == 3.0
                                    ? 'Average Experience'
                                    : 'Needs Improvement',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Fit Rating Selector
                Text(
                  'How did it fit?',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPrimary),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _FitChip(
                      label: 'Runs Small',
                      selected: _selectedFit == 0,
                      onTap: () => setState(() => _selectedFit = 0),
                      primaryColor: primaryColor,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _FitChip(
                      label: 'True to Size',
                      selected: _selectedFit == 1,
                      onTap: () => setState(() => _selectedFit = 1),
                      primaryColor: primaryColor,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _FitChip(
                      label: 'Runs Large',
                      selected: _selectedFit == 2,
                      onTap: () => setState(() => _selectedFit = 2),
                      primaryColor: primaryColor,
                      isDark: isDark,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Written Feedback Input
                Text(
                  'Your Experience',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPrimary),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: TextField(
                    controller: _reviewCtl,
                    maxLines: 4,
                    style: TextStyle(fontSize: 14, color: textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Describe the drape, luxury feel, fabric comfort, and styling tips...',
                      hintStyle: TextStyle(fontSize: 13, color: textSecondary),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Attach Photos
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Attach Photos (${_attachedPhotos.length}/3)',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPrimary),
                    ),
                    if (_attachedPhotos.length < _demoPhotoUrls.length)
                      GestureDetector(
                        onTap: _addPhoto,
                        child: Text(
                          '+ Add Demo Photo',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: primaryColor),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    ..._attachedPhotos.map((url) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(url, width: 68, height: 68, fit: BoxFit.cover),
                            ),
                            Positioned(
                              top: 2,
                              right: 2,
                              child: GestureDetector(
                                onTap: () {
                                  AppHaptics.light();
                                  setState(() => _attachedPhotos.remove(url));
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(CupertinoIcons.xmark, size: 12, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    if (_attachedPhotos.length < 3)
                      GestureDetector(
                        onTap: _addPhoto,
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: bgCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor, style: BorderStyle.solid),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(CupertinoIcons.camera_fill, size: 20, color: textSecondary),
                              const SizedBox(height: 2),
                              Text('Photo', style: TextStyle(fontSize: 10, color: textSecondary)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 28),

                // Submit Button
                PressableScale(
                  onTap: _isSubmitting ? () {} : _submitReview,
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, primaryColor.withValues(alpha: 0.85)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _isSubmitting
                          ? const CupertinoActivityIndicator(color: Colors.white)
                          : const Text(
                              'Submit Review & Earn 50 Pts',
                              style: TextStyle(
                                fontSize: 15,
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
      ),
    );
  }
}

class _FitChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color primaryColor;
  final bool isDark;

  const _FitChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.primaryColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: PressableScale(
        onTap: () {
          AppHaptics.selection();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: selected ? primaryColor : (isDark ? const Color(0xFF161B22) : Colors.white),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? primaryColor : (isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0)),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
