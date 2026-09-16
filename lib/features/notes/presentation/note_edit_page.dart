import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../core/widgets/app_text.dart';
import '../application/notes_provider.dart';
import '../domain/note_item.dart';
import 'note_add_sheet.dart';
import 'note_format_sheet.dart';

/// 笔记编辑：顶栏 + 元信息 + Quill + 底栏工具。
class NoteEditPage extends ConsumerStatefulWidget {
  const NoteEditPage({super.key, required this.noteId});

  final String noteId;

  @override
  ConsumerState<NoteEditPage> createState() => _NoteEditPageState();
}

class _NoteEditPageState extends ConsumerState<NoteEditPage>
    with WidgetsBindingObserver {
  late final TextEditingController _title;
  late QuillController _quill;
  final _focus = FocusNode();
  final _titleFocus = FocusNode();
  final _speech = SpeechToText();
  bool _speechAvailable = false;
  bool _listening = false;
  bool _editing = false;
  NoteItem? _note;

  /// 键盘高度（逻辑像素），驱动编辑工具栏上移。
  double _imeBottom = 0;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController();
    _quill = QuillController.basic();
    WidgetsBinding.instance.addObserver(this);
    _focus.addListener(_onFocusChange);
    _titleFocus.addListener(_onFocusChange);
    _imeBottom = _readImeBottom();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _onFocusChange() {
    final editing = _focus.hasFocus || _titleFocus.hasFocus;
    if (editing != _editing) setState(() => _editing = editing);
  }

  double _readImeBottom() {
    final views = WidgetsBinding.instance.platformDispatcher.views;
    if (views.isEmpty) return 0;
    final view = views.first;
    return view.viewInsets.bottom / view.devicePixelRatio;
  }

  @override
  void didChangeMetrics() {
    // 1. 跟随 IME 高度，让编辑工具栏贴在键盘上方（非 App 底栏）
    final next = _readImeBottom();
    if ((next - _imeBottom).abs() >= 0.5 && mounted) {
      setState(() => _imeBottom = next);
    }
    // 2. 键盘收起且失焦时退出编辑态顶栏
    if (next < 8 && _editing && !_focus.hasFocus && !_titleFocus.hasFocus) {
      setState(() => _editing = false);
    }
  }

  Future<void> _load() async {
    // 1. 读取或新建笔记
    final notifier = ref.read(notesProvider.notifier);
    NoteItem? note = notifier.byId(widget.noteId);
    if (note == null && widget.noteId == 'new') {
      final id = notifier.create();
      note = notifier.byId(id);
      if (mounted) context.replace('/notes/edit/$id');
    }
    if (note == null) return;
    _note = note;
    _title.text = note.title;
    try {
      final doc = Document.fromJson(jsonDecode(note.deltaJson) as List);
      _quill.dispose();
      _quill = QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
      );
      _quill.addListener(() {
        if (mounted) setState(() {});
      });
    } catch (_) {
      _quill = QuillController.basic();
    }
    // 2. 初始化语音（失败则灰显）
    _speechAvailable = await _speech.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focus.removeListener(_onFocusChange);
    _titleFocus.removeListener(_onFocusChange);
    _title.dispose();
    _quill.dispose();
    _focus.dispose();
    _titleFocus.dispose();
    _speech.stop();
    super.dispose();
  }

  void _done() {
    _save();
    _focus.unfocus();
    _titleFocus.unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _editing = false);
  }

  void _back() {
    _save();
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final note = _note;
    final plain = _quill.document.toPlainText().trim();
    final meta = note == null
        ? ''
        : '${_fmt(note.updatedAt)} | ${plain.characters.length} 字 | ${note.notebook}';

    // 1. 有键盘时贴 IME 上方；无键盘时避让系统底安全区（不是 App 底栏）
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final bottomInset = _imeBottom > 0 ? _imeBottom : safeBottom;

    return Material(
      color: AppColors.surface,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: bottomInset),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _TopBar(
                editing: _editing || _imeBottom > 0,
                canUndo: _quill.hasUndo,
                canRedo: _quill.hasRedo,
                onBack: _back,
                onUndo: () {
                  _quill.undo();
                  setState(() {});
                },
                onRedo: () {
                  _quill.redo();
                  setState(() {});
                },
                onDone: _done,
              ),
              const ColoredBox(
                color: AppColors.stroke,
                child: SizedBox(height: 1, width: double.infinity),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.sm,
                  AppSpacing.page,
                  0,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AppText(meta, role: AppTextRole.caption),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.md,
                  AppSpacing.page,
                  0,
                ),
                child: TextField(
                  controller: _title,
                  focusNode: _titleFocus,
                  cursorColor: AppColors.primary,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                    backgroundColor: Color(0x00000000),
                  ),
                  decoration: const InputDecoration(
                    hintText: '标题',
                    hintStyle: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.inkMuted,
                      backgroundColor: Color(0x00000000),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    filled: false,
                    fillColor: Color(0x00000000),
                  ),
                  spellCheckConfiguration:
                      const SpellCheckConfiguration.disabled(),
                ),
              ),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.page),
                  child: QuillEditor.basic(
                    controller: _quill,
                    focusNode: _focus,
                    config: QuillEditorConfig(
                      padding: EdgeInsets.zero,
                      customStyles: DefaultStyles(
                        paragraph: DefaultTextBlockStyle(
                          const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: AppColors.ink,
                            backgroundColor: Color(0x00000000),
                          ),
                          HorizontalSpacing.zero,
                          VerticalSpacing.zero,
                          VerticalSpacing.zero,
                          null,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              _EditorToolbar(
                listening: _listening,
                speechAvailable: _speechAvailable,
                onChecklist: () =>
                    _quill.formatSelection(Attribute.unchecked),
                onFormat: _openFormat,
                onMic: _speechAvailable ? _toggleSpeech : null,
                onPen: () {},
                onAdd: () => showAppSheet<void>(
                  context: context,
                  builder: (ctx) => NoteAddSheet(
                    onPick: (action) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$action 稍后支持')),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 打开格式面板：先收起键盘，避免与格式工具叠在一起。
  Future<void> _openFormat() async {
    // 1. 失焦并强制隐藏 IME（格式只改样式，不需要输入）
    _focus.unfocus();
    _titleFocus.unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
    await SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
    if (!mounted) return;
    setState(() => _editing = false);
    // 2. 再弹出格式 Sheet，贴屏幕底部而非键盘上方
    await showAppSheet<void>(
      context: context,
      avoidIme: false,
      builder: (ctx) => NoteFormatSheet(controller: _quill),
    );
  }

  Future<void> _toggleSpeech() async {
    if (_listening) {
      await _speech.stop();
      setState(() => _listening = false);
      return;
    }
    setState(() => _listening = true);
    await _speech.listen(
      onResult: (result) {
        if (!result.finalResult) return;
        final text = result.recognizedWords;
        if (text.isEmpty) return;
        final index = _quill.selection.baseOffset;
        _quill.document.insert(index < 0 ? 0 : index, text);
        setState(() => _listening = false);
      },
      listenOptions: SpeechListenOptions(
        listenFor: const Duration(seconds: 20),
      ),
    );
  }

  void _save() {
    final id = _note?.id ?? widget.noteId;
    if (id == 'new') return;
    final delta = jsonEncode(_quill.document.toDelta().toJson());
    final plain = _quill.document.toPlainText().trim();
    ref.read(notesProvider.notifier).save(
          id: id,
          title: _title.text,
          deltaJson: delta,
          plainPreview: plain,
        );
  }

  String _fmt(DateTime d) =>
      '${d.year}/${d.month}/${d.day} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

/// 浏览态：返回 / 分享 / 更多；编辑态：撤销重做 / 完成。
class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.editing,
    required this.canUndo,
    required this.canRedo,
    required this.onBack,
    required this.onUndo,
    required this.onRedo,
    required this.onDone,
  });

  final bool editing;
  final bool canUndo;
  final bool canRedo;
  final VoidCallback onBack;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.page,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: const AppIcon(LucideIcons.arrowLeft, size: 24),
          ),
          if (editing) ...[
            const Spacer(),
            GestureDetector(
              onTap: canUndo ? onUndo : null,
              child: AppIcon(
                LucideIcons.undo2,
                color: canUndo ? AppColors.ink : AppColors.inkMuted,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            GestureDetector(
              onTap: canRedo ? onRedo : null,
              child: AppIcon(
                LucideIcons.redo2,
                color: canRedo ? AppColors.ink : AppColors.inkMuted,
              ),
            ),
            const Spacer(),
            const AppIcon(LucideIcons.ellipsisVertical),
            const SizedBox(width: AppSpacing.md),
            GestureDetector(
              onTap: onDone,
              child: const AppIcon(
                LucideIcons.check,
                color: AppColors.primary,
              ),
            ),
          ] else ...[
            const Spacer(),
            const AppIcon(LucideIcons.share2),
            const SizedBox(width: AppSpacing.md),
            const AppIcon(LucideIcons.ellipsisVertical),
          ],
        ],
      ),
    );
  }
}

class _EditorToolbar extends StatelessWidget {
  const _EditorToolbar({
    required this.listening,
    required this.speechAvailable,
    required this.onChecklist,
    required this.onFormat,
    required this.onMic,
    required this.onPen,
    required this.onAdd,
  });

  final bool listening;
  final bool speechAvailable;
  final VoidCallback onChecklist;
  final VoidCallback onFormat;
  final VoidCallback? onMic;
  final VoidCallback onPen;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.stroke)),
        color: AppColors.surface,
      ),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _Tool(icon: LucideIcons.listTodo, onTap: onChecklist),
          _Tool(icon: LucideIcons.type, onTap: onFormat),
          _Tool(
            icon: listening ? LucideIcons.circleDot : LucideIcons.mic,
            color: speechAvailable
                ? (listening ? AppColors.expense : AppColors.ink)
                : AppColors.inkMuted,
            onTap: onMic,
          ),
          _Tool(icon: LucideIcons.penLine, onTap: onPen),
          _Tool(
            icon: LucideIcons.circlePlus,
            onTap: onAdd,
            badge: true,
          ),
        ],
      ),
    );
  }
}

class _Tool extends StatelessWidget {
  const _Tool({
    required this.icon,
    this.onTap,
    this.color,
    this.badge = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AppIcon(
              icon,
              size: 24,
              color:
                  color ?? (onTap == null ? AppColors.inkMuted : AppColors.ink),
            ),
            if (badge)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.expense,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
