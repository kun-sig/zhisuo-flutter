import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/question_bank/question_bank_dashboard_models.dart';
import '../../i18n/locale_keys.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

class PracticeCategorySection extends StatelessWidget {
  const PracticeCategorySection({
    super.key,
    required this.categories,
    required this.onTap,
  });

  final List<PracticeCategoryCardData> categories;
  final ValueChanged<PracticeCategoryCardData> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: categories
          .map(
            (item) => Padding(
              padding: EdgeInsets.only(
                bottom: item == categories.last ? 0 : AppSpacing.md,
              ),
              child: _CategoryCard(
                item: item,
                onTap: () => onTap(item),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.item,
    required this.onTap,
  });

  final PracticeCategoryCardData item;
  final VoidCallback onTap;

  /// 构建一级分类卡片，直接展示分类灰态和禁用原因。
  @override
  Widget build(BuildContext context) {
    final palette = _paletteFor(item.iconKey);
    final disabledReason = _disabledReasonText(item);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.large),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: item.enabled
                ? AppColors.surface
                : AppColors.surface.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(AppRadius.large),
            border: Border.all(
              color: item.enabled
                  ? palette.color.withValues(alpha: 0.16)
                  : AppColors.divider,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: palette.color.withValues(
                    alpha: item.enabled ? 0.12 : 0.08,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                child: Icon(
                  palette.icon,
                  color: item.enabled ? palette.color : AppColors.textDisabled,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.categoryName,
                            style: AppTextStyles.title.copyWith(
                              fontWeight: FontWeight.w700,
                              color: item.enabled
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                        if (!item.enabled) _DisabledBadge(text: _disabledLabel),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${item.completedUnitCount}/${item.unitCount} · '
                      '${item.averageCorrectRate.toStringAsFixed(0)}%',
                      style: AppTextStyles.caption,
                    ),
                    if (!item.enabled) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _DisabledHint(message: disabledReason),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                Icons.chevron_right_rounded,
                color: item.enabled
                    ? AppColors.textSecondary
                    : AppColors.textDisabled,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 统一收口分类禁用原因，避免页面层重复写灰度兜底逻辑。
  String _disabledReasonText(PracticeCategoryCardData data) {
    final value = data.disabledReason.trim();
    if (value.isNotEmpty) {
      return value;
    }
    return LocaleKeys.questionBankDashboardCategoryDisabledDefault.tr;
  }
}

/// 分类与单元统一复用的禁用标签，保证灰态表达一致。
class _DisabledBadge extends StatelessWidget {
  const _DisabledBadge({
    required this.text,
  });

  final String text;

  /// 构建灰态标签，统一分类和单元的未开放视觉标识。
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.divider.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// 统一渲染禁用原因提示，突出灰度或关闭原因而不打断浏览流程。
class _DisabledHint extends StatelessWidget {
  const _DisabledHint({
    required this.message,
  });

  final String message;

  /// 构建禁用原因提示条，让灰度原因在卡片内部直接可见。
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.divider.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Text(
        message,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

/// 统一复用未开放标签文案，避免分类和单元出现不同叫法。
String get _disabledLabel =>
    LocaleKeys.questionBankDashboardUnitStatusDisabled.tr;

class _Palette {
  const _Palette({
    required this.icon,
    required this.color,
  });

  final IconData icon;
  final Color color;
}

_Palette _paletteFor(String iconKey) {
  switch (iconKey) {
    case 'knowledge':
      return const _Palette(
        icon: Icons.lightbulb_outline_rounded,
        color: AppColors.warning,
      );
    case 'mock':
      return const _Palette(
        icon: Icons.description_outlined,
        color: AppColors.secondary,
      );
    case 'paper':
      return const _Palette(
        icon: Icons.history_edu_outlined,
        color: AppColors.success,
      );
    case 'hotpoint':
      return const _Palette(
        icon: Icons.local_fire_department_outlined,
        color: AppColors.warning,
      );
    case 'wrong':
      return const _Palette(
        icon: Icons.error_outline_rounded,
        color: AppColors.error,
      );
    case 'chapter':
    default:
      return const _Palette(
        icon: Icons.menu_book_outlined,
        color: AppColors.primary,
      );
  }
}
