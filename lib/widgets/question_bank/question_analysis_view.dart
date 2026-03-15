import 'package:flutter/material.dart';

import '../../data/models/question_bank/question_display_models.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

class QuestionAnalysisView extends StatelessWidget {
  const QuestionAnalysisView({
    super.key,
    required this.data,
    required this.emptyText,
  });

  final QuestionAnalysisDisplayData data;
  final String emptyText;

  /// 统一渲染题目解析区域，便于练习页和后续资产页共享解析展示样式。
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.title.trim(),
            style: AppTextStyles.title.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            data.content.trim().isEmpty ? emptyText : data.content.trim(),
            style: AppTextStyles.body.copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }
}
