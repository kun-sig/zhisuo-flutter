import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../data/models/question_bank/question_bank_dashboard_models.dart';
import '../../i18n/locale_keys.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

class PracticeUnitPreviewList extends StatelessWidget {
  const PracticeUnitPreviewList({
    super.key,
    required this.units,
    required this.onTap,
  });

  final List<PracticeUnitPreviewData> units;
  final ValueChanged<PracticeUnitPreviewData> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: units
          .map(
            (item) => Padding(
              padding: EdgeInsets.only(
                bottom: item == units.last ? 0 : AppSpacing.md,
              ),
              child: PracticeUnitCard(
                item: item,
                onTap: () => onTap(item),
              ),
            ),
          )
          .toList(),
    );
  }
}

/// 题库单元卡片，供首页预览区和单元列表页复用。
class PracticeUnitCard extends StatelessWidget {
  const PracticeUnitCard({
    super.key,
    required this.item,
    required this.onTap,
    this.enabledOverride,
    this.disabledReasonOverride,
  });

  final PracticeUnitPreviewData item;
  final VoidCallback onTap;
  final bool? enabledOverride;
  final String? disabledReasonOverride;

  /// 构建单元卡片，统一处理单元自身状态和分类级灰态覆盖。
  @override
  Widget build(BuildContext context) {
    final enabled = _resolvedEnabled;
    final accent = enabled ? AppColors.primary : AppColors.textDisabled;
    final disabledReason = _disabledReasonText(item);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.large),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: enabled
                ? AppColors.surface
                : AppColors.surface.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(AppRadius.large),
            border: Border.all(
              color: enabled
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : AppColors.divider,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.title.trim().isEmpty ? '--' : item.title.trim(),
                      style: AppTextStyles.title.copyWith(
                        fontWeight: FontWeight.w700,
                        color: enabled
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                    ),
                    child: Text(
                      _progressText(item),
                      style: AppTextStyles.caption.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              if (item.subtitle.trim().isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  item.subtitle.trim(),
                  style: AppTextStyles.caption,
                ),
              ],
              if (!enabled) ...[
                const SizedBox(height: AppSpacing.sm),
                _UnitDisabledHint(message: disabledReason),
              ],
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _Metric(
                      label: LocaleKeys
                          .questionBankDashboardUnitMetricQuestions.tr,
                      value: '${item.questionCount}',
                    ),
                  ),
                  Expanded(
                    child: _Metric(
                      label: LocaleKeys.questionBankDashboardUnitMetricDone.tr,
                      value: '${item.doneCount}',
                    ),
                  ),
                  Expanded(
                    child: _Metric(
                      label:
                          LocaleKeys.questionBankDashboardUnitMetricAccuracy.tr,
                      value: '${item.correctRate.toStringAsFixed(0)}%',
                    ),
                  ),
                ],
              ),
              if (item.lastPracticedAt != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  DateFormat('MM-dd HH:mm').format(item.lastPracticedAt!),
                  style: AppTextStyles.caption,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 统一决定单元卡片最终可用态，支持列表页按分类灰态覆盖单元本身状态。
  bool get _resolvedEnabled => enabledOverride ?? item.isEnabled;

  /// 统一处理单元禁用原因兜底，确保灰态原因在首页和列表页保持一致。
  String _disabledReasonText(PracticeUnitPreviewData unit) {
    final overrideReason = disabledReasonOverride?.trim() ?? '';
    if (overrideReason.isNotEmpty) {
      return overrideReason;
    }
    final value = unit.disabledReason.trim();
    if (value.isNotEmpty) {
      return value;
    }
    return LocaleKeys.questionBankDashboardUnitDisabledDefault.tr;
  }

  /// 根据单元当前进度输出统一状态文案。
  String _progressText(PracticeUnitPreviewData unit) {
    final value = unit.progressStatus.trim().toLowerCase();
    if (unit.completed || value == 'completed') {
      return LocaleKeys.questionBankDashboardUnitStatusCompleted.tr;
    }
    if (value == 'in_progress') {
      return LocaleKeys.questionBankDashboardUnitStatusInProgress.tr;
    }
    if (!_resolvedEnabled) {
      return LocaleKeys.questionBankDashboardUnitStatusDisabled.tr;
    }
    return LocaleKeys.questionBankDashboardUnitStatusNotStarted.tr;
  }
}

/// 在单元卡片内联展示禁用原因，减少用户只能点开后才知道不可用的问题。
class _UnitDisabledHint extends StatelessWidget {
  const _UnitDisabledHint({
    required this.message,
  });

  final String message;

  /// 构建单元禁用原因提示，明确告知当前入口为何不可用。
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
          style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}
