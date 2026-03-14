import 'package:flutter/material.dart';

import '../../data/models/question_bank/practice_session_models.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

class QuestionOptionGroupView extends StatelessWidget {
  const QuestionOptionGroupView({
    required this.options,
    required this.selectedAnswers,
    required this.onTap,
    super.key,
  });

  final List<PracticeQuestionOptionData> options;
  final List<String> selectedAnswers;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options.map((option) {
        final selected = selectedAnswers.contains(option.label);
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.large),
              onTap: () => onTap(option.label),
              child: Ink(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary.withValues(alpha: 0.08)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.large),
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.divider,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary
                            : AppColors.buttonLight,
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                      ),
                      child: Text(
                        option.label,
                        style: AppTextStyles.caption.copyWith(
                          color: selected ? Colors.white : AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        option.text.trim().isEmpty ? '--' : option.text.trim(),
                        style: AppTextStyles.body.copyWith(height: 1.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
