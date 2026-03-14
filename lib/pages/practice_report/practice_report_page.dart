import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../i18n/locale_keys.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/question_bank/chapter_stats_card.dart';
import '../../widgets/question_bank/practice_review_suggestion_card.dart';
import '../../widgets/question_bank/practice_result_summary_card.dart';
import '../../widgets/question_bank/question_category_stats_card.dart';
import 'practice_report_controller.dart';

class PracticeReportPage extends GetView<PracticeReportController> {
  const PracticeReportPage({super.key});

  /// 组织练习报告页的摘要、建议、统计和错题区域，保证完成练习后的信息完整可见。
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Obx(() => Text(controller.pageTitle)),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorText.value.isNotEmpty &&
              controller.data == null) {
            return _ErrorState(
              message: controller.errorText.value,
              onRetry: controller.retry,
            );
          }

          final report = controller.data;
          if (report == null) {
            return _EmptyState(message: LocaleKeys.practiceReportEmpty.tr);
          }

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              _ReportContextCard(
                unitTitle: controller.pageTitle,
                categoryName: controller.categoryDisplayName,
                unitId: controller.unitIdText,
                reportId: report.reportId,
              ),
              const SizedBox(height: AppSpacing.lg),
              PracticeResultSummaryCard(
                correctRate: report.correctRate,
                correctCount: report.correctCount,
                wrongCount: report.wrongCount,
                durationSeconds: report.durationSeconds,
              ),
              const SizedBox(height: AppSpacing.lg),
              PracticeReviewSuggestionCard(
                suggestions: controller.reviewSuggestions,
              ),
              const SizedBox(height: AppSpacing.lg),
              ChapterStatsCard(stats: report.chapterStats),
              const SizedBox(height: AppSpacing.lg),
              QuestionCategoryStatsCard(stats: report.questionCategoryStats),
              const SizedBox(height: AppSpacing.lg),
              _WrongQuestionCard(questionIds: report.wrongQuestionIds),
            ],
          );
        }),
      ),
    );
  }
}

class _ReportContextCard extends StatelessWidget {
  const _ReportContextCard({
    required this.unitTitle,
    required this.categoryName,
    required this.unitId,
    required this.reportId,
  });

  final String unitTitle;
  final String categoryName;
  final String unitId;
  final String reportId;

  /// 展示练习报告所属单元的上下文，帮助用户确认当前报告归属。
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
            unitTitle.trim().isEmpty ? '--' : unitTitle.trim(),
            style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.md),
          _InfoRow(
            label: LocaleKeys.practiceReportContextCategory.tr,
            value: categoryName,
          ),
          _InfoRow(
            label: LocaleKeys.practiceReportContextUnitId.tr,
            value: unitId,
          ),
          _InfoRow(
            label: LocaleKeys.practiceReportContextReportId.tr,
            value: reportId.trim().isEmpty ? '--' : reportId.trim(),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  /// 展示报告上下文中的单行键值信息。
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(label, style: AppTextStyles.caption),
          ),
          Expanded(
            child: Text(value, style: AppTextStyles.body),
          ),
        ],
      ),
    );
  }
}

class _WrongQuestionCard extends StatelessWidget {
  const _WrongQuestionCard({
    required this.questionIds,
  });

  final List<String> questionIds;

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
            LocaleKeys.practiceReportWrongTitle.tr,
            style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.md),
          if (questionIds.isEmpty)
            Text(
              LocaleKeys.practiceReportNoWrongQuestions.tr,
              style: AppTextStyles.body,
            )
          else
            ...questionIds.map(
              (id) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(id, style: AppTextStyles.body),
              ),
            ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(LocaleKeys.practiceReportRetry.tr),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.large),
          ),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}
