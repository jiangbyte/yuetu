import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_page_header.dart';

/// 关于页。
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const _repo = 'https://github.com/jiangbyte/yuetu';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const AppPageHeader(title: '关于', showBack: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.sheet,
              borderRadius: BorderRadius.circular(AppColors.radiusMd),
            ),
            child: const Column(
              children: [
                Text(
                  '月兔',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 8),
                Text(
                  'v2.0.0',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                SizedBox(height: 12),
                Text(
                  '本地优先的个人账本与事项 App。\n流水记账、日历总览、任务与笔记；数据落在本机 SQLite，不上传云端。',
                  textAlign: TextAlign.center,
                  style: TextStyle(height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.sheet,
              borderRadius: BorderRadius.circular(AppColors.radiusMd),
            ),
            child: Column(
              children: [
                const ListTile(
                  title: Text('技术栈'),
                  subtitle: Text('Flutter · Riverpod · Drift · go_router'),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('开源仓库'),
                  subtitle: const Text(_repo),
                  trailing: const Icon(Icons.copy, size: 18),
                  onTap: () async {
                    await Clipboard.setData(const ClipboardData(text: _repo));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('已复制仓库地址')),
                      );
                    }
                  },
                ),
                const Divider(height: 1),
                const ListTile(
                  title: Text('协议'),
                  subtitle: Text('Apache License 2.0'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
