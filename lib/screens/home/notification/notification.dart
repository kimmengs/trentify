import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:trentify/l10n/app_localizations.dart';
import 'package:trentify/router/app_routes.dart';
import 'package:trentify/widgets/pressable_scale.dart';

enum NoticeCategory { all, orders, promos, system }

class NoticeItem {
  final String id;
  final String title;
  final String body;
  final DateTime time;
  final IconData icon;
  final List<Color> gradientColors;
  final NoticeCategory category;
  final String? actionLabel;
  final String? targetRoute;
  final Map<String, dynamic>? extra;
  bool isUnread;

  NoticeItem({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.icon,
    required this.gradientColors,
    required this.category,
    this.actionLabel,
    this.targetRoute,
    this.extra,
    this.isUnread = true,
  });
}

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  NoticeCategory _selectedCategory = NoticeCategory.all;

  late List<NoticeItem> _notifications;

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  void _initNotifications() {
    final now = DateTime.now();
    _notifications = [
      NoticeItem(
        id: 'ord_1',
        title: 'Package Out for Delivery ✈️',
        body: 'Your order #ORD-1001 with DHL Express Priority is out for delivery today.',
        time: now.subtract(const Duration(minutes: 24)),
        icon: CupertinoIcons.airplane,
        gradientColors: const [Color(0xFF2563EB), Color(0xFF38BDF8)],
        category: NoticeCategory.orders,
        actionLabel: 'Track Shipment',
        targetRoute: AppRoutes.home,
        extra: {'tabIndex': 3},
        isUnread: true,
      ),
      NoticeItem(
        id: 'promo_1',
        title: 'VIP Weekend Exclusive: 20% OFF 🎉',
        body: 'Use code LUXURY20 at checkout for 20% off all designer suits and outerwear.',
        time: now.subtract(const Duration(hours: 2)),
        icon: CupertinoIcons.tag_fill,
        gradientColors: const [Color(0xFF8B5CF6), Color(0xFFD946EF)],
        category: NoticeCategory.promos,
        actionLabel: 'Shop Collection',
        targetRoute: AppRoutes.home,
        extra: {'tabIndex': 0},
        isUnread: true,
      ),
      NoticeItem(
        id: 'ord_2',
        title: 'Order Confirmed & Prepared 📦',
        body: 'Order #ORD-1000 has been verified by the boutique and packed for express dispatch.',
        time: now.subtract(const Duration(hours: 6)),
        icon: CupertinoIcons.cube_box_fill,
        gradientColors: const [Color(0xFF10B981), Color(0xFF34D399)],
        category: NoticeCategory.orders,
        actionLabel: 'View Order',
        targetRoute: AppRoutes.home,
        extra: {'tabIndex': 3},
        isUnread: true,
      ),
      NoticeItem(
        id: 'promo_2',
        title: 'Free VIP Express Delivery Unlocked 🚀',
        body: 'Enjoy complimentary express courier shipping on all purchases above \$300.',
        time: now.subtract(const Duration(days: 1, hours: 2)),
        icon: CupertinoIcons.sparkles,
        gradientColors: const [Color(0xFFF59E0B), Color(0xFFFBBF24)],
        category: NoticeCategory.promos,
        actionLabel: 'View Bag',
        targetRoute: AppRoutes.home,
        extra: {'tabIndex': 2},
        isUnread: false,
      ),
      NoticeItem(
        id: 'sys_1',
        title: 'Account Security Verified 🔒',
        body: 'Biometric Face ID authentication was successfully registered for your VIP account.',
        time: now.subtract(const Duration(days: 1, hours: 8)),
        icon: CupertinoIcons.shield_lefthalf_fill,
        gradientColors: const [Color(0xFF6366F1), Color(0xFF818CF8)],
        category: NoticeCategory.system,
        isUnread: false,
      ),
      NoticeItem(
        id: 'sys_2',
        title: 'New Spring/Summer Catalog Live ✨',
        body: 'Explore over 50+ new luxury silhouettes added to Trentify Haute Couture today.',
        time: now.subtract(const Duration(days: 2, hours: 4)),
        icon: CupertinoIcons.app_badge_fill,
        gradientColors: const [Color(0xFFEC4899), Color(0xFFF43F5E)],
        category: NoticeCategory.system,
        actionLabel: 'Explore Catalog',
        targetRoute: AppRoutes.home,
        extra: {'tabIndex': 0},
        isUnread: false,
      ),
    ];
  }

  void _markAllAsRead() {
    HapticFeedback.lightImpact();
    setState(() {
      for (final n in _notifications) {
        n.isUnread = false;
      }
    });
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('All notifications marked as read'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleNotificationTap(NoticeItem item) {
    HapticFeedback.lightImpact();
    setState(() {
      item.isUnread = false;
    });

    if (item.targetRoute != null) {
      if (item.targetRoute == AppRoutes.home && item.extra != null) {
        context.go(AppRoutes.home, extra: item.extra);
      } else {
        context.push(item.targetRoute!);
      }
    }
  }

  void _deleteNotification(NoticeItem item) {
    HapticFeedback.mediumImpact();
    setState(() {
      _notifications.removeWhere((n) => n.id == item.id);
    });
  }

  List<NoticeItem> get _filteredNotifications {
    if (_selectedCategory == NoticeCategory.all) return _notifications;
    return _notifications.where((n) => n.category == _selectedCategory).toList();
  }

  int _countFor(NoticeCategory cat) {
    if (cat == NoticeCategory.all) return _notifications.length;
    return _notifications.where((n) => n.category == cat).length;
  }

  int get _totalUnread => _notifications.where((n) => n.isUnread).length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B);
    final cardBg = isDark ? const Color(0xFF161B22) : Colors.white;
    final borderColor = isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0);

    final displayList = _filteredNotifications;

    final todayItems = displayList.where((n) => _isSameDay(n.time, DateTime.now())).toList();
    final yesterdayItems = displayList
        .where((n) => _isSameDay(n.time, DateTime.now().subtract(const Duration(days: 1))))
        .toList();
    final earlierItems = displayList
        .where((n) =>
            !_isSameDay(n.time, DateTime.now()) &&
            !_isSameDay(n.time, DateTime.now().subtract(const Duration(days: 1))))
        .toList();

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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.tr('notifications_title'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ),
            if (_totalUnread > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$_totalUnread',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (_notifications.any((n) => n.isUnread))
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                context.tr('mark_all_read'),
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Category Pill Tabs
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _CategoryFilterChip(
                    label: '${context.tr('filter_all')} (${_countFor(NoticeCategory.all)})',
                    selected: _selectedCategory == NoticeCategory.all,
                    onTap: () => setState(() => _selectedCategory = NoticeCategory.all),
                    primaryColor: primaryColor,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _CategoryFilterChip(
                    label: '${context.tr('filter_orders')} (${_countFor(NoticeCategory.orders)})',
                    selected: _selectedCategory == NoticeCategory.orders,
                    onTap: () => setState(() => _selectedCategory = NoticeCategory.orders),
                    primaryColor: primaryColor,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _CategoryFilterChip(
                    label: '${context.tr('filter_promos')} (${_countFor(NoticeCategory.promos)})',
                    selected: _selectedCategory == NoticeCategory.promos,
                    onTap: () => setState(() => _selectedCategory = NoticeCategory.promos),
                    primaryColor: primaryColor,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _CategoryFilterChip(
                    label: '${context.tr('filter_system')} (${_countFor(NoticeCategory.system)})',
                    selected: _selectedCategory == NoticeCategory.system,
                    onTap: () => setState(() => _selectedCategory = NoticeCategory.system),
                    primaryColor: primaryColor,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),

          // Notifications List View
          Expanded(
            child: displayList.isEmpty
                ? _EmptyNotificationState(isDark: isDark, primaryColor: primaryColor)
                : ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 40),
                    children: [
                      if (todayItems.isNotEmpty) ...[
                        _DateGroupHeader(title: 'Today', textSecondary: textSecondary),
                        const SizedBox(height: 8),
                        ...todayItems.map((n) => _NotificationTile(
                              item: n,
                              isDark: isDark,
                              cardBg: cardBg,
                              borderColor: borderColor,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                              primaryColor: primaryColor,
                              onTap: () => _handleNotificationTap(n),
                              onDelete: () => _deleteNotification(n),
                            )),
                        const SizedBox(height: 14),
                      ],
                      if (yesterdayItems.isNotEmpty) ...[
                        _DateGroupHeader(title: 'Yesterday', textSecondary: textSecondary),
                        const SizedBox(height: 8),
                        ...yesterdayItems.map((n) => _NotificationTile(
                              item: n,
                              isDark: isDark,
                              cardBg: cardBg,
                              borderColor: borderColor,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                              primaryColor: primaryColor,
                              onTap: () => _handleNotificationTap(n),
                              onDelete: () => _deleteNotification(n),
                            )),
                        const SizedBox(height: 14),
                      ],
                      if (earlierItems.isNotEmpty) ...[
                        _DateGroupHeader(title: 'Earlier', textSecondary: textSecondary),
                        const SizedBox(height: 8),
                        ...earlierItems.map((n) => _NotificationTile(
                              item: n,
                              isDark: isDark,
                              cardBg: cardBg,
                              borderColor: borderColor,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                              primaryColor: primaryColor,
                              onTap: () => _handleNotificationTap(n),
                              onDelete: () => _deleteNotification(n),
                            )),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _CategoryFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color primaryColor;
  final bool isDark;

  const _CategoryFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.primaryColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? primaryColor
              : (isDark ? const Color(0xFF161B22) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? primaryColor
                : (isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0)),
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            color: selected
                ? Colors.white
                : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B)),
          ),
        ),
      ),
    );
  }
}

class _DateGroupHeader extends StatelessWidget {
  final String title;
  final Color textSecondary;

  const _DateGroupHeader({required this.title, required this.textSecondary});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
          color: textSecondary,
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NoticeItem item;
  final bool isDark;
  final Color cardBg;
  final Color borderColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color primaryColor;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationTile({
    required this.item,
    required this.isDark,
    required this.cardBg,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.primaryColor,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(CupertinoIcons.trash, color: Colors.white, size: 20),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: item.isUnread ? primaryColor.withValues(alpha: 0.3) : borderColor,
            width: item.isUnread ? 1.2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Glowing Icon Badge
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: item.gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: item.gradientColors.first.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(item.icon, size: 20, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: item.isUnread ? FontWeight.w800 : FontWeight.w600,
                                color: textPrimary,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          if (item.isUnread)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.body,
                        style: TextStyle(
                          fontSize: 12,
                          color: textSecondary,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Footer Row: Time and Action Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatRelativeTime(item.time),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: textSecondary.withValues(alpha: 0.7),
                            ),
                          ),
                          if (item.actionLabel != null)
                            PressableScale(
                              onTap: onTap,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      item.actionLabel!,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: primaryColor,
                                      ),
                                    ),
                                    const SizedBox(width: 3),
                                    Icon(
                                      CupertinoIcons.arrow_right,
                                      size: 10,
                                      color: primaryColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatRelativeTime(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    }
    return '${diff.inDays}d ago';
  }
}

class _EmptyNotificationState extends StatelessWidget {
  final bool isDark;
  final Color primaryColor;

  const _EmptyNotificationState({required this.isDark, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: isDark ? 0.15 : 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.bell_fill,
                size: 38,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              context.tr('no_notifications'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr('no_notifications_sub'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            PressableScale(
              onTap: () => context.go(AppRoutes.home),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(CupertinoIcons.sparkles, size: 16, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      context.tr('start_shopping'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
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
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
