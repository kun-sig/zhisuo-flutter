import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../data/models/home/home_models.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';

class HomeArticleDetailPage extends StatelessWidget {
  const HomeArticleDetailPage({
    required this.detail,
    super.key,
  });

  final HomeArticleDetailData detail;

  @override
  Widget build(BuildContext context) {
    final article = detail.article;
    final content = detail.content;
    final bodyText = _resolveBodyText(content);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('资讯详情'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            article.title,
            style: AppTextStyles.title.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              if (article.tag.isNotEmpty) _buildTag(article.tag),
              Text(_formatDate(article.publishedAt),
                  style: AppTextStyles.caption),
              Text('阅读 ${article.viewCount}', style: AppTextStyles.caption),
              if (article.wordCount > 0)
                Text('${article.wordCount} 字', style: AppTextStyles.caption),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: SelectableText(
              bodyText.isEmpty ? '暂无正文内容' : bodyText,
              style: AppTextStyles.body.copyWith(height: 1.75),
            ),
          ),
          if (article.jumpUrl.isNotEmpty) ...[
            SizedBox(height: AppSpacing.lg),
            Text(
              '原文链接',
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textSecondary),
            ),
            SizedBox(height: AppSpacing.xs),
            InkWell(
              onTap: () => _copySourceLink(article.jumpUrl),
              child: Text(
                article.jumpUrl,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              '点击链接可复制到剪贴板',
              style: AppTextStyles.caption,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.buttonLight,
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: Text(
        tag,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.primary,
        ),
      ),
    );
  }

  String _resolveBodyText(HomeArticleContent content) {
    if (content.plainText.trim().isNotEmpty) {
      return content.plainText.trim();
    }
    if (content.htmlContent.trim().isEmpty) {
      return '';
    }
    final stripped = content.htmlContent.replaceAll(RegExp(r'<[^>]*>'), ' ');
    return stripped.replaceAll(RegExp(r'\s+'), ' ').trim();
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

  Future<void> _copySourceLink(String link) async {
    await Clipboard.setData(ClipboardData(text: link));
    Get.snackbar(
      '提示',
      '原文链接已复制',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
