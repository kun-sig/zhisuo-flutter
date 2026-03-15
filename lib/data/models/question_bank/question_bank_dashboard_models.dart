import 'dart:convert';

import 'package:get/get.dart';

import '../../../i18n/locale_keys.dart';

class QuestionBankDashboardData {
  const QuestionBankDashboardData({
    required this.currentSubject,
    required this.examCountdown,
    required this.continueSession,
    required this.practiceCategories,
    required this.practiceUnitsPreview,
    required this.assetTools,
    required this.todaySummary,
    required this.updatedAt,
  });

  final CurrentSubjectViewData? currentSubject;
  final ExamCountdownViewData? examCountdown;
  final ContinueSessionViewData? continueSession;
  final List<PracticeCategoryCardData> practiceCategories;
  final List<PracticeUnitPreviewData> practiceUnitsPreview;
  final List<AssetToolViewData> assetTools;
  final TodaySummaryViewData? todaySummary;
  final DateTime? updatedAt;

  factory QuestionBankDashboardData.fromJson(Map<String, dynamic> json) {
    final practiceCategories = _toMapList(json['practiceCategories'])
        .map(PracticeCategoryCardData.fromJson)
        .toList()
      ..sort((a, b) => a.sort.compareTo(b.sort));

    final practiceUnitsPreview = _toMapList(json['practiceUnitsPreview'])
        .map(PracticeUnitPreviewData.fromJson)
        .toList()
      ..sort((a, b) => a.sort.compareTo(b.sort));

    final previewFallbacks = practiceUnitsPreview.isEmpty
        ? (practiceCategories
            .expand((category) => category.previewUnits)
            .toList()
          ..sort((a, b) => a.sort.compareTo(b.sort)))
        : practiceUnitsPreview;

    final assetTools = _toMapList(json['assetTools'])
        .map(AssetToolViewData.fromJson)
        .toList()
      ..sort((a, b) => a.sort.compareTo(b.sort));

    return QuestionBankDashboardData(
      currentSubject: _nullableObject(
        json['currentSubject'],
        CurrentSubjectViewData.fromJson,
      ),
      examCountdown: _nullableObject(
        json['examCountdown'],
        ExamCountdownViewData.fromJson,
      ),
      continueSession: _nullableObject(
        json['continueSession'],
        ContinueSessionViewData.fromJson,
      ),
      practiceCategories: practiceCategories,
      practiceUnitsPreview: previewFallbacks,
      assetTools: assetTools,
      todaySummary:
          _nullableObject(json['todaySummary'], TodaySummaryViewData.fromJson),
      updatedAt: _toDateTime(json['updatedAt']),
    );
  }
}

class PracticeCatalogData {
  const PracticeCatalogData({
    required this.categories,
    required this.updatedAt,
  });

  final List<PracticeCategoryCardData> categories;
  final DateTime? updatedAt;

  factory PracticeCatalogData.fromJson(Map<String, dynamic> json) {
    final categories = _toMapList(json['categories'])
        .map(PracticeCategoryCardData.fromJson)
        .toList()
      ..sort((a, b) => a.sort.compareTo(b.sort));
    return PracticeCatalogData(
      categories: categories,
      updatedAt: _toDateTime(json['updatedAt']),
    );
  }
}

class PracticeUnitListPageData {
  const PracticeUnitListPageData({
    required this.items,
    required this.totalSize,
    required this.page,
    required this.pageSize,
  });

  final List<PracticeUnitPreviewData> items;
  final int totalSize;
  final int page;
  final int pageSize;

  bool get hasMore => page * pageSize < totalSize;
}

class CurrentSubjectViewData {
  const CurrentSubjectViewData({
    required this.subjectId,
    required this.subjectName,
  });

  final String subjectId;
  final String subjectName;

  factory CurrentSubjectViewData.fromJson(Map<String, dynamic> json) {
    return CurrentSubjectViewData(
      subjectId: (json['subjectId'] ?? '').toString(),
      subjectName: (json['subjectName'] ?? '').toString(),
    );
  }
}

class ExamCountdownViewData {
  const ExamCountdownViewData({
    required this.examDate,
    required this.countdownDays,
  });

  final DateTime? examDate;
  final int countdownDays;

  factory ExamCountdownViewData.fromJson(Map<String, dynamic> json) {
    return ExamCountdownViewData(
      examDate: _toDateTime(json['examDate']),
      countdownDays: _toInt(json['countdownDays']),
    );
  }
}

class ContinueSessionViewData {
  const ContinueSessionViewData({
    required this.sessionId,
    required this.progressText,
    required this.lastAnsweredAt,
    required this.categoryCode,
    required this.unitId,
    required this.unitTitle,
  });

  final String sessionId;
  final String progressText;
  final DateTime? lastAnsweredAt;
  final String categoryCode;
  final String unitId;
  final String unitTitle;

  /// 判断当前继续练习卡片是否已经具备按单元恢复所需的最小上下文。
  bool get hasUnitContext =>
      categoryCode.trim().isNotEmpty && unitId.trim().isNotEmpty;

  String get displayTitle {
    final title = unitTitle.trim();
    if (title.isNotEmpty) {
      return title;
    }
    return _resolvePracticeCategoryDisplayName(categoryCode);
  }

  factory ContinueSessionViewData.fromJson(Map<String, dynamic> json) {
    return ContinueSessionViewData(
      sessionId: (json['sessionId'] ?? '').toString(),
      progressText: (json['progressText'] ?? '').toString(),
      lastAnsweredAt: _toDateTime(json['lastAnsweredAt']),
      categoryCode: (json['categoryCode'] ?? '').toString(),
      unitId: (json['unitId'] ?? '').toString(),
      unitTitle: (json['unitTitle'] ?? '').toString(),
    );
  }

  /// 用单元预览聚合结果兜底继续练习卡片，确保首页可按 `categoryCode + unitId` 恢复。
  factory ContinueSessionViewData.fromUnitPreview(
      PracticeUnitPreviewData unit) {
    final questionCount = unit.questionCount <= 0 ? 0 : unit.questionCount;
    final progressText = questionCount > 0
        ? '${unit.doneCount}/$questionCount'
        : '${unit.doneCount}';
    return ContinueSessionViewData(
      sessionId: '',
      progressText: progressText,
      lastAnsweredAt: unit.lastPracticedAt,
      categoryCode: unit.categoryCode,
      unitId: unit.unitId,
      unitTitle: unit.title,
    );
  }
}

/// 统一把分类编码转换成页面可读文案，避免首页继续练习直接透出协议字段。
String _resolvePracticeCategoryDisplayName(String categoryCode) {
  switch (categoryCode.trim().toLowerCase()) {
    case 'chapter':
      return LocaleKeys.practiceSessionCategoryChapter.tr;
    case 'knowledge_point':
      return LocaleKeys.practiceSessionCategoryKnowledge.tr;
    case 'mock_paper':
      return LocaleKeys.practiceSessionCategoryMock.tr;
    case 'past_paper':
      return LocaleKeys.practiceSessionCategoryPastPaper.tr;
    case 'wrong_question_practice':
      return LocaleKeys.practiceSessionCategoryWrongQuestion.tr;
    default:
      final value = categoryCode.trim();
      if (value.isEmpty) {
        return '--';
      }
      return value;
  }
}

class PracticeCategoryCardData {
  const PracticeCategoryCardData({
    required this.categoryCode,
    required this.categoryName,
    required this.iconKey,
    required this.enabled,
    required this.disabledReason,
    required this.sort,
    required this.unitCount,
    required this.completedUnitCount,
    required this.averageCorrectRate,
    required this.previewUnits,
  });

  final String categoryCode;
  final String categoryName;
  final String iconKey;
  final bool enabled;
  final String disabledReason;
  final int sort;
  final int unitCount;
  final int completedUnitCount;
  final double averageCorrectRate;
  final List<PracticeUnitPreviewData> previewUnits;

  factory PracticeCategoryCardData.fromJson(Map<String, dynamic> json) {
    final previewUnits = _toMapList(json['previewUnits'])
        .map(PracticeUnitPreviewData.fromJson)
        .toList()
      ..sort((a, b) => a.sort.compareTo(b.sort));

    return PracticeCategoryCardData(
      categoryCode: (json['categoryCode'] ?? '').toString(),
      categoryName: (json['categoryName'] ?? '').toString(),
      iconKey: (json['iconKey'] ?? '').toString(),
      enabled: json['enabled'] == true,
      disabledReason: (json['disabledReason'] ?? '').toString(),
      sort: _toInt(json['sort']),
      unitCount: _toInt(json['unitCount']),
      completedUnitCount: _toInt(json['completedUnitCount']),
      averageCorrectRate: _toPercentRate(json['averageCorrectRate']),
      previewUnits: previewUnits,
    );
  }
}

class PracticeUnitPreviewData {
  const PracticeUnitPreviewData({
    required this.unitId,
    required this.categoryCode,
    required this.refType,
    required this.refId,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.questionCount,
    required this.completed,
    required this.progressStatus,
    required this.doneCount,
    required this.correctRate,
    required this.lastPracticedAt,
    required this.sort,
    required this.extJson,
  });

  final String unitId;
  final String categoryCode;
  final String refType;
  final String refId;
  final String title;
  final String subtitle;
  final String status;
  final int questionCount;
  final bool completed;
  final String progressStatus;
  final int doneCount;
  final double correctRate;
  final DateTime? lastPracticedAt;
  final int sort;
  final String extJson;

  bool get isEnabled {
    final value = status.trim().toLowerCase();
    return value != 'disabled' && value != 'hidden';
  }

  /// 统一从扩展字段中提取单元禁用原因，兼容后端灰度或状态说明透传。
  String get disabledReason {
    if (isEnabled) {
      return '';
    }
    final ext = _decodeJsonObject(extJson);
    const keys = [
      'disabledReason',
      'reason',
      'message',
      'statusReason',
      'grayReason',
    ];
    final direct = _readFirstString(ext, keys);
    if (direct.isNotEmpty) {
      return direct;
    }
    for (final nestedKey in const ['gray', 'featureToggle', 'status']) {
      final nested = _toMap(ext[nestedKey]);
      final value = _readFirstString(nested, keys);
      if (value.isNotEmpty) {
        return value;
      }
    }
    return '';
  }

  factory PracticeUnitPreviewData.fromJson(Map<String, dynamic> json) {
    return PracticeUnitPreviewData(
      unitId: (json['unitId'] ?? '').toString(),
      categoryCode: (json['categoryCode'] ?? '').toString(),
      refType: (json['refType'] ?? '').toString(),
      refId: (json['refId'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      questionCount: _toInt(json['questionCount']),
      completed: json['completed'] == true,
      progressStatus: (json['progressStatus'] ?? '').toString(),
      doneCount: _toInt(json['doneCount']),
      correctRate: _toPercentRate(json['correctRate']),
      lastPracticedAt: _toDateTime(json['lastPracticedAt']),
      sort: _toInt(json['sort']),
      extJson: (json['extJson'] ?? '').toString(),
    );
  }
}

class PracticeUnitProgressData {
  const PracticeUnitProgressData({
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

  factory PracticeUnitProgressData.fromJson(Map<String, dynamic> json) {
    return PracticeUnitProgressData(
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

class AssetToolViewData {
  const AssetToolViewData({
    required this.toolCode,
    required this.toolName,
    required this.iconKey,
    required this.enabled,
    required this.disabledReason,
    required this.sort,
    required this.count,
    required this.unreadCount,
    required this.badgeText,
  });

  final String toolCode;
  final String toolName;
  final String iconKey;
  final bool enabled;
  final String disabledReason;
  final int sort;
  final int count;
  final int unreadCount;
  final String badgeText;

  factory AssetToolViewData.fromJson(Map<String, dynamic> json) {
    return AssetToolViewData(
      toolCode: (json['toolCode'] ?? '').toString(),
      toolName: (json['toolName'] ?? '').toString(),
      iconKey: (json['iconKey'] ?? '').toString(),
      enabled: json['enabled'] == true,
      disabledReason: (json['disabledReason'] ?? '').toString(),
      sort: _toInt(json['sort']),
      count: _toInt(json['count']),
      unreadCount: _toInt(json['unreadCount']),
      badgeText: (json['badgeText'] ?? '').toString(),
    );
  }
}

class TodaySummaryViewData {
  const TodaySummaryViewData({
    required this.doneQuestionCount,
    required this.correctRate,
    required this.recentPracticeCount,
    required this.pendingReviewWrongCount,
  });

  final int doneQuestionCount;
  final double correctRate;
  final int recentPracticeCount;
  final int pendingReviewWrongCount;

  factory TodaySummaryViewData.fromJson(Map<String, dynamic> json) {
    return TodaySummaryViewData(
      doneQuestionCount: _toInt(json['doneQuestionCount']),
      correctRate: _toPercentRate(json['correctRate']),
      recentPracticeCount: _toInt(json['recentPracticeCount']),
      pendingReviewWrongCount: _toInt(json['pendingReviewWrongCount']),
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

/// 解析扩展 JSON 字符串，失败时返回空对象，避免灰度字段解析影响主流程。
Map<String, dynamic> _decodeJsonObject(String raw) {
  final text = raw.trim();
  if (text.isEmpty) {
    return const {};
  }
  try {
    return _toMap(jsonDecode(text));
  } catch (_) {
    return const {};
  }
}

/// 按候选 key 顺序读取第一个非空字符串，统一处理禁用原因兜底逻辑。
String _readFirstString(
  Map<String, dynamic> source,
  List<String> keys,
) {
  for (final key in keys) {
    final value = (source[key] ?? '').toString().trim();
    if (value.isNotEmpty) {
      return value;
    }
  }
  return '';
}

List<Map<String, dynamic>> _toMapList(dynamic raw) {
  if (raw is! List) {
    return const [];
  }
  return raw.map(_toMap).toList();
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

/// 统一把后端返回的比例值或百分比值折算成前端展示使用的百分比。
double _toPercentRate(dynamic value) {
  final rate = _toDouble(value);
  if (rate > 0 && rate <= 1) {
    return rate * 100;
  }
  return rate;
}

DateTime? _toDateTime(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is DateTime) {
    return value;
  }
  if (value is int) {
    if (value <= 0) {
      return null;
    }
    return value > 1000000000000
        ? DateTime.fromMillisecondsSinceEpoch(value)
        : DateTime.fromMillisecondsSinceEpoch(value * 1000);
  }
  if (value is num) {
    return _toDateTime(value.toInt());
  }

  final raw = value.toString().trim();
  if (raw.isEmpty) {
    return null;
  }

  final intValue = int.tryParse(raw);
  if (intValue != null) {
    return _toDateTime(intValue);
  }
  return DateTime.tryParse(raw);
}
