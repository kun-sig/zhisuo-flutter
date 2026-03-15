import 'package:flutter/material.dart';

import '../../data/models/question_bank/question_display_models.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

class QuestionFeedbackBanner extends StatelessWidget {
  const QuestionFeedbackBanner({
    super.key,
    required this.data,
  });

  final QuestionFeedbackDisplayData data;

  /// 统一展示答题反馈状态，便于后续在错题详情、报告页复用同一反馈样式。
  @override
  Widget build(BuildContext context) {
    final color = _resolveColor(data.color);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: color.withValues(alpha: 0.16),
        ),
      ),
      child: Text(
        data.label.trim(),
        style: AppTextStyles.body.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  /// 使用字符串色值协议解耦页面与具体颜色实现，便于后续跨模块复用。
  Color _resolveColor(String value) {
    switch (value.trim().toLowerCase()) {
      case 'success':
        return AppColors.success;
      case 'error':
        return AppColors.error;
      case 'warning':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }
}
