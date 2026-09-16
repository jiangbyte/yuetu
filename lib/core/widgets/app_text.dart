import 'package:flutter/widgets.dart';

import '../theme/tokens.dart';

/// 文字角色。
enum AppTextRole { display, pageTitle, title, body, label, caption }

/// 自建排版文字（强制无背景，避免黄底高亮）。
class AppText extends StatelessWidget {
  const AppText(
    this.data, {
    super.key,
    this.role = AppTextRole.body,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.weight,
  });

  final String data;
  final AppTextRole role;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final FontWeight? weight;

  @override
  Widget build(BuildContext context) {
    final base = switch (role) {
      AppTextRole.display => TextStyle(
          fontSize: AppTypography.display,
          fontWeight: weight ?? AppTypography.bold,
          height: 1.2,
          color: color ?? AppColors.ink,
        ),
      AppTextRole.pageTitle => TextStyle(
          fontSize: AppTypography.pageTitle,
          fontWeight: weight ?? AppTypography.bold,
          height: 1.25,
          color: color ?? AppColors.ink,
        ),
      AppTextRole.title => TextStyle(
          fontSize: AppTypography.title,
          fontWeight: weight ?? AppTypography.bold,
          height: 1.3,
          color: color ?? AppColors.ink,
        ),
      AppTextRole.body => TextStyle(
          fontSize: AppTypography.body,
          fontWeight: weight ?? AppTypography.regular,
          height: 1.5,
          color: color ?? AppColors.ink,
        ),
      AppTextRole.label => TextStyle(
          fontSize: AppTypography.label,
          fontWeight: weight ?? AppTypography.medium,
          height: 1.2,
          color: color ?? AppColors.ink,
        ),
      AppTextRole.caption => TextStyle(
          fontSize: AppTypography.caption,
          fontWeight: weight ?? AppTypography.regular,
          height: 1.4,
          color: color ?? AppColors.inkMuted,
        ),
    };

    return Text(
      data,
      style: base.copyWith(backgroundColor: const Color(0x00000000)),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
