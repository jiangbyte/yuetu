import 'package:flutter/widgets.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_text.dart';

/// 首页占位：品牌主视觉 + 一句说明 + 自绘按钮（无业务逻辑）。
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(flex: 2),
          // 1. 品牌名作为首屏主信号
          const AppText(AppConstants.appName, role: AppTextRole.display),
          const SizedBox(height: AppSpacing.md),
          // 2. 一句支撑文案，说明当前是空白壳
          const AppText(
            AppConstants.appTagline,
            role: AppTextRole.body,
          ),
          const SizedBox(height: AppSpacing.xl),
          // 3. 自绘主按钮，演示交互入口挂载方式
          AppButton(
            label: '开始',
            onPressed: () {},
          ),
          const Spacer(flex: 3),
          const AppText(
            'Android · iOS · Web · Linux · macOS · Windows',
            role: AppTextRole.caption,
          ),
        ],
      ),
    );
  }
}
