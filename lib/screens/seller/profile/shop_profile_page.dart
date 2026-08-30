import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:trentify/l10n/app_localizations.dart';
import 'package:trentify/provider/seller_provider.dart';
import 'package:trentify/router/app_routes.dart';
import 'package:trentify/widgets/animated_entry.dart';
import 'package:trentify/widgets/pressable_scale.dart';

class ShopProfilePage extends StatefulWidget {
  const ShopProfilePage({super.key});

  @override
  State<ShopProfilePage> createState() => _ShopProfilePageState();
}

class _ShopProfilePageState extends State<ShopProfilePage> {
  final _seller = SellerProvider.instance;
  int _selectedTab = 0; // 0: Branding & Info, 1: Payout & Bank, 2: Dispatch & Policies
  bool _isStoreOnline = true;
  bool _saving = false;

  late TextEditingController _nameCtl;
  late TextEditingController _handleCtl;
  late TextEditingController _bioCtl;
  late TextEditingController _emailCtl;
  late TextEditingController _phoneCtl;
  late TextEditingController _addressCtl;
  late TextEditingController _policyCtl;
  late TextEditingController _bankNameCtl;
  late TextEditingController _bankAccCtl;
  late TextEditingController _bankHolderCtl;

  @override
  void initState() {
    super.initState();
    final p = _seller.profile;
    _nameCtl = TextEditingController(text: p.name);
    _handleCtl = TextEditingController(text: p.handle);
    _bioCtl = TextEditingController(text: p.bio);
    _emailCtl = TextEditingController(text: p.email);
    _phoneCtl = TextEditingController(text: p.phone);
    _addressCtl = TextEditingController(text: p.address);
    _policyCtl = TextEditingController(text: p.returnPolicy);
    _bankNameCtl = TextEditingController(text: p.payoutBankName);
    _bankAccCtl = TextEditingController(text: p.payoutAccountNumber);
    _bankHolderCtl = TextEditingController(text: p.payoutAccountHolder);
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _handleCtl.dispose();
    _bioCtl.dispose();
    _emailCtl.dispose();
    _phoneCtl.dispose();
    _addressCtl.dispose();
    _policyCtl.dispose();
    _bankNameCtl.dispose();
    _bankAccCtl.dispose();
    _bankHolderCtl.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    setState(() => _saving = true);
    HapticFeedback.mediumImpact();

    final updated = _seller.profile.copyWith(
      name: _nameCtl.text.trim(),
      handle: _handleCtl.text.trim(),
      bio: _bioCtl.text.trim(),
      email: _emailCtl.text.trim(),
      phone: _phoneCtl.text.trim(),
      address: _addressCtl.text.trim(),
      returnPolicy: _policyCtl.text.trim(),
      payoutBankName: _bankNameCtl.text.trim(),
      payoutAccountNumber: _bankAccCtl.text.trim(),
      payoutAccountHolder: _bankHolderCtl.text.trim(),
    );

    _seller.updateShopProfile(updated);

    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF10B981),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Row(
            children: [
              const Icon(CupertinoIcons.checkmark_circle_fill, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.tr('profile_updated_toast'),
                  style: const TextStyle(fontWeight: FontWeight.w700),
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
    final cardBg = isDark ? const Color(0xFF161B22) : Colors.white;
    final borderColor = isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B);

    final profile = _seller.profile;

    final tabs = [
      context.tr('tab_general'),
      context.tr('tab_payout_bank'),
      context.tr('tab_shipping_policy'),
    ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(context.tr('store_menu_title')),
        actions: [
          PressableScale(
            onTap: _saving ? null : _saveProfile,
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: _saving
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      context.tr('save'),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
          children: [
            // Hero Luxury Boutique Card
            AnimatedEntry(
              delay: const Duration(milliseconds: 30),
              child: _buildBoutiqueHeroCard(
                profile: profile,
                cardBg: cardBg,
                borderColor: borderColor,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                primaryColor: primaryColor,
                isDark: isDark,
              ),
            ),

            const SizedBox(height: 16),

            // Live Store Online Status Toggle Card
            AnimatedEntry(
              delay: const Duration(milliseconds: 60),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isStoreOnline ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        boxShadow: [
                          BoxShadow(
                            color: (_isStoreOnline ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                                .withValues(alpha: 0.5),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isStoreOnline ? context.tr('store_online') : 'Store Offline / Paused',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                            ),
                          ),
                          Text(
                            _isStoreOnline ? context.tr('status_accepting_orders') : 'Storefront hidden from customers',
                            style: TextStyle(fontSize: 11, color: textSecondary),
                          ),
                        ],
                      ),
                    ),
                    CupertinoSwitch(
                      value: _isStoreOnline,
                      activeTrackColor: const Color(0xFF10B981),
                      onChanged: (val) {
                        HapticFeedback.selectionClick();
                        setState(() => _isStoreOnline = val);
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Segmented Menu Tabs
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: tabs.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final isSel = _selectedTab == i;
                  return PressableScale(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedTab = i);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                      decoration: BoxDecoration(
                        color: isSel ? primaryColor : cardBg,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSel ? primaryColor : borderColor,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          tabs[i],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isSel ? Colors.white : textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Active Tab Content
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: _buildActiveTabContent(
                cardBg: cardBg,
                borderColor: borderColor,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                primaryColor: primaryColor,
                isDark: isDark,
              ),
            ),

            const SizedBox(height: 24),

            // Quick Preferences & Settings Navigation
            _sectionHeader('QUICK SETTINGS & TOOLS', textSecondary),
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Column(
                children: [
                  _menuNavTile(
                    icon: CupertinoIcons.money_dollar_circle_fill,
                    iconColor: const Color(0xFF10B981),
                    title: context.tr('payouts_settlements'),
                    subtitle: 'Available balance: \$${_seller.availableBalance.toStringAsFixed(2)}',
                    onTap: () => context.push(AppRoutes.sellerPayouts),
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    isDark: isDark,
                    showDivider: true,
                  ),
                  _menuNavTile(
                    icon: CupertinoIcons.globe,
                    iconColor: const Color(0xFF3B82F6),
                    title: context.tr('language_region'),
                    subtitle: 'English • ភាសាខ្មែរ • Tiếng Việt',
                    onTap: () => context.push(AppRoutes.language),
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    isDark: isDark,
                    showDivider: true,
                  ),
                  _menuNavTile(
                    icon: CupertinoIcons.paintbrush_fill,
                    iconColor: const Color(0xFF8B5CF6),
                    title: context.tr('theme_appearance'),
                    subtitle: 'Dark mode, Light mode & Brand colors',
                    onTap: () => context.push(AppRoutes.theme),
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    isDark: isDark,
                    showDivider: false,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Switch to Buyer Mode CTA
            PressableScale(
              onTap: () {
                HapticFeedback.mediumImpact();
                context.go(AppRoutes.home);
              },
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.bag_fill, color: primaryColor, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      context.tr('buyer_view'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                        letterSpacing: -0.2,
                      ),
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

  Widget _buildBoutiqueHeroCard({
    required dynamic profile,
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
    required Color primaryColor,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Banner with avatar
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(23)),
                child: Image.network(
                  profile.bannerUrl,
                  height: 110,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: -28,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(profile.logoUrl),
                      fit: BoxFit.cover,
                    ),
                    border: Border.all(color: cardBg, width: 3),
                    boxShadow: const [
                      BoxShadow(color: Color(0x33000000), blurRadius: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 34),

          // Name, Handle & Verified Tag
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        profile.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(CupertinoIcons.checkmark_seal_fill, color: primaryColor, size: 18),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  profile.handle,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Divider(height: 1, color: borderColor),
          const SizedBox(height: 12),

          // KPI Metrics Ribbon (Rating, Sales, Followers)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Row(
              children: [
                Expanded(
                  child: _kpiStat('★ ${profile.rating}', context.tr('boutique_rating'), const Color(0xFFF59E0B), textSecondary),
                ),
                Container(width: 1, height: 24, color: borderColor),
                Expanded(
                  child: _kpiStat('${profile.totalSales}', context.tr('total_orders_sold'), primaryColor, textSecondary),
                ),
                Container(width: 1, height: 24, color: borderColor),
                Expanded(
                  child: _kpiStat('${profile.followerCount}', context.tr('active_followers'), const Color(0xFF10B981), textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _kpiStat(String val, String label, Color valColor, Color textSecondary) {
    return Column(
      children: [
        Text(
          val,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: valColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveTabContent({
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
    required Color primaryColor,
    required bool isDark,
  }) {
    switch (_selectedTab) {
      case 0:
        return _buildBrandingForm(cardBg, borderColor, textPrimary, textSecondary, isDark);
      case 1:
        return _buildPayoutForm(cardBg, borderColor, textPrimary, textSecondary, primaryColor, isDark);
      case 2:
      default:
        return _buildDispatchPoliciesForm(cardBg, borderColor, textPrimary, textSecondary, isDark);
    }
  }

  Widget _buildBrandingForm(Color cardBg, Color borderColor, Color textPrimary, Color textSecondary, bool isDark) {
    return Container(
      key: const ValueKey('tab_branding'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _inputLabel('Store Name', textPrimary),
          const SizedBox(height: 6),
          _field(_nameCtl, 'Maison Trentify Studio', isDark, borderColor, textPrimary, textSecondary),
          const SizedBox(height: 14),

          _inputLabel('Store Handle / URL', textPrimary),
          const SizedBox(height: 6),
          _field(_handleCtl, '@maisontrentify', isDark, borderColor, textPrimary, textSecondary),
          const SizedBox(height: 14),

          _inputLabel('Store Bio / Description', textPrimary),
          const SizedBox(height: 6),
          _field(_bioCtl, 'Tell shoppers about your fashion aesthetics...', isDark, borderColor, textPrimary, textSecondary, maxLines: 3),
        ],
      ),
    );
  }

  Widget _buildPayoutForm(Color cardBg, Color borderColor, Color textPrimary, Color textSecondary, Color primaryColor, bool isDark) {
    return Container(
      key: const ValueKey('tab_payout'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Live Wallet Summary Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(CupertinoIcons.checkmark_shield_fill, color: Color(0xFF10B981), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('available_for_payout'),
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textSecondary),
                      ),
                      Text(
                        '\$${_seller.availableBalance.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF10B981)),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push(AppRoutes.sellerPayouts),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      context.tr('withdraw_funds'),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          _inputLabel(context.tr('bank_name_label'), textPrimary),
          const SizedBox(height: 6),
          _field(_bankNameCtl, 'ABA Bank (Advanced Bank of Asia)', isDark, borderColor, textPrimary, textSecondary),
          const SizedBox(height: 14),

          _inputLabel(context.tr('account_number_label'), textPrimary),
          const SizedBox(height: 6),
          _field(_bankAccCtl, '001 849 204 (USD)', isDark, borderColor, textPrimary, textSecondary),
          const SizedBox(height: 14),

          _inputLabel(context.tr('account_holder_label'), textPrimary),
          const SizedBox(height: 6),
          _field(_bankHolderCtl, 'MAISON TRENTIFY CO., LTD', isDark, borderColor, textPrimary, textSecondary),
        ],
      ),
    );
  }

  Widget _buildDispatchPoliciesForm(Color cardBg, Color borderColor, Color textPrimary, Color textSecondary, bool isDark) {
    return Container(
      key: const ValueKey('tab_dispatch'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _inputLabel('Concierge Email', textPrimary),
          const SizedBox(height: 6),
          _field(_emailCtl, 'concierge@maisontrentify.com', isDark, borderColor, textPrimary, textSecondary),
          const SizedBox(height: 14),

          _inputLabel('Customer Service Phone', textPrimary),
          const SizedBox(height: 6),
          _field(_phoneCtl, '+1 (555) 234-8901', isDark, borderColor, textPrimary, textSecondary),
          const SizedBox(height: 14),

          _inputLabel('Dispatch & Return Address', textPrimary),
          const SizedBox(height: 6),
          _field(_addressCtl, '742 Fashion Avenue, New York, NY 10018', isDark, borderColor, textPrimary, textSecondary),
          const SizedBox(height: 14),

          _inputLabel('Return & Exchange Policy', textPrimary),
          const SizedBox(height: 6),
          _field(_policyCtl, '30-day worldwide returns on unworn garments with tags attached.', isDark, borderColor, textPrimary, textSecondary, maxLines: 3),
        ],
      ),
    );
  }

  Widget _menuNavTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color textPrimary,
    required Color textSecondary,
    required bool isDark,
    required bool showDivider,
  }) {
    return Column(
      children: [
        PressableScale(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: textSecondary),
                      ),
                    ],
                  ),
                ),
                Icon(CupertinoIcons.chevron_right, size: 14, color: textSecondary),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(height: 1, indent: 56, endIndent: 16, color: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0)),
      ],
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

  Widget _field(
    TextEditingController ctl,
    String hint,
    bool isDark,
    Color borderColor,
    Color textPrimary,
    Color textSecondary, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: ctl,
      maxLines: maxLines,
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
