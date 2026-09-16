import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// 圆角顶 Sheet 容器（底部避让由 [showAppSheet] 统一处理）。
class AppSheet extends StatelessWidget {
  const AppSheet({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.md,
          AppSpacing.page,
          AppSpacing.lg,
        ),
        child: child,
      ),
    );
  }
}

/// 弹出底部 Sheet。
/// [requireIme] 为 true 时：等输入法起来再显示；用户收起输入法则关闭。
/// [avoidIme] 为 true 时：Sheet 贴在键盘上方；格式等面板应传 false 并先收起键盘。
Future<T?> showAppSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool requireIme = false,
  bool avoidIme = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: requireIme ? Colors.transparent : null,
    isScrollControlled: true,
    useSafeArea: false,
    useRootNavigator: true,
    enableDrag: !requireIme,
    builder: (ctx) => _SheetAnchor(
      builder: builder,
      requireIme: requireIme,
      avoidIme: avoidIme,
    ),
  );
}

/// 锚定 Sheet 底部：用 metrics 观察器读键盘高度，避免依赖 MediaQuery.viewInsets
///（关 Sheet / 收键盘同一帧时 InheritedElement 易触发 `_dependents.isEmpty`）。
class _SheetAnchor extends StatefulWidget {
  const _SheetAnchor({
    required this.builder,
    this.requireIme = false,
    this.avoidIme = true,
  });

  final WidgetBuilder builder;
  final bool requireIme;
  final bool avoidIme;

  @override
  State<_SheetAnchor> createState() => _SheetAnchorState();
}

class _SheetAnchorState extends State<_SheetAnchor> with WidgetsBindingObserver {
  static const _imeThreshold = 8.0;

  double _imeBottom = 0;
  bool _imeSeen = false;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    // 1. 注册 metrics 监听
    // 2. 同步当前键盘高度
    WidgetsBinding.instance.addObserver(this);
    _imeBottom = _readImeBottom();
    if (_imeBottom > _imeThreshold) _imeSeen = true;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    // 1. 从 PlatformDispatcher 读取最新 IME inset（不注册 Inherited 依赖）
    // 2. 刷新垫高；见过键盘后若用户收起且无子弹路由，则关闭本层
    final next = _readImeBottom();
    if ((next - _imeBottom).abs() < 0.5) return;
    if (!mounted) return;
    final imeOpen = next > _imeThreshold;
    if (imeOpen) _imeSeen = true;
    setState(() => _imeBottom = next);
    if (widget.requireIme && _imeSeen && !imeOpen) {
      _dismissIfCurrent();
    }
  }

  /// 仅在本 Sheet 仍是最前路由时关闭（子弹日期层打开时不关）。
  void _dismissIfCurrent() {
    // 1. 已在关闭或已卸载则忽略
    if (_closing || !mounted) return;
    // 2. 上面还有路由（如日期 Sheet）时不关，等子层结束后再由 metrics 决定
    final route = ModalRoute.of(context);
    if (route == null || !route.isCurrent) return;
    _closing = true;
    Navigator.of(context).pop();
  }

  /// 遮罩点击关闭。
  void _dismiss() => _dismissIfCurrent();

  /// 读取逻辑像素下的 IME 底部 inset。
  double _readImeBottom() {
    final views = WidgetsBinding.instance.platformDispatcher.views;
    if (views.isEmpty) return 0;
    final view = views.first;
    return view.viewInsets.bottom / view.devicePixelRatio;
  }

  @override
  Widget build(BuildContext context) {
    // 1. 需要避让键盘时用 IME 高度垫底；格式面板等不避让
    final sheet = Padding(
      padding: EdgeInsets.only(bottom: widget.avoidIme ? _imeBottom : 0),
      child: widget.builder(context),
    );
    if (!widget.requireIme) return sheet;

    // 2. 键盘起来后显示；收起由 didChangeMetrics 关闭；遮罩也可点关
    final visible = _imeSeen && _imeBottom > _imeThreshold;
    return SizedBox.expand(
      child: Stack(
        children: [
          if (_imeSeen)
            GestureDetector(
              onTap: _dismiss,
              child: ColoredBox(
                color: visible
                    ? const Color(0x8A000000)
                    : const Color(0x00000000),
              ),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Opacity(
              opacity: visible ? 1 : 0,
              child: IgnorePointer(ignoring: !visible, child: sheet),
            ),
          ),
        ],
      ),
    );
  }
}
