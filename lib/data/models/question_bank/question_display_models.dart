import 'practice_session_models.dart';

class QuestionDisplayTagData {
  const QuestionDisplayTagData({
    required this.text,
  });

  final String text;
}

/// 统一题目展示协议，供练习页、错题页等模块共用题目头部/题干渲染结构。
class QuestionDisplayData {
  const QuestionDisplayData({
    required this.title,
    required this.body,
    required this.tags,
  });

  final String title;
  final String body;
  final List<QuestionDisplayTagData> tags;

  /// 练习会话题目优先展示题干正文，并把章节、题型、题类统一收敛到 tags。
  factory QuestionDisplayData.fromPracticeQuestion(PracticeQuestionData data) {
    return QuestionDisplayData(
      title: '',
      body: data.stem,
      tags: [
        if (data.questionCategoryName.trim().isNotEmpty)
          QuestionDisplayTagData(text: data.questionCategoryName.trim()),
        if (data.chapterName.trim().isNotEmpty)
          QuestionDisplayTagData(text: data.chapterName.trim()),
        if (data.questionType.trim().isNotEmpty)
          QuestionDisplayTagData(text: data.questionType.trim()),
      ],
    );
  }

  /// 错题资产卡片当前没有完整题干时，先统一展示 questionId 与状态标签，后续再扩展真实题干。
  factory QuestionDisplayData.fromWrongQuestionAsset({
    required String questionId,
    required int wrongCount,
    required String statusText,
  }) {
    return QuestionDisplayData(
      title: questionId.trim(),
      body: '',
      tags: [
        if (statusText.trim().isNotEmpty)
          QuestionDisplayTagData(text: statusText.trim()),
        QuestionDisplayTagData(text: '错题 $wrongCount 次'),
      ],
    );
  }
}

class QuestionOptionDisplayData {
  const QuestionOptionDisplayData({
    required this.label,
    required this.text,
    required this.imageUrl,
  });

  final String label;
  final String text;
  final String imageUrl;

  /// 练习会话的选项数据统一映射到展示协议，避免组件直接依赖业务模型。
  factory QuestionOptionDisplayData.fromPracticeOption(
    PracticeQuestionOptionData data,
  ) {
    return QuestionOptionDisplayData(
      label: data.label,
      text: data.text,
      imageUrl: data.imageUrl,
    );
  }
}

class QuestionAnalysisDisplayData {
  const QuestionAnalysisDisplayData({
    required this.title,
    required this.content,
  });

  final String title;
  final String content;

  /// 练习解析区统一走展示协议，便于后续扩展到错题详情、报告页等场景。
  factory QuestionAnalysisDisplayData.practice({
    required String title,
    required String content,
  }) {
    return QuestionAnalysisDisplayData(
      title: title,
      content: content,
    );
  }
}

class QuestionActionDisplayData {
  const QuestionActionDisplayData({
    required this.label,
    required this.iconName,
    required this.onPressed,
    this.isPrimary = false,
  });

  final String label;
  final String iconName;
  final Future<void> Function()? onPressed;
  final bool isPrimary;
}

class QuestionActionBarDisplayData {
  const QuestionActionBarDisplayData({
    required this.title,
    required this.actions,
  });

  final String title;
  final List<QuestionActionDisplayData> actions;
}

class QuestionFeedbackDisplayData {
  const QuestionFeedbackDisplayData({
    required this.label,
    required this.color,
  });

  final String label;
  final String color;
}

class QuestionProgressDisplayData {
  const QuestionProgressDisplayData({
    required this.title,
    required this.currentNumber,
    required this.totalCount,
    required this.answeredCount,
    required this.remainingCount,
  });

  final String title;
  final int currentNumber;
  final int totalCount;
  final int answeredCount;
  final int remainingCount;
}

class QuestionBottomActionDisplayData {
  const QuestionBottomActionDisplayData({
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
    this.isExpanded = false,
  });

  final String label;
  final void Function()? onPressed;
  final bool isPrimary;
  final bool isExpanded;
}

class QuestionBottomActionBarDisplayData {
  const QuestionBottomActionBarDisplayData({
    required this.leadingAction,
    required this.primaryAction,
    required this.secondaryAction,
  });

  final QuestionBottomActionDisplayData leadingAction;
  final QuestionBottomActionDisplayData primaryAction;
  final QuestionBottomActionDisplayData secondaryAction;
}

class QuestionAnswerSheetItemDisplayData {
  const QuestionAnswerSheetItemDisplayData({
    required this.index,
    required this.label,
    required this.answered,
    required this.current,
  });

  final int index;
  final String label;
  final bool answered;
  final bool current;
}

class QuestionAnswerSheetDisplayData {
  const QuestionAnswerSheetDisplayData({
    required this.title,
    required this.items,
  });

  final String title;
  final List<QuestionAnswerSheetItemDisplayData> items;
}
