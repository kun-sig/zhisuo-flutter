import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../data/models/question_bank/question_display_models.dart';
import '../../i18n/locale_keys.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/question_bank/question_asset_card.dart';
import '../../widgets/question_bank/question_stem_view.dart';
import 'wrong_book_controller.dart';

class WrongBookPage extends GetView<WrongBookController> {
  const WrongBookPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(LocaleKeys.wrongBookTitle.tr),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!controller.hasSubject) {
            return _EmptyState(message: LocaleKeys.wrongBookNeedSubject.tr);
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
                  filterCount: controller.filterCount,
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
                    message: LocaleKeys.wrongBookEmpty.tr,
                    sliverFriendly: true,
                  )
                else
                  ...controller.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _WrongQuestionCard(
                        questionId: item.questionId,
                        wrongCount: item.wrongCount,
                        lastWrongAt: item.lastWrongAt,
                        statusText: controller.resolveStatusText(item.status),
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

class _FilterCard extends StatelessWidget {
  const _FilterCard({
    required this.controller,
  });

  final WrongBookController controller;

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
            LocaleKeys.wrongBookFilterTitle.tr,
            style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: controller.chapterIdController,
            decoration: InputDecoration(
              labelText: LocaleKeys.wrongBookFilterChapterId.tr,
              hintText: LocaleKeys.wrongBookFilterChapterHint.tr,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: controller.questionCategoryIdController,
            decoration: InputDecoration(
              labelText: LocaleKeys.wrongBookFilterQuestionCategoryId.tr,
              hintText: LocaleKeys.wrongBookFilterQuestionCategoryHint.tr,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              ElevatedButton(
                onPressed: controller.applyFilters,
                child: Text(LocaleKeys.wrongBookFilterApply.tr),
              ),
              OutlinedButton(
                onPressed: controller.clearFilters,
                child: Text(LocaleKeys.wrongBookFilterClear.tr),
              ),
              FilledButton.tonal(
                onPressed: controller.startRetryPractice,
                child: Text(LocaleKeys.wrongBookRetryAction.tr),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            LocaleKeys.wrongBookFilterTip.tr,
            style: AppTextStyles.caption,
          ),
          if (controller.retryPracticeStatusText.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _RetryStatusBanner(
              message: controller.retryPracticeStatusText,
              isReady: controller.isRetryPracticeReady,
            ),
          ],
        ],
      ),
    );
  }
}

class _RetryStatusBanner extends StatelessWidget {
  const _RetryStatusBanner({
    required this.message,
    required this.isReady,
  });

  final String message;
  final bool isReady;

  @override
  Widget build(BuildContext context) {
    final accent = isReady ? AppColors.success : AppColors.warning;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: accent.withValues(alpha: 0.18),
        ),
      ),
      child: Text(
        message.trim(),
        style: AppTextStyles.body.copyWith(color: accent),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.subjectName,
    required this.totalSize,
    required this.filterCount,
  });

  final String subjectName;
  final int totalSize;
  final int filterCount;

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
              label: LocaleKeys.wrongBookSummarySubject.tr,
              value: subjectName.trim().isEmpty ? '--' : subjectName.trim(),
            ),
          ),
          Expanded(
            child: _Metric(
              label: LocaleKeys.wrongBookSummaryTotal.tr,
              value: '$totalSize',
            ),
          ),
          Expanded(
            child: _Metric(
              label: LocaleKeys.wrongBookSummaryFilters.tr,
              value: '$filterCount',
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

class _WrongQuestionCard extends StatelessWidget {
  const _WrongQuestionCard({
    required this.questionId,
    required this.wrongCount,
    required this.lastWrongAt,
    required this.statusText,
  });

  final String questionId;
  final int wrongCount;
  final DateTime? lastWrongAt;
  final String statusText;

  @override
  Widget build(BuildContext context) {
    final questionDisplayData = QuestionDisplayData.fromWrongQuestionAsset(
      questionId: questionId,
      wrongCount: wrongCount,
      statusText: statusText,
    );
    return QuestionAssetCard(
      title: questionId,
      header: QuestionStemView(
        data: questionDisplayData,
        showCardDecoration: false,
      ),
      metaItems: [
        QuestionAssetMetaItem(
          label: LocaleKeys.wrongBookWrongCount.tr,
          value: '$wrongCount',
        ),
        QuestionAssetMetaItem(
          label: LocaleKeys.wrongBookLastWrongAt.tr,
          value: _formatDateTime(lastWrongAt),
        ),
        QuestionAssetMetaItem(
          label: LocaleKeys.wrongBookStatus.tr,
          value: statusText.trim().isEmpty
              ? LocaleKeys.wrongBookStatusUnknown.tr
              : statusText.trim(),
        ),
      ],
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
            LocaleKeys.wrongBookNoMore.tr,
            style: AppTextStyles.caption,
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: OutlinedButton(
        onPressed: onLoadMore,
        child: Text(LocaleKeys.wrongBookLoadMore.tr),
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
              child: Text(LocaleKeys.wrongBookRetry.tr),
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
