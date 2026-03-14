import 'package:get/get.dart';

import '../../data/models/question_bank/practice_report_models.dart';
import '../../data/repositories/question_bank/practice_session_repository.dart';
import '../../i18n/locale_keys.dart';
import '../../logger/logger.dart';

class PracticeReportController extends GetxController {
  PracticeReportController(this._repository);

  final PracticeSessionRepository _repository;

  final isLoading = false.obs;
  final errorText = ''.obs;
  final reportData = Rxn<PracticeReportData>();

  String _sessionId = '';
  String _categoryCode = '';
  String _unitId = '';
  String _unitTitle = '';

  PracticeReportData? get data => reportData.value;

  /// 报告页标题优先显示单元标题，缺失时回退默认标题。
  String get pageTitle {
    final routeTitle = _unitTitle.trim();
    if (routeTitle.isNotEmpty) {
      return routeTitle;
    }
    final reportTitle = data?.unitTitle.trim() ?? '';
    if (reportTitle.isNotEmpty) {
      return reportTitle;
    }
    return LocaleKeys.practiceReportTitle.tr;
  }

  /// 报告页分类文案优先展示报告返回值，没有时回退路由参数。
  String get categoryDisplayName {
    final code = data?.categoryCode.trim().isNotEmpty == true
        ? data!.categoryCode.trim()
        : _categoryCode.trim();
    if (code.isEmpty) {
      return '--';
    }
    return _resolveCategoryName(code);
  }

  String get unitIdText {
    final value = data?.unitId.trim().isNotEmpty == true
        ? data!.unitId.trim()
        : _unitId.trim();
    if (value.isEmpty) {
      return '--';
    }
    return value;
  }

  /// 基于报告结果生成最小复习建议，优先覆盖错题、薄弱章节和薄弱题型。
  List<String> get reviewSuggestions {
    final report = data;
    if (report == null) {
      return const [];
    }

    final suggestions = <String>[];
    if (report.wrongQuestionIds.isNotEmpty) {
      suggestions.add(
        LocaleKeys.practiceReportSuggestionReviewWrong.trParams({
          'count': '${report.wrongQuestionIds.length}',
        }),
      );
    }

    final weakestChapter = _findWeakestStat(report.chapterStats);
    if (weakestChapter != null && weakestChapter.correctRate < 80) {
      suggestions.add(
        LocaleKeys.practiceReportSuggestionWeakChapter.trParams({
          'name': weakestChapter.name.trim().isEmpty ? '--' : weakestChapter.name,
        }),
      );
    }

    final weakestCategory = _findWeakestStat(report.questionCategoryStats);
    if (weakestCategory != null && weakestCategory.correctRate < 80) {
      suggestions.add(
        LocaleKeys.practiceReportSuggestionWeakCategory.trParams({
          'name':
              weakestCategory.name.trim().isEmpty ? '--' : weakestCategory.name,
        }),
      );
    }

    final avgCostSeconds =
        report.totalCount <= 0 ? 0 : report.durationSeconds / report.totalCount;
    if (report.correctRate < 70 && avgCostSeconds > 0 && avgCostSeconds < 25) {
      suggestions.add(LocaleKeys.practiceReportSuggestionSlowDown.tr);
    }

    if (report.correctRate < 85 && report.totalCount > 0) {
      suggestions.add(LocaleKeys.practiceReportSuggestionRetryUnit.tr);
    }

    if (suggestions.isEmpty) {
      suggestions.add(LocaleKeys.practiceReportSuggestionPerfect.tr);
    }
    return suggestions;
  }

  @override
  void onInit() {
    super.onInit();
    _readArguments();
    loadReport();
  }

  Future<void> retry() async {
    await loadReport();
  }

  Future<void> loadReport() async {
    if (_sessionId.trim().isEmpty) {
      errorText.value = LocaleKeys.practiceReportEmpty.tr;
      return;
    }

    isLoading.value = true;
    errorText.value = '';
    try {
      reportData.value = await _repository.fetchReport(
        sessionId: _sessionId,
      );
    } catch (e, stackTrace) {
      Logger.e(
        'PracticeReportController.loadReport failed',
        error: e,
        stackTrace: stackTrace,
      );
      errorText.value = LocaleKeys.practiceReportLoadFailed.tr;
    } finally {
      isLoading.value = false;
    }
  }

  void _readArguments() {
    final args = Get.arguments;
    if (args is! Map) {
      return;
    }
    _sessionId = (args['sessionId'] ?? '').toString().trim();
    _categoryCode = (args['categoryCode'] ?? '').toString().trim();
    _unitId = (args['unitId'] ?? '').toString().trim();
    _unitTitle = (args['unitTitle'] ?? '').toString().trim();
  }

  /// 从统计列表中找出当前最薄弱的一项，优先按正确率升序再按题量降序排序。
  PracticeReportStatData? _findWeakestStat(List<PracticeReportStatData> stats) {
    if (stats.isEmpty) {
      return null;
    }
    final next = List<PracticeReportStatData>.from(stats);
    next.sort((a, b) {
      final rateCompare = a.correctRate.compareTo(b.correctRate);
      if (rateCompare != 0) {
        return rateCompare;
      }
      return b.totalCount.compareTo(a.totalCount);
    });
    return next.first;
  }

  /// 兼容后端当前主要返回分类编码的阶段，前端先做最小分类名映射。
  String _resolveCategoryName(String categoryCode) {
    switch (categoryCode.trim().toLowerCase()) {
      case 'chapter':
      case 'chapter_practice':
        return LocaleKeys.practiceReportCategoryChapter.tr;
      case 'knowledge_point':
      case 'knowledge_practice':
        return LocaleKeys.practiceReportCategoryKnowledge.tr;
      case 'mock_paper':
      case 'mock_exam':
        return LocaleKeys.practiceReportCategoryMock.tr;
      case 'past_paper':
        return LocaleKeys.practiceReportCategoryPastPaper.tr;
      case 'wrong_question_practice':
        return LocaleKeys.practiceReportCategoryWrongQuestion.tr;
      default:
        return categoryCode.trim();
    }
  }
}
