import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../i18n/locale_keys.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import 'practice_history_controller.dart';

class PracticeHistoryPage extends GetView<PracticeHistoryController> {
  const PracticeHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(LocaleKeys.practiceHistoryTitle.tr),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!controller.hasSubject) {
            return _EmptyState(
              message: LocaleKeys.practiceHistoryNeedSubject.tr,
            );
          }

          if (controller.errorText.value.isNotEmpty &&
              controller.items.isEmpty) {
            return _ErrorState(
              message: controller.errorText.value,
              onRetry: controller.retry,
            );
          }

          if (controller.items.isEmpty) {
            return RefreshIndicator(
              onRefresh: controller.refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 120),
                  _EmptyState(
                    message: LocaleKeys.practiceHistoryEmpty.tr,
                    sliverFriendly: true,
                  ),
                ],
              ),
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
                if (controller.errorText.value.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  _ErrorBanner(message: controller.errorText.value),
                ],
                const SizedBox(height: AppSpacing.md),
                ...controller.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _PracticeRecordCard(
                      modeText: item.practiceMode,
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
              label: LocaleKeys.practiceHistorySummarySubject.tr,
              value: subjectName.trim().isEmpty ? '--' : subjectName.trim(),
            ),
          ),
          Expanded(
            child: _Metric(
              label: LocaleKeys.practiceHistorySummaryTotal.tr,
              value: '$totalSize',
            ),
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

class _PracticeRecordCard extends StatelessWidget {
  const _PracticeRecordCard({
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
            LocaleKeys.practiceHistoryNoMore.tr,
            style: AppTextStyles.caption,
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: OutlinedButton(
        onPressed: onLoadMore,
        child: Text(LocaleKeys.practiceHistoryLoadMore.tr),
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
              child: Text(LocaleKeys.practiceHistoryRetry.tr),
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
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
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
  return DateFormat('yyyy-MM-dd HH:mm').format(value.toLocal());
}

String _formatDuration(int seconds) {
  if (seconds <= 0) {
    return '0m';
  }
  final duration = Duration(seconds: seconds);
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final secs = duration.inSeconds.remainder(60);

  if (hours > 0) {
    return '${hours}h ${minutes}m';
  }
  if (minutes > 0) {
    return '${minutes}m ${secs}s';
  }
  return '${secs}s';
}
