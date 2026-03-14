import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/question_bank/question_bank_dashboard_models.dart';
import '../../i18n/locale_keys.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

class AssetToolGrid extends StatelessWidget {
  const AssetToolGrid({
    super.key,
    required this.tools,
    required this.onTap,
  });

  final List<AssetToolViewData> tools;
  final ValueChanged<AssetToolViewData> onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: tools.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.42,
      ),
      itemBuilder: (context, index) {
        final item = tools[index];
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
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: palette.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                    ),
                    child: Icon(
                      palette.icon,
                      color: palette.color,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.toolName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.title.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          _description(item),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  if (item.unreadCount > 0 || item.badgeText.trim().isNotEmpty)
                    _badge(item, palette.color),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _badge(AssetToolViewData item, Color color) {
    final text = item.badgeText.trim().isNotEmpty
        ? item.badgeText.trim()
        : item.unreadCount.toString();
    return Container(
      constraints: const BoxConstraints(minWidth: 24),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTextStyles.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _description(AssetToolViewData item) {
    if (!item.enabled) {
      final text = item.disabledReason.trim();
      if (text.isNotEmpty) {
        return text;
      }
      return LocaleKeys.questionBankDashboardNeedSubject.tr;
    }
    return '${item.count} 项记录';
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
    case 'record':
      return const _Palette(
        icon: Icons.history_outlined,
        color: AppColors.secondary,
      );
    case 'favorite':
      return const _Palette(
        icon: Icons.star_border_rounded,
        color: AppColors.warning,
      );
    case 'note':
      return const _Palette(
        icon: Icons.edit_note_rounded,
        color: AppColors.success,
      );
    case 'wrongbook':
    default:
      return const _Palette(
        icon: Icons.report_gmailerrorred_rounded,
        color: AppColors.error,
      );
  }
}
