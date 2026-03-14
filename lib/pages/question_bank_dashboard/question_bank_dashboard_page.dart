import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../i18n/locale_keys.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/current_subject_card.dart';
import '../../widgets/question_bank/asset_tool_grid.dart';
import '../../widgets/question_bank/continue_practice_card.dart';
import '../../widgets/question_bank/practice_category_section.dart';
import '../../widgets/question_bank/practice_unit_preview_list.dart';
import 'question_bank_dashboard_controller.dart';

class QuestionBankDashboardPage
    extends GetView<QuestionBankDashboardController> {
  const QuestionBankDashboardPage({super.key});

  /// 构建题库首页，按无科目、失败、空态和正常态分层渲染内容。
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() {
          final dashboard = controller.dashboard.value;
          final continueSession = controller.continueSession;

          return RefreshIndicator(
            onRefresh: () => controller.refreshDashboard(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      AppSpacing.xl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CurrentSubjectCard(
                          subjectName: controller.subjectName,
                          countdownText: controller.countdownText,
                          isLoading: controller.isLoading.value,
                          onTap: controller.openSubjectSelector,
                        ),
                        if (!controller.hasSubject) ...[
                          const SizedBox(height: AppSpacing.md),
                          _InfoBanner(
                            message: LocaleKeys
                                .questionBankDashboardNoSubjectBanner.tr,
                          ),
                        ],
                        if (controller.errorText.value.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.md),
                          _ErrorBanner(message: controller.errorText.value),
                        ],
                        if (continueSession != null) ...[
                          const SizedBox(height: AppSpacing.md),
                          ContinuePracticeCard(
                            session: continueSession,
                            onTap: controller.onContinueSessionTap,
                          ),
                        ],
                        const SizedBox(height: AppSpacing.xl),
                        _SectionHeader(
                          title:
                              LocaleKeys.questionBankDashboardPracticeTitle.tr,
                          trailing:
                              _UpdatedAtText(updatedAt: dashboard.updatedAt),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        if (dashboard.practiceCategories.isEmpty)
                          _EmptyBlock(
                            message: controller.hasSubject
                                ? LocaleKeys
                                    .questionBankDashboardEmptyCategories.tr
                                : LocaleKeys
                                    .questionBankDashboardNeedSubject.tr,
                          )
                        else
                          PracticeCategorySection(
                            categories: dashboard.practiceCategories,
                            onTap: controller.onPracticeCategoryTap,
                          ),
                        const SizedBox(height: AppSpacing.xl),
                        _SectionHeader(
                          title: LocaleKeys
                              .questionBankDashboardUnitPreviewTitle.tr,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        if (dashboard.practiceUnitsPreview.isEmpty)
                          _EmptyBlock(
                            message: controller.hasSubject
                                ? LocaleKeys.questionBankDashboardEmptyUnits.tr
                                : LocaleKeys
                                    .questionBankDashboardNeedSubject.tr,
                          )
                        else
                          PracticeUnitPreviewList(
                            units: dashboard.practiceUnitsPreview,
                            onTap: controller.onPracticeUnitTap,
                          ),
                        const SizedBox(height: AppSpacing.xl),
                        _SectionHeader(
                          title: LocaleKeys.questionBankDashboardAssetTitle.tr,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AssetToolGrid(
                          tools: dashboard.assetTools,
                          onTap: controller.onAssetToolTap,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        _SectionHeader(
                          title:
                              LocaleKeys.questionBankDashboardSummaryTitle.tr,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _SummaryCard(
                          doneCount:
                              dashboard.todaySummary?.doneQuestionCount ?? 0,
                          correctRate: dashboard.todaySummary?.correctRate ?? 0,
                          recentPracticeCount:
                              dashboard.todaySummary?.recentPracticeCount ?? 0,
                          pendingReviewWrongCount:
                              dashboard.todaySummary?.pendingReviewWrongCount ??
                                  0,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _EmptyBlock extends StatelessWidget {
  const _EmptyBlock({
    required this.message,
  });

  final String message;

  /// 构建首页空态卡片，统一承接无单元和无分类提示。
  @override
  Widget build(BuildContext context) {
    return Container(
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
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.message,
  });

  final String message;

  /// 构建首页信息提示，用于强调“无科目”这类非错误但需要处理的状态。
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Text(
        message,
        style: AppTextStyles.body.copyWith(
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.trailing,
  });

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: AppTextStyles.headline.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _UpdatedAtText extends StatelessWidget {
  const _UpdatedAtText({
    required this.updatedAt,
  });

  final DateTime? updatedAt;

  @override
  Widget build(BuildContext context) {
    if (updatedAt == null) {
      return const SizedBox.shrink();
    }
    final text = DateFormat('HH:mm').format(updatedAt!);
    return Text(
      '${LocaleKeys.questionBankDashboardUpdatedAt.tr} $text',
      style: AppTextStyles.caption,
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        message,
        style: AppTextStyles.body.copyWith(
          color: AppColors.error,
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.doneCount,
    required this.correctRate,
    required this.recentPracticeCount,
    required this.pendingReviewWrongCount,
  });

  final int doneCount;
  final double correctRate;
  final int recentPracticeCount;
  final int pendingReviewWrongCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryMetric(
              label: LocaleKeys.questionBankDashboardSummaryDone.tr,
              value: '$doneCount',
            ),
          ),
          Expanded(
            child: _SummaryMetric(
              label: LocaleKeys.questionBankDashboardSummaryAccuracy.tr,
              value: '${correctRate.toStringAsFixed(0)}%',
            ),
          ),
          Expanded(
            child: _SummaryMetric(
              label: LocaleKeys.questionBankDashboardSummaryRecent.tr,
              value: '$recentPracticeCount',
            ),
          ),
          Expanded(
            child: _SummaryMetric(
              label: LocaleKeys.questionBankDashboardSummaryPending.tr,
              value: '$pendingReviewWrongCount',
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
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
          style: AppTextStyles.headline.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppTextStyles.caption,
        ),
      ],
    );
  }
}
