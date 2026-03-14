import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/question_bank/practice_report_models.dart';
import '../../i18n/locale_keys.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

class ChapterStatsCard extends StatelessWidget {
  const ChapterStatsCard({
    required this.stats,
    super.key,
  });

  final List<PracticeReportStatData> stats;

  @override
  Widget build(BuildContext context) {
    return QuestionBankStatsCard(
      title: LocaleKeys.practiceReportChapterTitle.tr,
      emptyText: LocaleKeys.practiceReportNoStats.tr,
      stats: stats,
    );
  }
}

class QuestionBankStatsCard extends StatelessWidget {
  const QuestionBankStatsCard({
    required this.title,
    required this.emptyText,
    required this.stats,
    super.key,
  });

  final String title;
  final String emptyText;
  final List<PracticeReportStatData> stats;

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
            title,
            style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.md),
          if (stats.isEmpty)
            Text(emptyText, style: AppTextStyles.body)
          else
            ...stats.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name.trim().isEmpty ? '--' : item.name,
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          '${item.correctCount}/${item.totalCount}',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    LinearProgressIndicator(
                      value: (item.correctRate / 100).clamp(0.0, 1.0),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(AppRadius.small),
                      backgroundColor: AppColors.buttonLight,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
