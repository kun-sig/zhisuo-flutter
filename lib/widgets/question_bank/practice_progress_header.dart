import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../i18n/locale_keys.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

class PracticeProgressHeader extends StatelessWidget {
  const PracticeProgressHeader({
    required this.title,
    required this.currentNumber,
    required this.totalCount,
    required this.answeredCount,
    required this.remainingCount,
    super.key,
  });

  final String title;
  final int currentNumber;
  final int totalCount;
  final int answeredCount;
  final int remainingCount;

  @override
  Widget build(BuildContext context) {
    final progress = totalCount <= 0 ? 0.0 : answeredCount / totalCount;

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
            title,
            style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 6,
            borderRadius: BorderRadius.circular(AppRadius.small),
            backgroundColor: AppColors.buttonLight,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Text(
                LocaleKeys.practiceSessionProgressIndex.trParams({
                  'current': '$currentNumber',
                  'total': '$totalCount',
                }),
                style: AppTextStyles.caption,
              ),
              const Spacer(),
              Text(
                LocaleKeys.practiceSessionProgressSummary.trParams({
                  'answered': '$answeredCount',
                  'remaining': '$remainingCount',
                }),
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
