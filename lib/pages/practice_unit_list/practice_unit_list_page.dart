import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../i18n/locale_keys.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/question_bank/practice_unit_preview_list.dart';
import 'practice_unit_list_controller.dart';

class PracticeUnitListPage extends GetView<PracticeUnitListController> {
  const PracticeUnitListPage({super.key});

  /// 构建二级练习单元列表页，承接分类后的分页浏览与刷新。
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
          if (controller.isLoading.value && controller.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!controller.hasCategoryCode) {
            return _EmptyState(
              message: LocaleKeys.practiceUnitListMissingCategory.tr,
            );
          }

          if (!controller.hasSubject) {
            return _EmptyState(
              message: LocaleKeys.practiceUnitListNeedSubject.tr,
            );
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
                  completedUnitCount: controller.completedUnitCount,
                  averageCorrectRate: controller.averageCorrectRate,
                ),
                const SizedBox(height: AppSpacing.md),
                _FilterCard(controller: controller),
                if (controller.isCategoryDisabled) ...[
                  const SizedBox(height: AppSpacing.md),
                  _InfoBanner(message: controller.categoryDisabledReason),
                ],
                if (controller.errorText.value.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  _ErrorBanner(message: controller.errorText.value),
                ],
                const SizedBox(height: AppSpacing.md),
                if (controller.items.isEmpty)
                  _EmptyState(
                    message: controller.isCategoryDisabled
                        ? controller.categoryDisabledReason
                        : controller.hasFilter
                            ? LocaleKeys.practiceUnitListEmptyFiltered.tr
                            : LocaleKeys.practiceUnitListEmpty.tr,
                    sliverFriendly: true,
                  )
                else
                  ...controller.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: PracticeUnitCard(
                        item: item,
                        enabledOverride:
                            controller.isCategoryDisabled ? false : null,
                        disabledReasonOverride: controller.isCategoryDisabled
                            ? controller.categoryDisabledReason
                            : null,
                        onTap: () => controller.onUnitTap(item),
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

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.message,
  });

  final String message;

  /// 构建列表页信息提示，强调分类灰态但不阻断页面浏览。
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
        style: AppTextStyles.body.copyWith(color: AppColors.primary),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.subjectName,
    required this.totalSize,
    required this.completedUnitCount,
    required this.averageCorrectRate,
  });

  final String subjectName;
  final int totalSize;
  final int completedUnitCount;
  final double averageCorrectRate;

  /// 构建列表顶部摘要，展示当前分类的核心统计信息。
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
              label: LocaleKeys.practiceUnitListSummarySubject.tr,
              value: subjectName.trim().isEmpty ? '--' : subjectName.trim(),
            ),
          ),
          Expanded(
            child: _Metric(
              label: LocaleKeys.practiceUnitListSummaryTotal.tr,
              value: '$totalSize',
            ),
          ),
          Expanded(
            child: _Metric(
              label: LocaleKeys.practiceUnitListSummaryCompleted.tr,
              value: '$completedUnitCount',
            ),
          ),
          Expanded(
            child: _Metric(
              label: LocaleKeys.practiceUnitListSummaryAccuracy.tr,
              value: '${averageCorrectRate.toStringAsFixed(0)}%',
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

  final PracticeUnitListController controller;

  /// 构建单元搜索与状态筛选卡片，把远端已支持的过滤参数收口到同一个入口。
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
              Text(
                LocaleKeys.practiceUnitListFilterTitle.tr,
                style: AppTextStyles.title.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (controller.filterCount > 0)
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
                    '${LocaleKeys.practiceUnitListSummaryFilters.tr} ${controller.filterCount}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: controller.keywordController,
            decoration: InputDecoration(
              labelText: LocaleKeys.practiceUnitListFilterKeyword.tr,
              hintText: LocaleKeys.practiceUnitListFilterKeywordHint.tr,
              prefixIcon: const Icon(Icons.search),
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => controller.applyFilters(),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            LocaleKeys.practiceUnitListFilterStatus.tr,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Obx(
            () => Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: controller.statusOptions
                  .map(
                    (option) => ChoiceChip(
                      label: Text(option.labelKey.tr),
                      selected:
                          controller.draftStatus.value == option.value.trim(),
                      onSelected: (_) =>
                          controller.toggleDraftStatus(option.value),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              ElevatedButton(
                onPressed: controller.applyFilters,
                child: Text(LocaleKeys.practiceUnitListFilterApply.tr),
              ),
              OutlinedButton(
                onPressed: controller.clearFilters,
                child: Text(LocaleKeys.practiceUnitListFilterClear.tr),
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

  /// 构建摘要区单个指标块。
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

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({
    required this.message,
  });

  final String message;

  /// 构建列表内联错误提示，保留当前已加载数据。
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

  /// 构建分页底部，统一处理加载更多与无更多数据状态。
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
            LocaleKeys.practiceUnitListNoMore.tr,
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
          child: Text(LocaleKeys.practiceUnitListLoadMore.tr),
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

  /// 构建整页错误态，供首次加载失败时重试。
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
              child: Text(LocaleKeys.practiceUnitListRetry.tr),
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

  /// 构建空态视图，兼容整页和下拉刷新场景。
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
