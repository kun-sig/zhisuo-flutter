import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../i18n/locale_keys.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import 'qa_threads_controller.dart';

class QaThreadsPage extends GetView<QaThreadsController> {
  const QaThreadsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(LocaleKeys.qaThreadsTitle.tr),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.openCreateThreadDialog,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        label: Text(LocaleKeys.qaThreadsCreateAction.tr),
        icon: const Icon(Icons.edit_outlined),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!controller.hasSubject) {
            return _EmptyState(message: LocaleKeys.qaThreadsNeedSubject.tr);
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
                        ? LocaleKeys.qaThreadsEmptyFiltered.tr
                        : LocaleKeys.qaThreadsEmpty.tr,
                    sliverFriendly: true,
                  )
                else
                  ...controller.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _QaThreadCard(
                        title: item.title,
                        content: item.content,
                        questionId: item.questionId,
                        sessionId: item.sessionId,
                        replyCount: item.replies.length,
                        statusText: controller.resolveStatusText(item.status),
                        lastRepliedAt: item.lastRepliedAt,
                        onTap: () => controller.openThread(item),
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
              label: LocaleKeys.qaThreadsSummarySubject.tr,
              value: subjectName.trim().isEmpty ? '--' : subjectName.trim(),
            ),
          ),
          Expanded(
            child: _Metric(
              label: LocaleKeys.qaThreadsSummaryTotal.tr,
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

  final QaThreadsController controller;

  /// 用状态筛选统一管理开放中与已关闭线程，后续接通服务端更多筛选时无需改页面骨架。
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
            LocaleKeys.qaThreadsFilterTitle.tr,
            style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: controller.statusOptions
                .map(
                  (option) => ChoiceChip(
                    label: Text(option.labelKey.tr),
                    selected: controller.status.value == option.value.trim(),
                    onSelected: (_) => controller.changeStatus(option.value),
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

class _QaThreadCard extends StatelessWidget {
  const _QaThreadCard({
    required this.title,
    required this.content,
    required this.questionId,
    required this.sessionId,
    required this.replyCount,
    required this.statusText,
    required this.lastRepliedAt,
    required this.onTap,
  });

  final String title;
  final String content;
  final String questionId;
  final String sessionId;
  final int replyCount;
  final String statusText;
  final DateTime? lastRepliedAt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.large),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.large),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title.trim().isEmpty ? '--' : title.trim(),
                    style: AppTextStyles.title.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _StatusTag(text: statusText),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              content.trim().isEmpty
                  ? LocaleKeys.qaThreadsContentEmpty.tr
                  : content.trim(),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body.copyWith(height: 1.6),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.sm,
              children: [
                _MetaText(
                  label: LocaleKeys.qaThreadsQuestionId.tr,
                  value: questionId.trim().isEmpty ? '--' : questionId.trim(),
                ),
                _MetaText(
                  label: LocaleKeys.qaThreadsSessionId.tr,
                  value: sessionId.trim().isEmpty ? '--' : sessionId.trim(),
                ),
                _MetaText(
                  label: LocaleKeys.qaThreadsReplies.tr,
                  value: '$replyCount',
                ),
                _MetaText(
                  label: LocaleKeys.qaThreadsLastReplyAt.tr,
                  value: lastRepliedAt == null
                      ? '--'
                      : DateFormat('yyyy-MM-dd HH:mm').format(lastRepliedAt!),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusTag extends StatelessWidget {
  const _StatusTag({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    final isClosed =
        text == LocaleKeys.qaThreadsStatusClosed.tr || text == 'Closed';
    final color = isClosed ? AppColors.textSecondary : AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MetaText extends StatelessWidget {
  const _MetaText({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$label$value',
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
          color: AppColors.error.withValues(alpha: 0.18),
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
    if (!hasMore && !isLoadingMore) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.md),
        child: Center(
          child: Text(
            LocaleKeys.qaThreadsNoMore.tr,
            style: AppTextStyles.caption,
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Center(
        child: isLoadingMore
            ? const CircularProgressIndicator(strokeWidth: 2)
            : OutlinedButton(
                onPressed: onLoadMore,
                child: Text(LocaleKeys.qaThreadsLoadMore.tr),
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
              child: Text(LocaleKeys.qaThreadsRetry.tr),
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
    if (sliverFriendly) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.md),
        child: child,
      );
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: child,
      ),
    );
  }
}
