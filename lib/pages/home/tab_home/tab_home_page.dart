import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/home/home_models.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';
import 'tab_home_controller.dart';

class TabHomePage extends GetView<TabHomeController> {
  const TabHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(
          () => RefreshIndicator(
            onRefresh: controller.onRefresh,
            child: ListView(
              controller: controller.articleScrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                _buildBannerSection(),
                SizedBox(height: AppSpacing.lg),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Text('最新资讯', style: AppTextStyles.title),
                ),
                SizedBox(height: AppSpacing.md),
                if (controller.isLoading.value &&
                    !controller.hasBanners &&
                    !controller.hasArticles)
                  _buildLoadingState()
                else if (controller.errorText.value.isNotEmpty &&
                    !controller.hasBanners &&
                    !controller.hasArticles)
                  _buildErrorState()
                else if (!controller.hasArticles)
                  _buildEmptyState()
                else
                  ...controller.articles.map(_buildArticleItem),
                _buildLoadMoreFooter(),
                SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBannerSection() {
    if (controller.isLoading.value && !controller.hasBanners) {
      return Container(
        height: 220,
        margin: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.large),
        ),
        alignment: Alignment.center,
        child: const CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (!controller.hasBanners) {
      return Container(
        height: 220,
        margin: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.large),
        ),
        alignment: Alignment.center,
        child: Text('暂无横幅内容', style: AppTextStyles.body),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: controller.pageController,
            onPageChanged: controller.onPageChanged,
            itemCount: controller.banners.length,
            itemBuilder: (context, index) {
              final item = controller.banners[index];
              return _buildBannerItem(item);
            },
          ),
        ),
        if (controller.banners.length > 1) ...[
          SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              controller.banners.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                width: controller.currentBannerIndex.value == index ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: controller.currentBannerIndex.value == index
                      ? AppColors.secondary
                      : AppColors.buttonDisabled,
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBannerItem(HomeBannerItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            item.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppColors.buttonLight,
                alignment: Alignment.center,
                child: Text('图片加载失败', style: AppTextStyles.caption),
              );
            },
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  AppColors.primary.withValues(alpha: 0.65),
                  AppColors.primary.withValues(alpha: 0.08),
                ],
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: AppSpacing.lg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.headline.copyWith(
                    color: AppColors.surface,
                  ),
                ),
                if (item.overlay.text.isNotEmpty) ...[
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    item.overlay.text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.surface,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleItem(HomeArticleItem item) {
    return InkWell(
      onTap: () => controller.onArticleTap(item),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.title.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ),
                if (item.coverUrl.isNotEmpty) ...[
                  SizedBox(width: AppSpacing.md),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.small),
                    child: Image.network(
                      item.coverUrl,
                      width: 88,
                      height: 66,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 88,
                          height: 66,
                          color: AppColors.buttonLight,
                          alignment: Alignment.center,
                          child: Text('无图', style: AppTextStyles.caption),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: AppSpacing.sm),
            if (item.summary.isNotEmpty)
              Text(
                item.summary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ),
            SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                if (item.tag.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.buttonLight,
                      borderRadius: BorderRadius.circular(AppRadius.small),
                    ),
                    child: Text(
                      item.tag,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                SizedBox(width: AppSpacing.sm),
                Text(_formatDate(item.publishedAt),
                    style: AppTextStyles.caption),
                SizedBox(width: AppSpacing.sm),
                Text('阅读 ${item.viewCount}', style: AppTextStyles.caption),
              ],
            ),
            SizedBox(height: AppSpacing.lg),
            Container(height: 0.5, color: AppColors.divider),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMoreFooter() {
    if (!controller.hasArticles) {
      return const SizedBox.shrink();
    }
    if (controller.isLoadingMore.value) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: Text('加载更多中...', style: AppTextStyles.caption),
        ),
      );
    }
    if (controller.loadMoreErrorText.value.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Center(
          child: TextButton(
            onPressed: controller.retryLoadMore,
            child: Text(controller.loadMoreErrorText.value),
          ),
        ),
      );
    }
    if (!controller.hasMore) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: Text('没有更多内容了', style: AppTextStyles.caption),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Center(
        child: Text('加载中...', style: AppTextStyles.body),
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Text(controller.errorText.value, style: AppTextStyles.body),
          SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: () => controller.loadHomeFeed(reset: true),
            child: Text('重试', style: AppTextStyles.body),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Center(
        child: Text('暂无资讯内容', style: AppTextStyles.body),
      ),
    );
  }

  String _formatDate(int timestampSeconds) {
    if (timestampSeconds <= 0) {
      return '--';
    }
    final date = DateTime.fromMillisecondsSinceEpoch(timestampSeconds * 1000);
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
