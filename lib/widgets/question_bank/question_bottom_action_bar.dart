import 'package:flutter/material.dart';

import '../../data/models/question_bank/question_display_models.dart';
import '../../theme/app_spacing.dart';

class QuestionBottomActionBar extends StatelessWidget {
  const QuestionBottomActionBar({
    super.key,
    required this.data,
  });

  final QuestionBottomActionBarDisplayData data;

  /// 统一渲染题目底部操作区，保持上一题、主动作和收尾动作的布局一致。
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: data.leadingAction.onPressed,
                child: Text(data.leadingAction.label),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: ElevatedButton(
                onPressed: data.primaryAction.onPressed,
                child: Text(data.primaryAction.label),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          child: FilledButton.tonal(
            onPressed: data.secondaryAction.onPressed,
            child: Text(data.secondaryAction.label),
          ),
        ),
      ],
    );
  }
}
