import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../data/models/question_bank/asset_models.dart';
import '../../i18n/locale_keys.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import 'practice_notes_controller.dart';

class PracticeNotesPage extends GetView<PracticeNotesController> {
  const PracticeNotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(LocaleKeys.practiceNotesTitle.tr),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      floatingActionButton: Obx(
        () => FloatingActionButton.extended(
          onPressed: controller.hasSubject && !controller.isCreating.value
              ? controller.openCreateDialog
              : null,
          label: Text(
            controller.isCreating.value
                ? LocaleKeys.practiceNotesCreating.tr
                : LocaleKeys.practiceNotesCreateAction.tr,
          ),
          icon: const Icon(Icons.edit_note_rounded),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!controller.hasSubject) {
            return _EmptyState(message: LocaleKeys.practiceNotesNeedSubject.tr);
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
                    message: LocaleKeys.practiceNotesEmpty.tr,
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
                    child: _PracticeNoteCard(
                      item: item,
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
              label: LocaleKeys.practiceNotesSummarySubject.tr,
              value: subjectName.trim().isEmpty ? '--' : subjectName.trim(),
            ),
          ),
          Expanded(
            child: _Metric(
              label: LocaleKeys.practiceNotesSummaryTotal.tr,
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

class _PracticeNoteCard extends StatelessWidget {
  const _PracticeNoteCard({
    required this.item,
    required this.statusText,
  });

  final PracticeNoteAssetItem item;
  final String statusText;

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
            item.content.toString().trim().isEmpty
                ? LocaleKeys.practiceNotesContentEmpty.tr
                : item.content.toString().trim(),
            style: AppTextStyles.bodyLarge.copyWith(height: 1.6),
          ),
          const SizedBox(height: AppSpacing.md),
          _InfoRow(
            label: LocaleKeys.practiceNotesQuestionId.tr,
            value: item.questionId.toString().trim().isEmpty
                ? '--'
                : item.questionId.toString().trim(),
          ),
          _InfoRow(
            label: LocaleKeys.practiceNotesSessionId.tr,
            value: item.sessionId.toString().trim().isEmpty
                ? '--'
                : item.sessionId.toString().trim(),
          ),
          _InfoRow(
            label: LocaleKeys.practiceNotesStatus.tr,
            value: statusText.trim().isEmpty
                ? LocaleKeys.practiceNotesStatusUnknown.tr
                : statusText.trim(),
          ),
          _InfoRow(
            label: LocaleKeys.practiceNotesUpdatedAt.tr,
            value: _formatDateTime(item.updatedAt),
          ),
          if (item.reviewRemark.toString().trim().isNotEmpty)
            _InfoRow(
              label: LocaleKeys.practiceNotesReviewRemark.tr,
              value: item.reviewRemark.toString().trim(),
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
            LocaleKeys.practiceNotesNoMore.tr,
            style: AppTextStyles.caption,
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: OutlinedButton(
        onPressed: onLoadMore,
        child: Text(LocaleKeys.practiceNotesLoadMore.tr),
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
              child: Text(LocaleKeys.practiceNotesRetry.tr),
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
