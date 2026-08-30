import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trentify/widgets/animated_entry.dart';
import 'package:trentify/widgets/app_badge_pill.dart';
import 'package:trentify/widgets/app_haptics.dart';
import 'package:trentify/widgets/app_network_image.dart';
import 'package:trentify/widgets/liquid_glass_card.dart';
import 'package:trentify/widgets/pressable_scale.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  String _gender = 'Male';
  String _avatarUrl = 'https://i.pravatar.cc/150?img=12';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Alex Rivera');
    _usernameController = TextEditingController(text: 'alex_rivera');
    _emailController = TextEditingController(text: 'alex.rivera@example.com');
    _phoneController = TextEditingController(text: '+1 (555) 234-5678');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleChangeAvatar() {
    AppHaptics.light();

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: const Text('Change Profile Photo'),
        message: const Text('Select a new photo for your VIP account'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _avatarUrl = 'https://i.pravatar.cc/150?img=33';
              });
              AppHaptics.success();
            },
            child: const Text('Take Photo with Camera'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _avatarUrl = 'https://i.pravatar.cc/150?img=68';
              });
              AppHaptics.success();
            },
            child: const Text('Choose from Photo Library'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      AppHaptics.error();
      return;
    }

    AppHaptics.medium();
    setState(() => _isSaving = true);

    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    setState(() => _isSaving = false);

    AppHaptics.success();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            Icon(CupertinoIcons.checkmark_circle_fill, color: Color(0xFF10B981), size: 20),
            SizedBox(width: 8),
            Text('Profile updated successfully!'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B);
    final inputBg = isDark ? const Color(0xFF161B22) : const Color(0xFFF1F5F9);
    final borderColor = isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090D14) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF090D14) : const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: textPrimary),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: textPrimary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: PressableScale(
              onTap: _isSaving ? null : _handleSave,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 40),
          children: [
            // 1. Avatar Card with Camera Badge
            AnimatedEntry(
              delay: const Duration(milliseconds: 40),
              child: Center(
                child: Stack(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: primaryColor,
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: AppNetworkImage(
                        imageUrl: _avatarUrl,
                        width: 96,
                        height: 96,
                        borderRadius: 48,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: _handleChangeAvatar,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                primaryColor,
                                primaryColor.withValues(alpha: 0.8),
                              ],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark ? const Color(0xFF090D14) : Colors.white,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: const Icon(
                            CupertinoIcons.camera_fill,
                            size: 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            Center(
              child: TextButton(
                onPressed: _handleChangeAvatar,
                child: Text(
                  'Change Photo',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 2. VIP Member Info Pill Card
            AnimatedEntry(
              delay: const Duration(milliseconds: 80),
              child: LiquidGlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                borderRadius: 18,
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryColor, const Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        CupertinoIcons.sparkles,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'VIP Elite Tier',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const AppBadgePill(
                                label: 'VERIFIED',
                                variant: BadgeVariant.success,
                                fontSize: 9,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Member ID: #VIP-8892 • 20% discount unlocked',
                            style: TextStyle(fontSize: 11, color: textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 3. Profile Information Form Card
            AnimatedEntry(
              delay: const Duration(milliseconds: 120),
              child: LiquidGlassCard(
                borderRadius: 22,
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PERSONAL INFORMATION',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Full Name
                    _ProfileTextField(
                      label: 'Full Name',
                      controller: _nameController,
                      icon: CupertinoIcons.person,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      inputBg: inputBg,
                      borderColor: borderColor,
                      validator: (val) =>
                          (val == null || val.trim().isEmpty) ? 'Please enter your name' : null,
                    ),

                    const SizedBox(height: 14),

                    // Username
                    _ProfileTextField(
                      label: 'Username',
                      controller: _usernameController,
                      icon: CupertinoIcons.at,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      inputBg: inputBg,
                      borderColor: borderColor,
                      validator: (val) => (val == null || val.trim().isEmpty)
                          ? 'Please enter a username'
                          : null,
                    ),

                    const SizedBox(height: 14),

                    // Email Address
                    _ProfileTextField(
                      label: 'Email Address',
                      controller: _emailController,
                      icon: CupertinoIcons.mail,
                      keyboardType: TextInputType.emailAddress,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      inputBg: inputBg,
                      borderColor: borderColor,
                      validator: (val) =>
                          (val == null || !val.contains('@')) ? 'Please enter a valid email' : null,
                    ),

                    const SizedBox(height: 14),

                    // Phone Number
                    _ProfileTextField(
                      label: 'Phone Number',
                      controller: _phoneController,
                      icon: CupertinoIcons.phone,
                      keyboardType: TextInputType.phone,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      inputBg: inputBg,
                      borderColor: borderColor,
                    ),

                    const SizedBox(height: 16),

                    // Gender Selector
                    Text(
                      'Gender',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: ['Male', 'Female', 'Other'].map((g) {
                        final isSelected = _gender == g;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              AppHaptics.selection();
                              setState(() => _gender = g);
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? primaryColor
                                    : (isDark ? const Color(0xFF21262D) : const Color(0xFFF1F5F9)),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? primaryColor : borderColor,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  g,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : (isDark ? Colors.white : const Color(0xFF0F172A)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType keyboardType;
  final Color textPrimary;
  final Color textSecondary;
  final Color inputBg;
  final Color borderColor;
  final String? Function(String?)? validator;

  const _ProfileTextField({
    required this.label,
    required this.controller,
    required this.icon,
    this.keyboardType = TextInputType.text,
    required this.textPrimary,
    required this.textSecondary,
    required this.inputBg,
    required this.borderColor,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: inputBg,
            prefixIcon: Icon(icon, size: 18, color: textSecondary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}
