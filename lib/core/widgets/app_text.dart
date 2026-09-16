import 'package:flutter/widgets.dart';

import '../theme/tokens.dart';

/// 文字角色：对应 Design Token 中的排版层级。
enum AppTextRole { display, title, body, label, caption }

/// 自建排版文字，不依赖 Material 默认 Text 主题样式名。
class AppText extends StatelessWidget {
  const AppText(
    this.data, {
    super.key,
    this.role = AppTextRole.body,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  final String data;
  final AppTextRole role;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    // 1. 按角色映射字号/字重/默认色
    final style = switch (role) {
      AppTextRole.display => TextStyle(
          fontSize: AppTypography.display,
          fontWeight: AppTypography.bold,
          height: 1.15,
          letterSpacing: -0.8,
          color: color ?? AppColors.ink,
        ),
      AppTextRole.title => TextStyle(
          fontSize: AppTypography.title,
          fontWeight: AppTypography.medium,
          height: 1.3,
          color: color ?? AppColors.ink,
        ),
      AppTextRole.body => TextStyle(
          fontSize: AppTypography.body,
          fontWeight: AppTypography.regular,
          height: 1.5,
          color: color ?? AppColors.inkMuted,
        ),
      AppTextRole.label => TextStyle(
          fontSize: AppTypography.label,
          fontWeight: AppTypography.medium,
          height: 1.2,
          color: color ?? AppColors.ink,
        ),
      AppTextRole.caption => TextStyle(
          fontSize: AppTypography.caption,
          fontWeight: AppTypography.regular,
          height: 1.4,
          color: color ?? AppColors.inkMuted,
        ),
    };

    // 2. 用基础 Text 渲染，避免引入 Material DefaultTextStyle 语义
    return Text(
      data,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
