import 'package:flutter/material.dart';

import '../../data/models/question_bank/question_display_models.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

class AnswerSheetBar extends StatelessWidget {
  const AnswerSheetBar({
    super.key,
    required this.data,
    required this.onTapItem,
  });

  final QuestionAnswerSheetDisplayData data;
  final ValueChanged<int> onTapItem;

  /// 统一渲染题号导航答题卡，方便练习页后续扩展为更多场景共用的题目导航组件。
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
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: data.items
                .map(
                  (item) => _AnswerSheetChip(
                    item: item,
                    onTap: () => onTapItem(item.index),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _AnswerSheetChip extends StatelessWidget {
  const _AnswerSheetChip({
    required this.item,
    required this.onTap,
  });

  final QuestionAnswerSheetItemDisplayData item;
  final VoidCallback onTap;

  /// 根据当前题、已答题、未答题三种状态统一输出题号胶囊样式。
  @override
  Widget build(BuildContext context) {
    final colors = _resolveColors();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Ink(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(AppRadius.medium),
            border: Border.all(color: colors.border),
          ),
          child: Center(
            child: Text(
              item.label,
              style: AppTextStyles.caption.copyWith(
                color: colors.foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 题号胶囊颜色规则统一集中，避免页面层自行拼接当前/已答态色值逻辑。
  _AnswerSheetChipColors _resolveColors() {
    if (item.current) {
      return const _AnswerSheetChipColors(
        background: AppColors.primary,
        border: AppColors.primary,
        foreground: Colors.white,
      );
    }
    if (item.answered) {
      return _AnswerSheetChipColors(
        background: AppColors.success.withValues(alpha: 0.12),
        border: AppColors.success.withValues(alpha: 0.22),
        foreground: AppColors.success,
      );
    }
    return _AnswerSheetChipColors(
      background: AppColors.buttonLight,
      border: AppColors.divider,
      foreground: AppColors.textSecondary,
    );
  }
}

class _AnswerSheetChipColors {
  const _AnswerSheetChipColors({
    required this.background,
    required this.border,
    required this.foreground,
  });

  final Color background;
  final Color border;
  final Color foreground;
}
