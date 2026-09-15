import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_page_header.dart';

/// 我的：入口导航。
class MinePage extends StatelessWidget {
  const MinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const AppPageHeader(title: '我的'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.sheet,
              borderRadius: BorderRadius.circular(AppColors.radiusMd),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.accentSoft,
                  child: Icon(LucideIcons.moon, color: AppColors.accentDeep),
                ),
                SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '月兔账本',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '本地优先 · 数据不出设备',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _MenuCard(
            children: [
              _MenuTile(
                icon: LucideIcons.tags,
                title: '分类管理',
                onTap: () => context.push('/categories'),
              ),
              _MenuTile(
                icon: LucideIcons.database,
                title: '数据管理',
                onTap: () => context.push('/mine/data'),
              ),
              _MenuTile(
                icon: LucideIcons.info,
                title: '关于',
                onTap: () => context.push('/mine/about'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.sheet,
        borderRadius: BorderRadius.circular(AppColors.radiusMd),
      ),
      child: Column(children: children),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 20, color: AppColors.accentDeep),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: AppColors.mute),
      onTap: onTap,
    );
  }
}
