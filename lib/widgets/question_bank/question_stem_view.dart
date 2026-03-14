import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../i18n/locale_keys.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

class QuestionStemView extends StatelessWidget {
  const QuestionStemView({
    required this.questionType,
    required this.stem,
    required this.chapterName,
    required this.questionCategoryName,
    super.key,
  });

  final String questionType;
  final String stem;
  final String chapterName;
  final String questionCategoryName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              if (questionCategoryName.trim().isNotEmpty)
                _Tag(text: questionCategoryName),
              if (chapterName.trim().isNotEmpty) _Tag(text: chapterName),
              if (questionType.trim().isNotEmpty) _Tag(text: questionType),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            stem.trim().isEmpty
                ? LocaleKeys.practiceSessionNoStem.tr
                : stem.trim(),
            style: AppTextStyles.bodyLarge.copyWith(
              height: 1.7,
            ),
          ),
        ],
      ),
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
