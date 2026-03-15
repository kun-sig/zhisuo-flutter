import 'package:get/get.dart';

import '../../../i18n/locale_keys.dart';

class AssetPageResult<T> {
  const AssetPageResult({
    required this.items,
    required this.totalSize,
    required this.page,
    required this.pageSize,
  });

  final List<T> items;
  final int totalSize;
  final int page;
  final int pageSize;

  bool get hasMore => page * pageSize < totalSize;
}

class WrongQuestionAssetItem {
  const WrongQuestionAssetItem({
    required this.id,
    required this.userId,
    required this.subjectId,
    required this.questionId,
    required this.wrongCount,
    required this.lastWrongAt,
    required this.status,
  });

  final String id;
  final String userId;
  final String subjectId;
  final String questionId;
  final int wrongCount;
  final DateTime? lastWrongAt;
  final String status;

  factory WrongQuestionAssetItem.fromJson(Map<String, dynamic> json) {
    return WrongQuestionAssetItem(
      id: (json['id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      subjectId: (json['subjectId'] ?? '').toString(),
      questionId: (json['questionId'] ?? '').toString(),
      wrongCount: _toInt(json['wrongCount']),
      lastWrongAt: _toDateTime(json['lastWrongAt']),
      status: (json['status'] ?? '').toString(),
    );
  }
}

class PracticeRecordAssetItem {
  const PracticeRecordAssetItem({
    required this.id,
    required this.userId,
    required this.subjectId,
    required this.sessionId,
    required this.categoryCode,
    required this.unitId,
    required this.unitTitle,
    required this.questionCount,
    required this.correctCount,
    required this.wrongCount,
    required this.correctRate,
    required this.durationSeconds,
    required this.finishedAt,
  });

  final String id;
  final String userId;
  final String subjectId;
  final String sessionId;
  final String categoryCode;
  final String unitId;
  final String unitTitle;
  final int questionCount;
  final int correctCount;
  final int wrongCount;
  final double correctRate;
  final int durationSeconds;
  final DateTime? finishedAt;

  /// 资产记录卡片优先展示正式单元标题，缺失时再回退到分类文案。
  String get displayTitle {
    final title = unitTitle.trim();
    if (title.isNotEmpty) {
      return title;
    }
    return _resolvePracticeCategoryDisplayName(categoryCode);
  }

  factory PracticeRecordAssetItem.fromJson(Map<String, dynamic> json) {
    return PracticeRecordAssetItem(
      id: (json['id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      subjectId: (json['subjectId'] ?? '').toString(),
      sessionId: (json['sessionId'] ?? '').toString(),
      categoryCode: (json['categoryCode'] ?? '').toString(),
      unitId: (json['unitId'] ?? '').toString(),
      unitTitle: (json['unitTitle'] ?? '').toString(),
      questionCount: _toInt(json['questionCount']),
      correctCount: _toInt(json['correctCount']),
      wrongCount: _toInt(json['wrongCount']),
      correctRate: _toPercentRate(json['correctRate']),
      durationSeconds: _toInt(json['durationSeconds']),
      finishedAt: _toDateTime(json['finishedAt']),
    );
  }
}

class QuestionFavoriteAssetItem {
  const QuestionFavoriteAssetItem({
    required this.id,
    required this.userId,
    required this.subjectId,
    required this.questionId,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String subjectId;
  final String questionId;
  final DateTime? createdAt;

  factory QuestionFavoriteAssetItem.fromJson(Map<String, dynamic> json) {
    return QuestionFavoriteAssetItem(
      id: (json['id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      subjectId: (json['subjectId'] ?? '').toString(),
      questionId: (json['questionId'] ?? '').toString(),
      createdAt: _toDateTime(json['createdAt']),
    );
  }
}

class PracticeNoteAssetItem {
  const PracticeNoteAssetItem({
    required this.id,
    required this.userId,
    required this.subjectId,
    required this.questionId,
    required this.sessionId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.reviewRemark,
    required this.reviewedAt,
  });

  final String id;
  final String userId;
  final String subjectId;
  final String questionId;
  final String sessionId;
  final String content;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String status;
  final String reviewRemark;
  final DateTime? reviewedAt;

  factory PracticeNoteAssetItem.fromJson(Map<String, dynamic> json) {
    return PracticeNoteAssetItem(
      id: (json['id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      subjectId: (json['subjectId'] ?? '').toString(),
      questionId: (json['questionId'] ?? '').toString(),
      sessionId: (json['sessionId'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      createdAt: _toDateTime(json['createdAt']),
      updatedAt: _toDateTime(json['updatedAt']),
      status: (json['status'] ?? '').toString(),
      reviewRemark: (json['reviewRemark'] ?? '').toString(),
      reviewedAt: _toDateTime(json['reviewedAt']),
    );
  }
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

AssetPageResult<T> mapAssetPageResult<T>(
  Map<String, dynamic> json, {
  required int page,
  required int pageSize,
  required T Function(Map<String, dynamic>) mapper,
}) {
  return AssetPageResult<T>(
    items: _toMapList(json['objects']).map(mapper).toList(),
    totalSize: _toInt(json['totalSize']),
    page: page,
    pageSize: pageSize,
  );
}

/// 统一把正式分类编码转换成页面可读文案，避免资产页直接暴露协议字段。
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
