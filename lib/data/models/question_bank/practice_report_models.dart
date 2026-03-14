class PracticeReportData {
  const PracticeReportData({
    required this.reportId,
    required this.sessionId,
    required this.categoryCode,
    required this.unitId,
    required this.unitTitle,
    required this.totalCount,
    required this.correctCount,
    required this.wrongCount,
    required this.correctRate,
    required this.durationSeconds,
    required this.chapterStats,
    required this.questionCategoryStats,
    required this.wrongQuestionIds,
  });

  final String reportId;
  final String sessionId;
  final String categoryCode;
  final String unitId;
  final String unitTitle;
  final int totalCount;
  final int correctCount;
  final int wrongCount;
  final double correctRate;
  final int durationSeconds;
  final List<PracticeReportStatData> chapterStats;
  final List<PracticeReportStatData> questionCategoryStats;
  final List<String> wrongQuestionIds;

  /// 解析练习报告响应，补齐单元上下文和统计信息。
  factory PracticeReportData.fromJson(Map<String, dynamic> json) {
    final report = _toMap(json['report']);
    return PracticeReportData(
      reportId: (report['reportId'] ?? '').toString(),
      sessionId: (report['sessionId'] ?? '').toString(),
      categoryCode: (report['categoryCode'] ?? '').toString(),
      unitId: (report['unitId'] ?? '').toString(),
      unitTitle: (report['unitTitle'] ?? '').toString(),
      totalCount: _toInt(report['totalCount']),
      correctCount: _toInt(report['correctCount']),
      wrongCount: _toInt(report['wrongCount']),
      correctRate: _toPercentRate(report['correctRate']),
      durationSeconds: _toInt(report['durationSeconds']),
      chapterStats: _toMapList(report['chapterStats'])
          .map(PracticeReportStatData.fromChapterJson)
          .toList(),
      questionCategoryStats: _toMapList(report['questionCategoryStats'])
          .map(PracticeReportStatData.fromQuestionCategoryJson)
          .toList(),
      wrongQuestionIds: _toStringList(report['wrongQuestionIds']),
    );
  }
}

class PracticeReportStatData {
  const PracticeReportStatData({
    required this.id,
    required this.name,
    required this.totalCount,
    required this.correctCount,
    required this.correctRate,
  });

  final String id;
  final String name;
  final int totalCount;
  final int correctCount;
  final double correctRate;

  factory PracticeReportStatData.fromChapterJson(Map<String, dynamic> json) {
    return PracticeReportStatData(
      id: (json['chapterId'] ?? '').toString(),
      name: (json['chapterName'] ?? '').toString(),
      totalCount: _toInt(json['totalCount']),
      correctCount: _toInt(json['correctCount']),
      correctRate: _toPercentRate(json['correctRate']),
    );
  }

  factory PracticeReportStatData.fromQuestionCategoryJson(
    Map<String, dynamic> json,
  ) {
    return PracticeReportStatData(
      id: (json['questionCategoryId'] ?? '').toString(),
      name: (json['questionCategoryName'] ?? '').toString(),
      totalCount: _toInt(json['totalCount']),
      correctCount: _toInt(json['correctCount']),
      correctRate: _toPercentRate(json['correctRate']),
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
