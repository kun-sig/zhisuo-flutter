class PracticeSessionLaunchData {
  const PracticeSessionLaunchData({
    required this.session,
    required this.currentQuestion,
    required this.currentIndex,
    required this.remainingCount,
    required this.unitProgress,
  });

  final PracticeSessionSummaryData session;
  final PracticeQuestionData? currentQuestion;
  final int currentIndex;
  final int remainingCount;
  final PracticeSessionUnitProgressData? unitProgress;

  /// 解析开始练习响应，补齐会话和单元进度上下文。
  factory PracticeSessionLaunchData.fromJson(Map<String, dynamic> json) {
    return PracticeSessionLaunchData(
      session: PracticeSessionSummaryData.fromJson(_toMap(json['session'])),
      currentQuestion: _nullableObject(
        json['currentQuestion'],
        PracticeQuestionData.fromJson,
      ),
      currentIndex: _toInt(json['currentIndex']),
      remainingCount: _toInt(json['remainingCount']),
      unitProgress: _nullableObject(
        json['unitProgress'],
        PracticeSessionUnitProgressData.fromJson,
      ),
    );
  }
}

class PracticeSessionData {
  const PracticeSessionData({
    required this.session,
    required this.questions,
    required this.currentIndex,
    required this.remainingCount,
    required this.unitProgress,
  });

  final PracticeSessionSummaryData session;
  final List<PracticeQuestionData> questions;
  final int currentIndex;
  final int remainingCount;
  final PracticeSessionUnitProgressData? unitProgress;

  PracticeQuestionData? get currentQuestion {
    if (questions.isEmpty) {
      return null;
    }
    if (currentIndex < 0 || currentIndex >= questions.length) {
      return questions.first;
    }
    return questions[currentIndex];
  }

  PracticeSessionData copyWith({
    PracticeSessionSummaryData? session,
    List<PracticeQuestionData>? questions,
    int? currentIndex,
    int? remainingCount,
    PracticeSessionUnitProgressData? unitProgress,
  }) {
    return PracticeSessionData(
      session: session ?? this.session,
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      remainingCount: remainingCount ?? this.remainingCount,
      unitProgress: unitProgress ?? this.unitProgress,
    );
  }

  /// 解析会话详情响应，统一携带题目列表和单元进度信息。
  factory PracticeSessionData.fromJson(Map<String, dynamic> json) {
    return PracticeSessionData(
      session: PracticeSessionSummaryData.fromJson(_toMap(json['session'])),
      questions: _toMapList(json['questions'])
          .map(PracticeQuestionData.fromJson)
          .toList(),
      currentIndex: _toInt(json['currentIndex']),
      remainingCount: _toInt(json['remainingCount']),
      unitProgress: _nullableObject(
        json['unitProgress'],
        PracticeSessionUnitProgressData.fromJson,
      ),
    );
  }
}

class PracticeSessionSummaryData {
  const PracticeSessionSummaryData({
    required this.sessionId,
    required this.userId,
    required this.subjectId,
    required this.status,
    required this.questionCount,
    required this.answeredCount,
    required this.correctCount,
    required this.wrongCount,
    required this.startedAt,
    required this.finishedAt,
    required this.lastAnsweredAt,
    required this.categoryCode,
    required this.unitId,
    required this.unitTitle,
    required this.lastAnswerSummary,
  });

  final String sessionId;
  final String userId;
  final String subjectId;
  final String status;
  final int questionCount;
  final int answeredCount;
  final int correctCount;
  final int wrongCount;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final DateTime? lastAnsweredAt;
  final String categoryCode;
  final String unitId;
  final String unitTitle;
  final PracticeLastAnswerSummaryData? lastAnswerSummary;

  factory PracticeSessionSummaryData.fromJson(Map<String, dynamic> json) {
    return PracticeSessionSummaryData(
      sessionId: (json['sessionId'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      subjectId: (json['subjectId'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      questionCount: _toInt(json['questionCount']),
      answeredCount: _toInt(json['answeredCount']),
      correctCount: _toInt(json['correctCount']),
      wrongCount: _toInt(json['wrongCount']),
      startedAt: _toDateTime(json['startedAt']),
      finishedAt: _toDateTime(json['finishedAt']),
      lastAnsweredAt: _toDateTime(json['lastAnsweredAt']),
      categoryCode: (json['categoryCode'] ?? '').toString(),
      unitId: (json['unitId'] ?? '').toString(),
      unitTitle: (json['unitTitle'] ?? '').toString(),
      lastAnswerSummary: _nullableObject(
        json['lastAnswerSummary'],
        PracticeLastAnswerSummaryData.fromJson,
      ),
    );
  }
}

class PracticeLastAnswerSummaryData {
  const PracticeLastAnswerSummaryData({
    required this.questionId,
    required this.isCorrect,
    required this.userAnswers,
    required this.costSeconds,
    required this.submittedAt,
  });

  final String questionId;
  final bool isCorrect;
  final List<String> userAnswers;
  final int costSeconds;
  final DateTime? submittedAt;

  factory PracticeLastAnswerSummaryData.fromJson(Map<String, dynamic> json) {
    return PracticeLastAnswerSummaryData(
      questionId: (json['questionId'] ?? '').toString(),
      isCorrect: json['isCorrect'] == true,
      userAnswers: _toStringList(json['userAnswers']),
      costSeconds: _toInt(json['costSeconds']),
      submittedAt: _toDateTime(json['submittedAt']),
    );
  }
}

class PracticeSessionUnitProgressData {
  const PracticeSessionUnitProgressData({
    required this.unitId,
    required this.categoryCode,
    required this.completed,
    required this.progressStatus,
    required this.sessionCount,
    required this.answeredCount,
    required this.correctCount,
    required this.wrongCount,
    required this.correctRate,
    required this.doneCount,
    required this.lastSessionId,
    required this.lastPracticedAt,
  });

  final String unitId;
  final String categoryCode;
  final bool completed;
  final String progressStatus;
  final int sessionCount;
  final int answeredCount;
  final int correctCount;
  final int wrongCount;
  final double correctRate;
  final int doneCount;
  final String lastSessionId;
  final DateTime? lastPracticedAt;

  /// 解析会话关联的单元进度响应，供会话页展示学习上下文。
  factory PracticeSessionUnitProgressData.fromJson(Map<String, dynamic> json) {
    return PracticeSessionUnitProgressData(
      unitId: (json['unitId'] ?? '').toString(),
      categoryCode: (json['categoryCode'] ?? '').toString(),
      completed: json['completed'] == true,
      progressStatus: (json['progressStatus'] ?? '').toString(),
      sessionCount: _toInt(json['sessionCount']),
      answeredCount: _toInt(json['answeredCount']),
      correctCount: _toInt(json['correctCount']),
      wrongCount: _toInt(json['wrongCount']),
      correctRate: _toPercentRate(json['correctRate']),
      doneCount: _toInt(json['doneCount']),
      lastSessionId: (json['lastSessionId'] ?? '').toString(),
      lastPracticedAt: _toDateTime(json['lastPracticedAt']),
    );
  }
}

class PracticeQuestionData {
  const PracticeQuestionData({
    required this.questionId,
    required this.questionType,
    required this.stem,
    required this.options,
    required this.analysis,
    required this.favorite,
    required this.noteCount,
    required this.noteSummary,
    required this.noteUpdatedAt,
    required this.answered,
    required this.userAnswers,
    required this.chapterId,
    required this.chapterName,
    required this.questionCategoryId,
    required this.questionCategoryName,
  });

  final String questionId;
  final String questionType;
  final String stem;
  final List<PracticeQuestionOptionData> options;
  final String analysis;
  final bool favorite;
  final int noteCount;
  final String noteSummary;
  final DateTime? noteUpdatedAt;
  final bool answered;
  final List<String> userAnswers;
  final String chapterId;
  final String chapterName;
  final String questionCategoryId;
  final String questionCategoryName;

  bool get isSingleChoice {
    final type = questionType.trim().toLowerCase();
    return type == 'single' || type == 'single_choice';
  }

  bool get isMultipleChoice {
    final type = questionType.trim().toLowerCase();
    return type == 'multiple' || type == 'multiple_choice';
  }

  bool get isJudgement {
    final type = questionType.trim().toLowerCase();
    return type == 'judge' || type == 'judgement' || type == 'boolean';
  }

  PracticeQuestionData copyWith({
    bool? answered,
    List<String>? userAnswers,
    bool? favorite,
    int? noteCount,
    String? noteSummary,
    DateTime? noteUpdatedAt,
  }) {
    return PracticeQuestionData(
      questionId: questionId,
      questionType: questionType,
      stem: stem,
      options: options,
      analysis: analysis,
      favorite: favorite ?? this.favorite,
      noteCount: noteCount ?? this.noteCount,
      noteSummary: noteSummary ?? this.noteSummary,
      noteUpdatedAt: noteUpdatedAt ?? this.noteUpdatedAt,
      answered: answered ?? this.answered,
      userAnswers: userAnswers ?? this.userAnswers,
      chapterId: chapterId,
      chapterName: chapterName,
      questionCategoryId: questionCategoryId,
      questionCategoryName: questionCategoryName,
    );
  }

  factory PracticeQuestionData.fromJson(Map<String, dynamic> json) {
    return PracticeQuestionData(
      questionId: (json['questionId'] ?? '').toString(),
      questionType: (json['questionType'] ?? '').toString(),
      stem: (json['stem'] ?? '').toString(),
      options: _toMapList(json['options'])
          .map(PracticeQuestionOptionData.fromJson)
          .toList(),
      analysis: (json['analysis'] ?? '').toString(),
      favorite: json['favorite'] == true,
      noteCount: _toInt(json['noteCount']),
      noteSummary: (json['noteSummary'] ?? '').toString(),
      noteUpdatedAt: _toDateTime(json['noteUpdatedAt']),
      answered: json['answered'] == true,
      userAnswers: _toStringList(json['userAnswers']),
      chapterId: (json['chapterId'] ?? '').toString(),
      chapterName: (json['chapterName'] ?? '').toString(),
      questionCategoryId: (json['questionCategoryId'] ?? '').toString(),
      questionCategoryName: (json['questionCategoryName'] ?? '').toString(),
    );
  }
}

class PracticeQuestionOptionData {
  const PracticeQuestionOptionData({
    required this.label,
    required this.text,
    required this.imageUrl,
  });

  final String label;
  final String text;
  final String imageUrl;

  factory PracticeQuestionOptionData.fromJson(Map<String, dynamic> json) {
    return PracticeQuestionOptionData(
      label: (json['label'] ?? '').toString(),
      text: (json['text'] ?? '').toString(),
      imageUrl: (json['imageUrl'] ?? '').toString(),
    );
  }
}

class PracticeSubmitResult {
  const PracticeSubmitResult({
    required this.questionId,
    required this.isCorrect,
    required this.correctAnswers,
    required this.analysis,
    required this.answeredCount,
    required this.remainingCount,
  });

  final String questionId;
  final bool isCorrect;
  final List<String> correctAnswers;
  final String analysis;
  final int answeredCount;
  final int remainingCount;

  factory PracticeSubmitResult.fromJson(Map<String, dynamic> json) {
    return PracticeSubmitResult(
      questionId: (json['questionId'] ?? '').toString(),
      isCorrect: json['isCorrect'] == true,
      correctAnswers: _toStringList(json['correctAnswers']),
      analysis: (json['analysis'] ?? '').toString(),
      answeredCount: _toInt(json['answeredCount']),
      remainingCount: _toInt(json['remainingCount']),
    );
  }
}

class FinishPracticeSessionResult {
  const FinishPracticeSessionResult({
    required this.sessionId,
    required this.status,
    required this.reportId,
  });

  final String sessionId;
  final String status;
  final String reportId;

  factory FinishPracticeSessionResult.fromJson(Map<String, dynamic> json) {
    return FinishPracticeSessionResult(
      sessionId: (json['sessionId'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      reportId: (json['reportId'] ?? '').toString(),
    );
  }
}

T? _nullableObject<T>(
  dynamic raw,
  T Function(Map<String, dynamic>) mapper,
) {
  final map = _toMap(raw);
  if (map.isEmpty) {
    return null;
  }
  return mapper(map);
}

Map<String, dynamic> _toMap(dynamic raw) {
  if (raw is Map<String, dynamic>) {
    return raw;
  }
  if (raw is Map) {
    return raw.map((key, value) => MapEntry(key.toString(), value));
  }
  return const {};
}

List<Map<String, dynamic>> _toMapList(dynamic raw) {
  if (raw is! List) {
    return const [];
  }
  return raw.map(_toMap).toList();
}

List<String> _toStringList(dynamic raw) {
  if (raw is! List) {
    return const [];
  }
  return raw.map((item) => item.toString()).toList();
}

int _toInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _toDouble(dynamic value) {
  if (value is double) {
    return value;
  }
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

/// 统一把后端比例型正确率折算成页面展示使用的百分比。
double _toPercentRate(dynamic value) {
  final rate = _toDouble(value);
  if (rate > 0 && rate <= 1) {
    return rate * 100;
  }
  return rate;
}

DateTime? _toDateTime(dynamic value) {
  final seconds = _toInt(value);
  if (seconds <= 0) {
    return null;
  }
  return DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true)
      .toLocal();
}
