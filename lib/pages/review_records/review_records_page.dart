import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../i18n/locale_keys.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import 'review_records_controller.dart';

class ReviewRecordsPage extends GetView<ReviewRecordsController> {
  const ReviewRecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(LocaleKeys.reviewRecordsTitle.tr),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!controller.hasSubject) {
            return _EmptyState(message: LocaleKeys.reviewRecordsNeedSubject.tr);
          }

          if (controller.errorText.value.isNotEmpty &&
              controller.items.isEmpty) {
            return _ErrorState(
              message: controller.errorText.value,
              onRetry: controller.retry,
            );
          }

          return RefreshIndicator(
            onRefresh: controller.refresh,
            child: ListView(
              controller: controller.scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                _SummaryCard(
                  subjectName: controller.subjectName,
                  totalSize: controller.totalSize.value,
                ),
                const SizedBox(height: AppSpacing.md),
                _FilterCard(controller: controller),
                if (controller.errorText.value.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  _ErrorBanner(message: controller.errorText.value),
                ],
                const SizedBox(height: AppSpacing.md),
                if (controller.items.isEmpty)
                  _EmptyState(
                    message: controller.hasFilter
                        ? LocaleKeys.reviewRecordsEmptyFiltered.tr
                        : LocaleKeys.reviewRecordsEmpty.tr,
                    sliverFriendly: true,
                  )
                else
                  ...controller.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _ReviewRecordCard(
                        modeText: item.displayTitle,
                        questionCount: item.questionCount,
                        correctCount: item.correctCount,
                        wrongCount: item.wrongCount,
                        correctRate: item.correctRate,
                        durationSeconds: item.durationSeconds,
                        finishedAt: item.finishedAt,
                        onOpenReport: () => controller.openReport(item),
                      ),
                    ),
                  ),
                _LoadMoreFooter(
                  hasMore: controller.hasMore.value,
                  isLoadingMore: controller.isLoadingMore.value,
                  onLoadMore: controller.loadMore,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.subjectName,
    required this.totalSize,
  });

  final String subjectName;
  final int totalSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Metric(
              label: LocaleKeys.reviewRecordsSummarySubject.tr,
              value: subjectName.trim().isEmpty ? '--' : subjectName.trim(),
            ),
          ),
          Expanded(
            child: _Metric(
              label: LocaleKeys.reviewRecordsSummaryTotal.tr,
              value: '$totalSize',
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterCard extends StatelessWidget {
  const _FilterCard({
    required this.controller,
  });

  final ReviewRecordsController controller;

  /// 构建正式分类筛选条，确保筛选请求直接对齐后端 `categoryCode` 契约。
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
            LocaleKeys.reviewRecordsFilterTitle.tr,
            style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: controller.modeOptions
                .map(
                  (option) => ChoiceChip(
                    label: Text(option.labelKey.tr),
                    selected:
                        controller.categoryCode.value == option.value.trim(),
                    onSelected: (_) =>
                        controller.changeCategoryCode(option.value),
                  ),
                )
                .toList(),
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

class _ReviewRecordCard extends StatelessWidget {
  const _ReviewRecordCard({
    required this.modeText,
    required this.questionCount,
    required this.correctCount,
    required this.wrongCount,
    required this.correctRate,
    required this.durationSeconds,
    required this.finishedAt,
    required this.onOpenReport,
  });

  final String modeText;
  final int questionCount;
  final int correctCount;
  final int wrongCount;
  final double correctRate;
  final int durationSeconds;
  final DateTime? finishedAt;
  final VoidCallback onOpenReport;

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
            modeText.trim().isEmpty ? '--' : modeText.trim(),
            style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.md),
          _InfoRow(
            label: LocaleKeys.practiceHistoryQuestionCount.tr,
            value: '$questionCount',
          ),
          _InfoRow(
            label: LocaleKeys.practiceHistoryCorrectCount.tr,
            value: '$correctCount',
          ),
          _InfoRow(
            label: LocaleKeys.practiceHistoryWrongCount.tr,
            value: '$wrongCount',
          ),
          _InfoRow(
            label: LocaleKeys.practiceHistoryCorrectRate.tr,
            value: '${correctRate.toStringAsFixed(0)}%',
          ),
          _InfoRow(
            label: LocaleKeys.practiceHistoryDuration.tr,
            value: _formatDuration(durationSeconds),
          ),
          _InfoRow(
            label: LocaleKeys.practiceHistoryFinishedAt.tr,
            value: _formatDateTime(finishedAt),
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: onOpenReport,
              child: Text(LocaleKeys.practiceHistoryViewReport.tr),
            ),
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: 88,
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
        style: AppTextStyles.body.copyWith(color: AppColors.error),
      ),
    );
  }
}

class _LoadMoreFooter extends StatelessWidget {
  const _LoadMoreFooter({
    required this.hasMore,
    required this.isLoadingMore,
    required this.onLoadMore,
  });

  final bool hasMore;
  final bool isLoadingMore;
  final Future<void> Function() onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (!hasMore) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.sm),
        child: Center(
          child: Text(
            LocaleKeys.reviewRecordsNoMore.tr,
            style: AppTextStyles.caption,
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Center(
        child: OutlinedButton(
          onPressed: () => onLoadMore(),
          child: Text(LocaleKeys.reviewRecordsLoadMore.tr),
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
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(
              onPressed: () => onRetry(),
              child: Text(LocaleKeys.reviewRecordsRetry.tr),
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
    this.sliverFriendly = false,
  });

  final String message;
  final bool sliverFriendly;

  @override
  Widget build(BuildContext context) {
    final child = Padding(
      padding: EdgeInsets.all(sliverFriendly ? AppSpacing.lg : AppSpacing.xl),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
      ),
    );

    if (sliverFriendly) {
      return child;
    }
    return Center(child: child);
  }
}

String _formatDateTime(DateTime? value) {
  if (value == null) {
    return '--';
  }
  return DateFormat('yyyy-MM-dd HH:mm').format(value);
}

String _formatDuration(int seconds) {
  if (seconds <= 0) {
    return '--';
  }
  final minutes = seconds ~/ 60;
  final remainSeconds = seconds % 60;
  if (minutes <= 0) {
    return '$remainSeconds s';
  }
  return '$minutes m $remainSeconds s';
}
