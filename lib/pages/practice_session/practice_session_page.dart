import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../i18n/locale_keys.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/question_bank/practice_progress_header.dart';
import '../../widgets/question_bank/question_option_group_view.dart';
import '../../widgets/question_bank/question_stem_view.dart';
import 'practice_session_controller.dart';

class PracticeSessionPage extends GetView<PracticeSessionController> {
  const PracticeSessionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        if (await controller.confirmExit()) {
          Get.back<void>();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Obx(() => Text(controller.pageTitle)),
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            onPressed: () async {
              if (await controller.confirmExit()) {
                Get.back<void>();
              }
            },
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
        ),
        body: SafeArea(
          child: Obx(() {
            if (controller.isPageLoading.value && controller.data == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.errorText.value.isNotEmpty &&
                controller.data == null) {
              return _ErrorState(
                message: controller.errorText.value,
                onRetry: controller.retry,
              );
            }

            final detail = controller.data;
            final question = controller.currentQuestion;
            if (detail == null || question == null) {
              return _EmptyState(
                message: LocaleKeys.practiceSessionEmpty.tr,
              );
            }

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                _SessionContextCard(
                  unitTitle: controller.pageTitle,
                  categoryName: controller.categoryDisplayName,
                  progressStatusText: controller.unitProgressStatusText,
                  doneCountText: controller.unitDoneCountText,
                  accuracyText: controller.unitCorrectRateText,
                  sessionCountText: controller.unitSessionCountText,
                ),
                const SizedBox(height: AppSpacing.lg),
                PracticeProgressHeader(
                  title: controller.pageTitle,
                  currentNumber: controller.currentIndex.value + 1,
                  totalCount: detail.session.questionCount,
                  answeredCount: detail.session.answeredCount,
                  remainingCount: detail.remainingCount,
                ),
                const SizedBox(height: AppSpacing.lg),
                QuestionStemView(
                  questionType: question.questionType,
                  stem: question.stem,
                  chapterName: question.chapterName,
                  questionCategoryName: question.questionCategoryName,
                ),
                const SizedBox(height: AppSpacing.lg),
                if (question.options.isNotEmpty)
                  QuestionOptionGroupView(
                    options: question.options,
                    selectedAnswers: controller.selectedAnswers,
                    onTap: controller.selectOption,
                  )
                else
                  _EmptyState(
                    message: LocaleKeys.practiceSessionNoOptions.tr,
                    compact: true,
                  ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.large),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LocaleKeys.practiceSessionAnalysisTitle.tr,
                        style: AppTextStyles.title.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        question.analysis.trim().isEmpty
                            ? LocaleKeys.practiceSessionNoAnalysis.tr
                            : question.analysis.trim(),
                        style: AppTextStyles.body.copyWith(height: 1.6),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: controller.currentIndex.value > 0 &&
                                !controller.isSubmitLoading.value &&
                                !controller.isFinishLoading.value
                            ? controller.goPrevious
                            : null,
                        child: Text(LocaleKeys.practiceSessionPrevious.tr),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: !controller.isSubmitLoading.value &&
                                !controller.isFinishLoading.value
                            ? controller.submitCurrentAnswer
                            : null,
                        child: Text(
                          controller.isSubmitLoading.value
                              ? LocaleKeys.practiceSessionSubmitting.tr
                              : LocaleKeys.practiceSessionSubmit.tr,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonal(
                    onPressed: !controller.isFinishLoading.value &&
                            !controller.isSubmitLoading.value
                        ? controller.finishPractice
                        : null,
                    child: Text(
                      controller.isFinishLoading.value
                          ? LocaleKeys.practiceSessionFinishing.tr
                          : LocaleKeys.practiceSessionFinish.tr,
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
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
              child: Text(LocaleKeys.practiceSessionRetry.tr),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionContextCard extends StatelessWidget {
  const _SessionContextCard({
    required this.unitTitle,
    required this.categoryName,
    required this.progressStatusText,
    required this.doneCountText,
    required this.accuracyText,
    required this.sessionCountText,
  });

  final String unitTitle;
  final String categoryName;
  final String progressStatusText;
  final String doneCountText;
  final String accuracyText;
  final String sessionCountText;

  /// 展示当前练习单元的上下文和聚合进度，帮助用户理解当前会话位置。
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
          Row(
            children: [
              Expanded(
                child: Text(
                  unitTitle.trim().isEmpty ? '--' : unitTitle.trim(),
                  style: AppTextStyles.title.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                child: Text(
                  progressStatusText,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${LocaleKeys.practiceSessionContextCategory.tr}: $categoryName',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _ContextMetric(
                  label: LocaleKeys.practiceSessionContextDone.tr,
                  value: doneCountText,
                ),
              ),
              Expanded(
                child: _ContextMetric(
                  label: LocaleKeys.practiceSessionContextAccuracy.tr,
                  value: accuracyText,
                ),
              ),
              Expanded(
                child: _ContextMetric(
                  label: LocaleKeys.practiceSessionContextSessions.tr,
                  value: sessionCountText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContextMetric extends StatelessWidget {
  const _ContextMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  /// 展示单元上下文卡片内的单个统计指标。
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.message,
    this.compact = false,
  });

  final String message;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final child = Container(
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
    );

    if (compact) {
      return child;
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: child,
      ),
    );
  }
}
