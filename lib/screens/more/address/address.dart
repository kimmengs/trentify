import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trentify/model/address.dart';
import 'package:trentify/widgets/app_haptics.dart';
import 'package:trentify/widgets/pressable_scale.dart';

class AddressFormPage extends StatefulWidget {
  const AddressFormPage({super.key, this.initial});
  final Address? initial;

  @override
  State<AddressFormPage> createState() => _AddressFormPageState();
}

class _AddressFormPageState extends State<AddressFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _labelCtl;
  late final TextEditingController _nameCtl;
  late final TextEditingController _phoneCtl;
  late final TextEditingController _line1Ctl;
  late final TextEditingController _noteCtl;
  bool _isPrimary = false;

  final _quickLabels = ['Home', 'Office', 'Apartment', 'Villa', 'Studio'];

  @override
  void initState() {
    super.initState();
    final a = widget.initial;
    _labelCtl = TextEditingController(text: a?.label ?? 'Home');
    _nameCtl = TextEditingController(text: a?.fullName ?? 'Alex Rivera');
    _phoneCtl = TextEditingController(text: a?.phone ?? '+1 (555) 234-5678');
    _line1Ctl = TextEditingController(text: a?.line1 ?? '');
    _noteCtl = TextEditingController();
    _isPrimary = a?.isMain ?? false;
  }

  @override
  void dispose() {
    _labelCtl.dispose();
    _nameCtl.dispose();
    _phoneCtl.dispose();
    _line1Ctl.dispose();
    _noteCtl.dispose();
    super.dispose();
  }

  void _onSave() {
    AppHaptics.medium();
    if (!_validate()) return;

    final id = widget.initial?.id ?? 'addr_${DateTime.now().millisecondsSinceEpoch}';
    final addr = Address(
      id: id,
      label: _labelCtl.text.trim().isEmpty ? 'Home' : _labelCtl.text.trim(),
      fullName: _nameCtl.text.trim(),
      phone: _phoneCtl.text.trim(),
      line1: _line1Ctl.text.trim(),
      isMain: _isPrimary,
    );

    Navigator.pop(context, addr);
  }

  bool _validate() {
    if (_nameCtl.text.trim().isEmpty) return _showError('Recipient name is required');
    if (_phoneCtl.text.trim().isEmpty) return _showError('Phone number is required');
    if (_line1Ctl.text.trim().isEmpty) return _showError('Street address is required');
    return true;
  }

  bool _showError(String msg) {
    AppHaptics.error();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(CupertinoIcons.exclamationmark_circle_fill, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text(msg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B);
    final cardBg = isDark ? const Color(0xFF161B22) : Colors.white;
    final borderColor = isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0);

    final isEditing = widget.initial != null;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090D14) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF090D14) : const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Edit Address' : 'New Address',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _onSave,
            child: Text(
              'Save',
              style: TextStyle(
                fontSize: 15,
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
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
            children: [
              // Address Category Label Chips
              _SectionHeader(label: 'ADDRESS LABEL', textSecondary: textSecondary),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _quickLabels.map((label) {
                  final isSelected = _labelCtl.text.trim().toLowerCase() == label.toLowerCase();
                  return GestureDetector(
                    onTap: () {
                      AppHaptics.selection();
                      setState(() => _labelCtl.text = label);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? primaryColor.withValues(alpha: isDark ? 0.25 : 0.12)
                            : (isDark ? const Color(0xFF1E2633) : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? primaryColor : borderColor,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? primaryColor : textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Contact Details Group
              _SectionHeader(label: 'CONTACT DETAILS', textSecondary: textSecondary),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: Column(
                  children: [
                    _LuxuryFormField(
                      controller: _nameCtl,
                      label: "Recipient's Name",
                      hint: 'e.g. Alex Rivera',
                      icon: CupertinoIcons.person_fill,
                      isDark: isDark,
                      primaryColor: primaryColor,
                      textPrimary: textPrimary,
                    ),
                    Divider(height: 1, color: borderColor),
                    _LuxuryFormField(
                      controller: _phoneCtl,
                      label: 'Phone Number',
                      hint: '+1 (555) 000-0000',
                      icon: CupertinoIcons.phone_fill,
                      keyboardType: TextInputType.phone,
                      isDark: isDark,
                      primaryColor: primaryColor,
                      textPrimary: textPrimary,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Delivery Address Group
              _SectionHeader(label: 'DELIVERY LOCATION', textSecondary: textSecondary),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: Column(
                  children: [
                    _LuxuryFormField(
                      controller: _line1Ctl,
                      label: 'Street Address & Postal Code',
                      hint: '742 Evergreen Terrace, Beverly Hills, CA 90210',
                      icon: CupertinoIcons.location_solid,
                      maxLines: 2,
                      isDark: isDark,
                      primaryColor: primaryColor,
                      textPrimary: textPrimary,
                    ),
                    Divider(height: 1, color: borderColor),
                    _LuxuryFormField(
                      controller: _noteCtl,
                      label: 'Note to Courier (Optional)',
                      hint: 'e.g. Leave package with front desk / gate code #1234',
                      icon: CupertinoIcons.doc_text_fill,
                      isDark: isDark,
                      primaryColor: primaryColor,
                      textPrimary: textPrimary,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Primary Address Switch
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        CupertinoIcons.star_fill,
                        color: Color(0xFFF59E0B),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Set As Default Address',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Used automatically for 1-Tap checkout',
                            style: TextStyle(
                              fontSize: 12,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CupertinoSwitch(
                      value: _isPrimary,
                      activeTrackColor: primaryColor,
                      onChanged: (val) {
                        AppHaptics.selection();
                        setState(() => _isPrimary = val);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Save Button
              PressableScale(
                onTap: _onSave,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, primaryColor.withValues(alpha: 0.85)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      isEditing ? 'Save Changes' : 'Save Delivery Address',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.2,
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
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final Color textSecondary;
  const _SectionHeader({required this.label, required this.textSecondary});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        color: textSecondary,
      ),
    );
  }
}

class _LuxuryFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool isDark;
  final Color primaryColor;
  final Color textPrimary;

  const _LuxuryFormField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
    required this.isDark,
    required this.primaryColor,
    required this.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: maxLines > 1 ? 4 : 0),
            child: Icon(icon, size: 18, color: primaryColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 2),
                TextFormField(
                  controller: controller,
                  keyboardType: keyboardType,
                  maxLines: maxLines,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: hint,
                    hintStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: isDark ? const Color(0xFF484F58) : const Color(0xFF94A3B8),
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
