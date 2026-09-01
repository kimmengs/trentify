import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trentify/widgets/app_haptics.dart';
import 'package:trentify/widgets/liquid_glass_card.dart';
import 'package:trentify/widgets/pressable_scale.dart';

class SizingGuideSheet extends StatefulWidget {
  final String productTitle;
  const SizingGuideSheet({super.key, required this.productTitle});

  static Future<void> show(BuildContext context, {required String productTitle}) {
    AppHaptics.light();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SizingGuideSheet(productTitle: productTitle),
    );
  }

  @override
  State<SizingGuideSheet> createState() => _SizingGuideSheetState();
}

class _SizingGuideSheetState extends State<SizingGuideSheet> {
  bool _isCm = true;
  int _selectedFit = 1; // 0: Slim, 1: Regular, 2: Oversized
  double _userHeight = 178; // cm
  double _userWeight = 72; // kg

  String get _recommendedSize {
    if (_userHeight < 165 || _userWeight < 55) return _selectedFit == 0 ? 'XS' : 'S';
    if (_userHeight < 174 || _userWeight < 68) return _selectedFit == 0 ? 'S' : 'M';
    if (_userHeight < 182 || _userWeight < 80) return _selectedFit == 0 ? 'M' : 'L';
    if (_userHeight < 190 || _userWeight < 92) return _selectedFit == 0 ? 'L' : 'XL';
    return 'XXL';
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

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF090D14).withValues(alpha: 0.94)
                : const Color(0xFFF8FAFC).withValues(alpha: 0.94),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.8),
            ),
          ),
          child: Column(
            children: [
              // Drag Handle
              const SizedBox(height: 12),
              Container(
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF30363D) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 14),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sizing & Fit Guide',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.productTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: textSecondary),
                        ),
                      ],
                    ),
                    // Unit Switcher
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF161B22) : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          _UnitPill(
                            label: 'CM',
                            selected: _isCm,
                            onTap: () => setState(() => _isCm = true),
                            primaryColor: primaryColor,
                          ),
                          _UnitPill(
                            label: 'INCH',
                            selected: !_isCm,
                            onTap: () => setState(() => _isCm = false),
                            primaryColor: primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),
              Divider(height: 1, color: borderColor),

              // Scrollable Content
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  children: [
                    // Smart Fit AI Recommender Card
                    LiquidGlassCard(
                      borderColor: primaryColor.withValues(alpha: 0.35),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [primaryColor, primaryColor.withValues(alpha: 0.7)],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(CupertinoIcons.sparkles, size: 16, color: Colors.white),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Smart Fit Recommender',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: textPrimary,
                                      ),
                                    ),
                                    Text(
                                      'Personalized fit based on your body profile',
                                      style: TextStyle(fontSize: 11, color: textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withValues(alpha: 0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  'Size $_recommendedSize',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Height Slider
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Height', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textSecondary)),
                              Text('${_userHeight.toInt()} cm', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: primaryColor)),
                            ],
                          ),
                          SliderTheme(
                            data: SliderThemeData(
                              activeTrackColor: primaryColor,
                              thumbColor: primaryColor,
                              inactiveTrackColor: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0),
                              trackHeight: 3,
                            ),
                            child: Slider(
                              value: _userHeight,
                              min: 150,
                              max: 205,
                              onChanged: (v) {
                                AppHaptics.selection();
                                setState(() => _userHeight = v);
                              },
                            ),
                          ),

                          // Weight Slider
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Weight', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textSecondary)),
                              Text('${_userWeight.toInt()} kg', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: primaryColor)),
                            ],
                          ),
                          SliderTheme(
                            data: SliderThemeData(
                              activeTrackColor: primaryColor,
                              thumbColor: primaryColor,
                              inactiveTrackColor: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0),
                              trackHeight: 3,
                            ),
                            child: Slider(
                              value: _userWeight,
                              min: 45,
                              max: 120,
                              onChanged: (v) {
                                AppHaptics.selection();
                                setState(() => _userWeight = v);
                              },
                            ),
                          ),

                          const SizedBox(height: 6),

                          // Fit Preference Selector
                          Text('Fit Preference', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textSecondary)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _FitOption(label: 'Slim Fit', index: 0, selected: _selectedFit == 0, onTap: () => setState(() => _selectedFit = 0), primaryColor: primaryColor, isDark: isDark),
                              const SizedBox(width: 8),
                              _FitOption(label: 'Regular Fit', index: 1, selected: _selectedFit == 1, onTap: () => setState(() => _selectedFit = 1), primaryColor: primaryColor, isDark: isDark),
                              const SizedBox(width: 8),
                              _FitOption(label: 'Oversized', index: 2, selected: _selectedFit == 2, onTap: () => setState(() => _selectedFit = 2), primaryColor: primaryColor, isDark: isDark),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Garment Dimensions Table
                    Text(
                      'Garment Measurements (${_isCm ? 'cm' : 'inches'})',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      decoration: BoxDecoration(
                        color: bgCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Table(
                        border: TableBorder.symmetric(
                          inside: BorderSide(color: borderColor, width: 0.6),
                        ),
                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                        children: [
                          _buildTableRow(['Size', 'Chest', 'Waist', 'Length', 'Shoulder'], isHeader: true, textPrimary: textPrimary, textSecondary: textSecondary),
                          _buildTableRow(['XS', _formatVal(92), _formatVal(80), _formatVal(68), _formatVal(42)], isSelected: _recommendedSize == 'XS', textPrimary: textPrimary, primaryColor: primaryColor),
                          _buildTableRow(['S', _formatVal(96), _formatVal(84), _formatVal(70), _formatVal(44)], isSelected: _recommendedSize == 'S', textPrimary: textPrimary, primaryColor: primaryColor),
                          _buildTableRow(['M', _formatVal(102), _formatVal(90), _formatVal(72), _formatVal(46)], isSelected: _recommendedSize == 'M', textPrimary: textPrimary, primaryColor: primaryColor),
                          _buildTableRow(['L', _formatVal(108), _formatVal(96), _formatVal(74), _formatVal(48)], isSelected: _recommendedSize == 'L', textPrimary: textPrimary, primaryColor: primaryColor),
                          _buildTableRow(['XL', _formatVal(114), _formatVal(102), _formatVal(76), _formatVal(50)], isSelected: _recommendedSize == 'XL', textPrimary: textPrimary, primaryColor: primaryColor),
                          _buildTableRow(['XXL', _formatVal(120), _formatVal(108), _formatVal(78), _formatVal(52)], isSelected: _recommendedSize == 'XXL', textPrimary: textPrimary, primaryColor: primaryColor),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // How to Measure Tips
                    Text(
                      'How to Measure',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _MeasureTip(icon: CupertinoIcons.arrow_left_right, title: 'Chest', desc: 'Measure around the fullest part of your chest, keeping tape horizontal.', textPrimary: textPrimary, textSecondary: textSecondary),
                    const SizedBox(height: 8),
                    _MeasureTip(icon: CupertinoIcons.circle, title: 'Waist', desc: 'Measure around your natural waistline, where your trousers usually sit.', textPrimary: textPrimary, textSecondary: textSecondary),
                    const SizedBox(height: 8),
                    _MeasureTip(icon: CupertinoIcons.arrow_up_down, title: 'Length', desc: 'Measure from highest point of the shoulder seam to bottom hem.', textPrimary: textPrimary, textSecondary: textSecondary),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatVal(double cmVal) {
    if (_isCm) return cmVal.toStringAsFixed(0);
    return (cmVal / 2.54).toStringAsFixed(1);
  }

  TableRow _buildTableRow(
    List<String> cells, {
    bool isHeader = false,
    bool isSelected = false,
    required Color textPrimary,
    Color? textSecondary,
    Color? primaryColor,
  }) {
    return TableRow(
      decoration: BoxDecoration(
        color: isSelected
            ? primaryColor?.withValues(alpha: 0.12)
            : (isHeader ? textPrimary.withValues(alpha: 0.04) : Colors.transparent),
      ),
      children: cells.map((cell) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Text(
            cell,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isHeader ? 12 : 13,
              fontWeight: isHeader ? FontWeight.w800 : (isSelected ? FontWeight.w800 : FontWeight.w500),
              color: isSelected ? (primaryColor ?? textPrimary) : (isHeader ? textSecondary : textPrimary),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _UnitPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color primaryColor;

  const _UnitPill({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppHaptics.selection();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: selected ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }
}

class _FitOption extends StatelessWidget {
  final String label;
  final int index;
  final bool selected;
  final VoidCallback onTap;
  final Color primaryColor;
  final bool isDark;

  const _FitOption({
    required this.label,
    required this.index,
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
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? primaryColor : (isDark ? const Color(0xFF161B22) : Colors.white),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? primaryColor : (isDark ? const Color(0xFF30363D) : const Color(0xFFCBD5E1)),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
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

class _MeasureTip extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final Color textPrimary;
  final Color textSecondary;

  const _MeasureTip({
    required this.icon,
    required this.title,
    required this.desc,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: textSecondary),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: '$title: ',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textPrimary),
              children: [
                TextSpan(
                  text: desc,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: textSecondary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
