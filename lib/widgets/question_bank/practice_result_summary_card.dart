import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../i18n/locale_keys.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

class PracticeResultSummaryCard extends StatelessWidget {
  const PracticeResultSummaryCard({
    required this.correctRate,
    required this.correctCount,
    required this.wrongCount,
    required this.durationSeconds,
    super.key,
  });

  final double correctRate;
  final int correctCount;
  final int wrongCount;
  final int durationSeconds;

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
            LocaleKeys.practiceReportSummaryTitle.tr,
            style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  label: LocaleKeys.practiceReportSummaryAccuracy.tr,
                  value: '${correctRate.toStringAsFixed(0)}%',
                ),
              ),
              Expanded(
                child: _Metric(
                  label: LocaleKeys.practiceReportSummaryCorrect.tr,
                  value: '$correctCount',
                ),
              ),
              Expanded(
                child: _Metric(
                  label: LocaleKeys.practiceReportSummaryWrong.tr,
                  value: '$wrongCount',
                ),
              ),
              Expanded(
                child: _Metric(
                  label: LocaleKeys.practiceReportSummaryDuration.tr,
                  value: _formatDuration(durationSeconds),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTextStyles.headline.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

String _formatDuration(int seconds) {
  if (seconds <= 0) {
    return '0m';
  }
  final minutes = seconds ~/ 60;
  final remains = seconds % 60;
  if (minutes <= 0) {
    return '${remains}s';
  }
  return '${minutes}m';
}
