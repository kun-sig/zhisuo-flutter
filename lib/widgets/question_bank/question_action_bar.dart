import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/models/question_bank/question_display_models.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

class QuestionActionBar extends StatelessWidget {
  const QuestionActionBar({
    super.key,
    required this.data,
  });

  final QuestionActionBarDisplayData data;

  /// 统一渲染题目操作区，减少页面重复维护收藏、笔记等操作布局。
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
            data.title.trim(),
            style: AppTextStyles.title.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: data.actions
                .map(
                  (action) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: action == data.actions.last ? 0 : AppSpacing.md,
                      ),
                      child: _buildActionButton(action),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  /// 根据动作主次关系切换按钮样式，保证题目操作区视觉一致。
  Widget _buildActionButton(QuestionActionDisplayData action) {
    if (action.isPrimary) {
      return FilledButton.tonalIcon(
        onPressed: action.onPressed == null
            ? null
            : () => unawaited(action.onPressed!.call()),
        icon: Icon(_resolveIcon(action.iconName)),
        label: Text(action.label),
      );
    }
    return OutlinedButton.icon(
      onPressed: action.onPressed == null
          ? null
          : () => unawaited(action.onPressed!.call()),
      icon: Icon(_resolveIcon(action.iconName)),
      label: Text(action.label),
    );
  }

  /// 用字符串图标协议隔离 model 层与 Flutter UI 类型，保持题目展示协议更稳定。
  IconData _resolveIcon(String value) {
    switch (value.trim().toLowerCase()) {
      case 'star_filled':
        return Icons.star_rounded;
      case 'star_outline':
        return Icons.star_outline_rounded;
      case 'note':
        return Icons.edit_note_rounded;
      default:
        return Icons.circle_outlined;
    }
  }
}
