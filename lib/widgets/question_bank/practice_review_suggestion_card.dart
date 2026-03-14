import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../i18n/locale_keys.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

class PracticeReviewSuggestionCard extends StatelessWidget {
  const PracticeReviewSuggestionCard({
    required this.suggestions,
    super.key,
  });

  final List<String> suggestions;

  /// 展示练习报告的复习建议列表，帮助用户按优先级继续复盘。
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
          Text(
            LocaleKeys.practiceReportSuggestionTitle.tr,
            style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.md),
          if (suggestions.isEmpty)
            Text(
              LocaleKeys.practiceReportNoStats.tr,
              style: AppTextStyles.body,
            )
          else
            ...List.generate(
              suggestions.length,
              (index) => Padding(
                padding: EdgeInsets.only(
                  bottom: index == suggestions.length - 1 ? 0 : AppSpacing.md,
                ),
                child: _SuggestionItem(
                  index: index,
                  content: suggestions[index],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SuggestionItem extends StatelessWidget {
  const _SuggestionItem({
    required this.index,
    required this.content,
  });

  final int index;
  final String content;

  /// 把单条建议包装成带序号的说明块，降低长文案阅读负担。
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.buttonLight,
              shape: BoxShape.circle,
            ),
            child: Text(
              '${index + 1}',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              content,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
