import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('More'),
        // If this page sits under a TabScaffold you can hide the back button:
        // automaticallyImplyLeading: false,
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            // Profile card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x11000000),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // avatar
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage('https://i.pravatar.cc/150?img=12'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kimmeng Soueng',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'andrew_ainsley@yourdomain.com',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: CupertinoColors.systemGrey,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => context.push('/profile/edit'),
                    child: const Icon(
                      CupertinoIcons.pencil,
                      color: Color(0xFF4F77FE),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),
            const Divider(height: 1, color: CupertinoColors.separator),
            const SizedBox(height: 12),

            _MoreItem(
              icon: CupertinoIcons.person_solid,
              tint: const Color(0xFFE7F0FF),
              title: 'Language & Region',
              onTap: () {},
            ),
            _MoreItem(
              icon: CupertinoIcons.lock_fill,
              tint: const Color(0xFFFFF1DC),
              title: 'Security',
              onTap: () {},
            ),
            _MoreItem(
              icon: CupertinoIcons.bell_fill,
              tint: const Color(0xFFEDE9FF),
              title: 'Notifications',
              onTap: () {},
            ),
            _MoreItem(
              icon: CupertinoIcons.color_filter,
              tint: const Color(0xFFEAF6F0),
              title: 'Themes',
              onTap: () {
                context.push('/settings/theme');
              },
            ),

            // extra bottom space for iPhone home indicator
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _MoreItem extends StatelessWidget {
  const _MoreItem({
    required this.icon,
    required this.tint,
    required this.title,
    this.titleColor = CupertinoColors.black,
    this.onTap,
  });

  final IconData icon;
  final Color tint;
  final String title;
  final VoidCallback? onTap;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Icon(icon, color: const Color(0xFF4F77FE), size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_right,
              color: CupertinoColors.systemGrey,
            ),
          ],
        ),
      ),
    );
  }
}
