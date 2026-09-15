import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// 自由输入分类 + 下方建议 chips。
class SuggestCategory extends StatefulWidget {
  const SuggestCategory({
    super.key,
    required this.value,
    required this.suggestions,
    required this.onChanged,
    this.hint = '分类',
  });

  final String value;
  final List<String> suggestions;
  final ValueChanged<String> onChanged;
  final String hint;

  @override
  State<SuggestCategory> createState() => _SuggestCategoryState();
}

class _SuggestCategoryState extends State<SuggestCategory> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant SuggestCategory oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.text = widget.value;
      _controller.selection =
          TextSelection.collapsed(offset: widget.value.length);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          onChanged: widget.onChanged,
          decoration: InputDecoration(hintText: widget.hint),
        ),
        if (widget.suggestions.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.suggestions.map((s) {
              final selected = s == widget.value;
              return ChoiceChip(
                label: Text(s),
                selected: selected,
                onSelected: (_) => widget.onChanged(s),
                selectedColor: AppColors.accentSoft,
                labelStyle: TextStyle(
                  color: selected ? AppColors.accentDeep : AppColors.text,
                  fontSize: 13,
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
