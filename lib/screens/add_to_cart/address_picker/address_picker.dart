import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:trentify/model/address.dart';
import 'package:trentify/provider/address_provider.dart';
import 'package:trentify/router/app_routes.dart';
import 'package:trentify/widgets/animated_entry.dart';
import 'package:trentify/widgets/app_badge_pill.dart';
import 'package:trentify/widgets/app_haptics.dart';
import 'package:trentify/widgets/liquid_glass_card.dart';
import 'package:trentify/widgets/pressable_scale.dart';

class AddressPickerPage extends StatefulWidget {
  const AddressPickerPage({
    super.key,
    this.addresses,
    this.initialSelectedId,
    this.isPickerMode = false,
  });

  final List<Address>? addresses;
  final String? initialSelectedId;
  final bool isPickerMode;

  @override
  State<AddressPickerPage> createState() => _AddressPickerPageState();
}

class _AddressPickerPageState extends State<AddressPickerPage> {
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    final provider = AddressProvider.instance;
    _selectedId = widget.initialSelectedId ?? provider.selectedAddressId;
  }

  Future<void> _addNewAddress(BuildContext context) async {
    AppHaptics.light();
    final created = await context.push<Address>(AppRoutes.addressForm);
    if (created != null && context.mounted) {
      context.read<AddressProvider>().addAddress(created);
      setState(() => _selectedId = created.id);
    }
  }

  Future<void> _editAddress(BuildContext context, Address address) async {
    AppHaptics.light();
    final updated = await context.push<Address>(
      AppRoutes.addressForm,
      extra: address,
    );
    if (updated != null && context.mounted) {
      context.read<AddressProvider>().updateAddress(updated);
    }
  }

  void _confirmDelete(BuildContext context, Address address) {
    AppHaptics.medium();
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Delete Address'),
        content: Text('Are you sure you want to remove "${address.label}" from your delivery addresses?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AddressProvider>().deleteAddress(address.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B);

    final addressProvider = context.watch<AddressProvider>();
    final addresses = addressProvider.addresses;

    final isPicker = widget.isPickerMode;

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
          isPicker ? 'Select Delivery Address' : 'Shipping Addresses',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(CupertinoIcons.plus_circle_fill, color: primaryColor, size: 22),
            onPressed: () => _addNewAddress(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: addresses.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.location_slash_fill,
                      size: 56,
                      color: textSecondary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'No Delivery Addresses Saved',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Add your first shipping address for fast checkout.',
                      style: TextStyle(fontSize: 13, color: textSecondary),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _addNewAddress(context),
                      icon: const Icon(CupertinoIcons.plus),
                      label: const Text('Add New Address'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 120),
                itemCount: addresses.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final a = addresses[i];
                  final isSelected = a.id == _selectedId;

                  return AnimatedEntry(
                    delay: Duration(milliseconds: 30 * i),
                    child: _LuxuryAddressCard(
                      address: a,
                      isSelected: isSelected,
                      isPickerMode: isPicker,
                      isDark: isDark,
                      primaryColor: primaryColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      onTap: () {
                        AppHaptics.selection();
                        setState(() => _selectedId = a.id);
                        if (isPicker) {
                          addressProvider.selectAddress(a.id);
                        }
                      },
                      onSetDefault: () {
                        AppHaptics.medium();
                        addressProvider.setPrimary(a.id);
                      },
                      onEdit: () => _editAddress(context, a),
                      onDelete: () => _confirmDelete(context, a),
                    ),
                  );
                },
              ),
      ),
      bottomNavigationBar: isPicker && addresses.isNotEmpty
          ? SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
                child: PressableScale(
                  onTap: () {
                    AppHaptics.medium();
                    final chosen = addresses.firstWhere(
                      (e) => e.id == _selectedId,
                      orElse: () => addresses.first,
                    );
                    addressProvider.selectAddress(chosen.id);
                    Navigator.pop(context, chosen);
                  },
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
                    child: const Center(
                      child: Text(
                        'Deliver To This Address',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

class _LuxuryAddressCard extends StatelessWidget {
  final Address address;
  final bool isSelected;
  final bool isPickerMode;
  final bool isDark;
  final Color primaryColor;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onTap;
  final VoidCallback onSetDefault;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _LuxuryAddressCard({
    required this.address,
    required this.isSelected,
    required this.isPickerMode,
    required this.isDark,
    required this.primaryColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.onTap,
    required this.onSetDefault,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected
        ? primaryColor
        : (isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0));

    return PressableScale(
      onTap: onTap,
      child: LiquidGlassCard(
        borderColor: borderColor,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Location Icon + Label + Main Badge + Action Icons
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: address.isMain
                        ? primaryColor.withValues(alpha: 0.15)
                        : (isDark ? const Color(0xFF1E2633) : const Color(0xFFF1F5F9)),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.location_solid,
                    size: 18,
                    color: address.isMain ? primaryColor : textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  address.label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                if (address.isMain)
                  const AppBadgePill(
                    label: 'DEFAULT',
                    variant: BadgeVariant.vip,
                    fontSize: 9,
                  ),
                const Spacer(),
                if (isPickerMode)
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? primaryColor : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? primaryColor : (isDark ? const Color(0xFF484F58) : const Color(0xFFCBD5E1)),
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(CupertinoIcons.checkmark, size: 13, color: Colors.white)
                        : null,
                  )
                else ...[
                  IconButton(
                    icon: Icon(CupertinoIcons.pencil, size: 18, color: primaryColor),
                    onPressed: onEdit,
                    tooltip: 'Edit Address',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(CupertinoIcons.trash, size: 18, color: Color(0xFFEF4444)),
                    onPressed: onDelete,
                    tooltip: 'Delete Address',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 12),
            Divider(height: 1, color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0)),
            const SizedBox(height: 12),

            // Recipient & Phone
            Row(
              children: [
                Icon(CupertinoIcons.person, size: 14, color: textSecondary),
                const SizedBox(width: 6),
                Text(
                  address.fullName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '•  ${address.phone}',
                  style: TextStyle(
                    fontSize: 13,
                    color: textSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Street & Location
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(CupertinoIcons.map_pin, size: 14, color: textSecondary),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    address.line1,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                    ),
                  ),
                ),
              ],
            ),

            if (!address.isMain && !isPickerMode) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: onSetDefault,
                child: Row(
                  children: [
                    Icon(CupertinoIcons.star, size: 14, color: primaryColor),
                    const SizedBox(width: 6),
                    Text(
                      'Set as Default Delivery Address',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
