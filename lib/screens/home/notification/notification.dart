import 'package:flutter/material.dart';

enum NoticeTab { general, promotions }

class NoticeItem {
  final String id;
  final String title;
  final String body;
  final DateTime time;
  final IconData icon;
  final bool unread;
  final NoticeTab tab;

  NoticeItem({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.icon,
    this.unread = true,
    this.tab = NoticeTab.general,
  });
}

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  NoticeTab _tab = NoticeTab.general;

  // --- demo data (swap with your backend/provider) ---
  late final List<NoticeItem> _all = [
    NoticeItem(
      id: '1',
      title: 'Account Security Alert 🔒',
      body:
          "We've noticed some unusual activity on your account. Please review your recent logins and update your password if necessary.",
      time: DateTime.now().subtract(const Duration(minutes: 5)),
      icon: Icons.verified_user_outlined,
      tab: NoticeTab.general,
    ),
    NoticeItem(
      id: '2',
      title: 'System Update Available 🔄',
      body:
          'A new system update is ready for installation. It includes performance improvements and bug fixes.',
      time: DateTime.now().subtract(const Duration(minutes: 55)),
      icon: Icons.info_outline,
      tab: NoticeTab.general,
    ),
    NoticeItem(
      id: '3',
      title: 'Password Reset Successful ✅',
      body:
          "Your password has been successfully reset. If you didn't request this change, please contact support immediately.",
      time: DateTime.now().subtract(const Duration(hours: 14)), // yesterday
      icon: Icons.lock_outline,
      tab: NoticeTab.general,
      unread: false,
    ),
    NoticeItem(
      id: '4',
      title: 'Exciting New Feature 🆕',
      body:
          "We've just launched a new feature that will enhance your user experience. Check it out now!",
      time: DateTime.now().subtract(const Duration(hours: 17)), // yesterday
      icon: Icons.grade_outlined,
      tab: NoticeTab.general,
    ),
    // promotions
    NoticeItem(
      id: 'p1',
      title: 'Weekend Mega Sale 🎉',
      body: 'Up to 40% OFF selected items. Limited time only.',
      time: DateTime.now().subtract(const Duration(hours: 2)),
      icon: Icons.local_offer_outlined,
      tab: NoticeTab.promotions,
    ),
    NoticeItem(
      id: 'p2',
      title: 'Free Shipping Voucher ✈️',
      body: 'Use code FREESHIP on orders above \$50.',
      time: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      icon: Icons.card_giftcard_outlined,
      tab: NoticeTab.promotions,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final items = _all.where((e) => e.tab == _tab).toList()
      ..sort((a, b) => b.time.compareTo(a.time));

    final today = items
        .where((e) => _isSameDay(e.time, DateTime.now()))
        .toList();
    final yesterday = items
        .where(
          (e) => _isSameDay(
            e.time,
            DateTime.now().subtract(const Duration(days: 1)),
          ),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        centerTitle: true,
        title: const Text('Notification'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: open notification settings
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tabs (pill segmented look)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: DecoratedBox(
              decoration: ShapeDecoration(
                color: cs.surfaceContainerHighest,
                shape: const StadiumBorder(),
              ),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Row(
                  children: [
                    _SegmentChip(
                      label: 'General',
                      selected: _tab == NoticeTab.general,
                      onTap: () => setState(() => _tab = NoticeTab.general),
                    ),
                    const SizedBox(width: 8),
                    _SegmentChip(
                      label: 'Promotions',
                      selected: _tab == NoticeTab.promotions,
                      onTap: () => setState(() => _tab = NoticeTab.promotions),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 1),

          // List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: [
                if (today.isNotEmpty) ...[
                  _SectionHeader('Today'),
                  const SizedBox(height: 8),
                  ...today.map((n) => _NoticeTile(item: n)),
                  const SizedBox(height: 16),
                ],
                if (yesterday.isNotEmpty) ...[
                  _SectionHeader('Yesterday'),
                  const SizedBox(height: 8),
                  ...yesterday.map((n) => _NoticeTile(item: n)),
                ],
                if (today.isEmpty && yesterday.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 48),
                    child: Center(
                      child: Text(
                        'No notifications',
                        style: text.bodyLarge?.copyWith(color: cs.outline),
                      ),
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

// --- Parts ---

class _SegmentChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SegmentChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Material(
        color: selected
            ? const Color(0xFF528F65)
            : Colors.transparent, // green like mock
        shape: const StadiumBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : cs.onSurface,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final divider = Theme.of(context).dividerColor.withOpacity(0.4);
    return Row(
      children: [
        Text(
          title,
          style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(width: 8),
        Expanded(child: Divider(color: divider, thickness: 1)),
      ],
    );
  }
}

class _NoticeTile extends StatelessWidget {
  final NoticeItem item;
  const _NoticeTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            // TODO: open details; also mark read
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Leading circled icon
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Icon(item.icon, size: 26),
                ),
                const SizedBox(width: 12),

                // Texts
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // title row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: text.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // status dot + chevron
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _StatusDot(active: item.unread),
                              const SizedBox(width: 6),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(item.body, style: text.bodyMedium),
                      const SizedBox(height: 8),
                      Text(
                        _fmtTime(item.time),
                        style: text.bodySmall?.copyWith(color: cs.outline),
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
}

class _StatusDot extends StatelessWidget {
  final bool active;
  const _StatusDot({required this.active});

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFF52AA5E) : Colors.transparent;
    final border = active ? Colors.transparent : Theme.of(context).dividerColor;
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: border),
      ),
    );
  }
}

// --- helpers ---

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String _fmtTime(DateTime t) {
  final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
  final m = t.minute.toString().padLeft(2, '0');
  final ampm = t.hour >= 12 ? 'PM' : 'AM';
  return '${h.toString().padLeft(2, '0')}:$m $ampm';
}
