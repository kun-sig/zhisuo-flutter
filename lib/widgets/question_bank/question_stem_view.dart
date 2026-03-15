import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/question_bank/question_display_models.dart';
import '../../i18n/locale_keys.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

class QuestionStemView extends StatelessWidget {
  const QuestionStemView({
    required this.data,
    this.showCardDecoration = true,
    super.key,
  });

  final QuestionDisplayData data;
  final bool showCardDecoration;

  /// 统一渲染题目头部和题干区域，供练习页、错题页等模块共享题目展示协议。
  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (data.title.trim().isNotEmpty) ...[
          Text(
            data.title.trim(),
            style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (data.tags.isNotEmpty)
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: data.tags
                .where((tag) => tag.text.trim().isNotEmpty)
                .map((tag) => _Tag(text: tag.text.trim()))
                .toList(),
          ),
        if (data.body.trim().isNotEmpty || data.title.trim().isEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            data.body.trim().isEmpty
                ? LocaleKeys.practiceSessionNoStem.tr
                : data.body.trim(),
            style: AppTextStyles.bodyLarge.copyWith(height: 1.7),
          ),
        ],
      ],
    );
    if (!showCardDecoration) {
      return content;
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: content,
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.buttonLight,
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(color: AppColors.primary),
      ),
    );
  }
}
