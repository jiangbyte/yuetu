import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../../data/repositories/providers.dart';

/// 数据导出与清空。
class DataPage extends ConsumerStatefulWidget {
  const DataPage({super.key});

  @override
  ConsumerState<DataPage> createState() => _DataPageState();
}

class _DataPageState extends ConsumerState<DataPage> {
  bool _busy = false;

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      // 1. 导出 JSON 字符串
      // 2. 写入临时文件并唤起系统分享
      final json = await ref.read(dataRepositoryProvider).exportJson();
      final dir = await getTemporaryDirectory();
      final stamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')
          .first;
      final file = File(p.join(dir.path, 'yuetu-backup-$stamp.json'));
      await file.writeAsString(json);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: '月兔数据备份',
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败：$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _clear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('清空业务数据'),
        content: const Text('将删除全部流水、任务与笔记，分类会保留。此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.expense),
            child: const Text('清空'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _busy = true);
    try {
      await ref.read(dataRepositoryProvider).clearUserContent();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已清空')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('清空失败：$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const AppPageHeader(title: '数据管理', showBack: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.sheet,
              borderRadius: BorderRadius.circular(AppColors.radiusMd),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.upload_file_outlined,
                      color: AppColors.accentDeep),
                  title: const Text('导出备份（JSON）'),
                  subtitle: const Text('分享到文件管理器或其它 App'),
                  trailing: _busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: _busy ? null : _export,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_outline,
                      color: AppColors.expense),
                  title: const Text('清空流水 / 任务 / 笔记'),
                  subtitle: const Text('分类与账本设置保留'),
                  onTap: _busy ? null : _clear,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
