import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/question_bank/question_bank_dashboard_models.dart';
import '../../i18n/locale_keys.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

class PracticeModuleGrid extends StatelessWidget {
  const PracticeModuleGrid({
    super.key,
    required this.modules,
    required this.onTap,
  });

  final List<PracticeModuleViewData> modules;
  final ValueChanged<PracticeModuleViewData> onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: modules.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.18,
      ),
      itemBuilder: (context, index) {
        final item = modules[index];
        final palette = _paletteFor(item.iconKey);

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.large),
            onTap: () => onTap(item),
            child: Ink(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.large),
                border: Border.all(
                  color: item.enabled
                      ? palette.color.withValues(alpha: 0.16)
                      : AppColors.divider,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: palette.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadius.medium),
                        ),
                        child: Icon(
                          palette.icon,
                          color: palette.color,
                          size: 20,
                        ),
                      ),
                      const Spacer(),
                      if (item.badgeText.trim().isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: palette.color.withValues(alpha: 0.12),
                            borderRadius:
                                BorderRadius.circular(AppRadius.medium),
                          ),
                          child: Text(
                            item.badgeText,
                            style: AppTextStyles.caption.copyWith(
                              color: palette.color,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    item.moduleName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.title.copyWith(
                      fontWeight: FontWeight.w700,
                      color: item.enabled
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _description(item),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _description(PracticeModuleViewData item) {
    if (!item.enabled) {
      final text = item.disabledReason.trim();
      if (text.isNotEmpty) {
        return text;
      }
      return LocaleKeys.questionBankDashboardNeedSubject.tr;
    }
    final stat = item.questionCount > 0
        ? '${item.questionCount} 题'
        : item.paperCount > 0
            ? '${item.paperCount} 套卷'
            : '${item.doneCount} 已完成';
    final rate = item.correctRate <= 0 ? '--' : '${item.correctRate}%';
    return '$stat · 正确率 $rate';
  }
}

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
