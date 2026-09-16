import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_text.dart';
import '../application/memorial_provider.dart';
import '../domain/memorial_item.dart';

/// 添加/编辑纪念日。
class MemorialEditPage extends ConsumerStatefulWidget {
  const MemorialEditPage({super.key, this.type});

  final MemorialType? type;

  @override
  ConsumerState<MemorialEditPage> createState() => _MemorialEditPageState();
}

class _MemorialEditPageState extends ConsumerState<MemorialEditPage> {
  late final TextEditingController _name;
  late MemorialType _type;
  DateTime? _date;
  MemorialRepeat _repeat = MemorialRepeat.yearly;
  var _showAge = false;
  String? _reminder = '当天, 提前 3 天';

  @override
  void initState() {
    super.initState();
    _type = widget.type ?? MemorialType.birthday;
    _name = TextEditingController();
    if (_type == MemorialType.countdown) {
      _repeat = MemorialRepeat.none;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(1970),
      lastDate: DateTime(now.year + 50),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickType() async {
    final picked = await showModalBottomSheet<MemorialType>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final t in MemorialType.values)
              ListTile(
                leading: AppIcon(t.icon, color: t.color),
                title: AppText(t.label, role: AppTextRole.body),
                onTap: () => Navigator.pop(ctx, t),
              ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _type = picked);
  }

  Future<void> _pickRepeat() async {
    final picked = await showModalBottomSheet<MemorialRepeat>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final r in MemorialRepeat.values)
              ListTile(
                title: AppText(r.label, role: AppTextRole.body),
                onTap: () => Navigator.pop(ctx, r),
              ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _repeat = picked);
  }

  /// 保存并进入详情。
  void _submit() {
    // 1. 名称与日期必填
    final name = _name.text.trim();
    if (name.isEmpty || _date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写名称和日期')),
      );
      return;
    }
    // 2. 写入并跳转详情
    final id = 'm${DateTime.now().millisecondsSinceEpoch}';
    final item = MemorialItem(
      id: id,
      name: name,
      date: _date!,
      type: _type,
      repeat: _repeat,
      showAge: _showAge,
      reminder: _reminder ?? '',
    );
    ref.read(memorialProvider.notifier).add(item);
    context.pushReplacement('/memorial/$id');
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = _date == null
        ? '无'
        : '${_date!.year}/${_date!.month.toString().padLeft(2, '0')}/${_date!.day.toString().padLeft(2, '0')}';

    return Material(
      color: AppColors.canvas,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.page,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const AppIcon(LucideIcons.x, size: 22),
                  ),
                  const Expanded(
                    child: Center(
                      child: AppText('添加', role: AppTextRole.pageTitle),
                    ),
                  ),
                  const SizedBox(width: 22),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
                children: [
                  const SizedBox(height: AppSpacing.md),
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: _type.iconBg,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: AppIcon(
                            _type.icon,
                            size: 40,
                            color: _type.color,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              color: AppColors.surface,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x22000000),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const AppIcon(
                              LucideIcons.pencil,
                              size: 14,
                              color: AppColors.inkMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextField(
                    controller: _name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: AppTypography.body,
                      color: AppColors.ink,
                      backgroundColor: Color(0x00000000),
                    ),
                    decoration: InputDecoration(
                      hintText: '名称',
                      hintStyle: const TextStyle(
                        color: AppColors.inkMuted,
                        backgroundColor: Color(0x00000000),
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _Card(
                    children: [
                      _Tile(
                        label: '日期',
                        value: dateLabel,
                        onTap: _pickDate,
                        onClear: _date == null
                            ? null
                            : () => setState(() => _date = null),
                      ),
                      _Tile(
                        label: '提醒',
                        value: _reminder ?? '无',
                        onTap: () {},
                        onClear: _reminder == null
                            ? null
                            : () => setState(() => _reminder = null),
                      ),
                      _Tile(
                        label: '重复',
                        value: _repeat.label,
                        onTap: _pickRepeat,
                        onClear: () =>
                            setState(() => _repeat = MemorialRepeat.none),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _Card(
                    children: [
                      _Tile(
                        label: '类型',
                        value: _type.label,
                        onTap: _pickType,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm,
                        ),
                        child: Row(
                          children: [
                            const AppText('显示岁数', role: AppTextRole.body),
                            const Spacer(),
                            Switch(
                              value: _showAge,
                              activeThumbColor: AppColors.onPrimary,
                              activeTrackColor: AppColors.primary,
                              onChanged: (v) => setState(() => _showAge = v),
                            ),
                          ],
                        ),
                      ),
                      const _Tile(
                        label: '在智能清单显示',
                        value: '当天显示',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                0,
                AppSpacing.page,
                AppSpacing.lg,
              ),
              child: AppButton(
                label: '下一步',
                expanded: true,
                onPressed: _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Column(children: children),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.label,
    required this.value,
    this.onTap,
    this.onClear,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            AppText(label, role: AppTextRole.body),
            const Spacer(),
            AppText(value, role: AppTextRole.caption),
            if (onClear != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onClear,
                child: const AppIcon(
                  LucideIcons.x,
                  size: 14,
                  color: AppColors.inkMuted,
                ),
              ),
            ],
            if (onTap != null)
              const AppIcon(
                LucideIcons.chevronRight,
                size: 16,
                color: AppColors.inkMuted,
              ),
          ],
        ),
      ),
    );
  }
}
