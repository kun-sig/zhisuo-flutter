import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

class QuestionAssetMetaItem {
  const QuestionAssetMetaItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

class QuestionAssetActionItem {
  const QuestionAssetActionItem({
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
    this.foregroundColor,
  });

  final String label;
  final Future<void> Function()? onPressed;
  final bool isPrimary;
  final Color? foregroundColor;
}

/// 统一渲染资产域题目卡片，减少错题、收藏、笔记页重复拼装同类结构。
class QuestionAssetCard extends StatelessWidget {
  const QuestionAssetCard({
    super.key,
    required this.title,
    required this.metaItems,
    this.header,
    this.body = '',
    this.emptyTitle = '--',
    this.emptyBody = '--',
    this.highlightText = '',
    this.highlightColor,
    this.actions = const <QuestionAssetActionItem>[],
  });

  final String title;
  final Widget? header;
  final String body;
  final String emptyTitle;
  final String emptyBody;
  final String highlightText;
  final Color? highlightColor;
  final List<QuestionAssetMetaItem> metaItems;
  final List<QuestionAssetActionItem> actions;

  /// 统一输出资产卡片布局，标题、摘要、元信息和操作区均保持同一视觉节奏。
  @override
  Widget build(BuildContext context) {
    final resolvedHighlightText = highlightText.trim();
    final resolvedHighlightColor = highlightColor ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (header != null)
            header!
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    _resolveText(title, emptyTitle),
                    style: AppTextStyles.title.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (resolvedHighlightText.isNotEmpty) ...[
                  const SizedBox(width: AppSpacing.sm),
                  _QuestionAssetHighlightTag(
                    text: resolvedHighlightText,
                    color: resolvedHighlightColor,
                  ),
                ],
              ],
            ),
          if (header == null && body.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              _resolveText(body, emptyBody),
              style: AppTextStyles.body.copyWith(height: 1.6),
            ),
          ],
          if (metaItems.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            ...metaItems.map(_buildMetaRow),
          ],
          if (actions.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              alignment: WrapAlignment.end,
              children: actions.map(_buildActionButton).toList(),
            ),
          ],
        ],
      ),
    );
  }

  /// 统一渲染键值型元信息，避免各资产页重复维护同样的行布局。
  Widget _buildMetaRow(QuestionAssetMetaItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(item.label, style: AppTextStyles.caption),
          ),
          Expanded(
            child: Text(
              _resolveText(item.value, '--'),
              style: AppTextStyles.body,
            ),
          ),
        ],
      ),
    );
  }

  /// 根据动作语义切换主按钮和次按钮，保证资产页操作风格一致。
  Widget _buildActionButton(QuestionAssetActionItem item) {
    final foregroundColor = item.foregroundColor;
    final onPressed = item.onPressed;
    if (item.isPrimary) {
      return FilledButton.tonal(
        onPressed: onPressed == null ? null : () => unawaited(onPressed()),
        style: FilledButton.styleFrom(
          foregroundColor: foregroundColor,
        ),
        child: Text(item.label),
      );
    }
    return OutlinedButton(
      onPressed: onPressed == null ? null : () => unawaited(onPressed()),
      style: OutlinedButton.styleFrom(
        foregroundColor: foregroundColor,
      ),
      child: Text(item.label),
    );
  }

  /// 统一处理空字符串兜底，避免各页面散落 `trim().isEmpty` 判断。
  String _resolveText(String value, String fallback) {
    final resolvedValue = value.trim();
    if (resolvedValue.isEmpty) {
      return fallback;
    }
    return resolvedValue;
  }
}

/// 资产卡片的高亮标签统一承载状态、次数等轻量辅助信息。
class _QuestionAssetHighlightTag extends StatelessWidget {
  const _QuestionAssetHighlightTag({
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  /// 统一渲染右上角高亮标签，避免不同资产页出现样式漂移。
  @override
  Widget build(BuildContext context) {
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
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
