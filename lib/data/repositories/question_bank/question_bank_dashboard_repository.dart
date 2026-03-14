import '../../models/question_bank/question_bank_dashboard_models.dart';
import '../../models/subject/subject_models.dart';
import '../../remote/question_bank_remote_service.dart';

class QuestionBankDashboardRepository {
  QuestionBankDashboardRepository(this._remoteDataSource);

  final QuestionBankRemoteDataSource _remoteDataSource;

  Future<QuestionBankDashboardData> fetchDashboard({
    required String userId,
    required String subjectId,
    required String platform,
  }) async {
    final data = await _remoteDataSource.fetchDashboard(
      userId: userId,
      subjectId: subjectId,
      platform: platform,
    );
    return QuestionBankDashboardData.fromJson(data);
  }

  Future<PracticeCatalogData> fetchPracticeCatalog({
    required String userId,
    required String subjectId,
    required String platform,
  }) async {
    final data = await _remoteDataSource.getPracticeCatalog(
      userId: userId,
      subjectId: subjectId,
      platform: platform,
    );
    return PracticeCatalogData.fromJson(data);
  }

  Future<PracticeUnitListPageData> fetchPracticeUnitList({
    required String userId,
    required String subjectId,
    required String categoryCode,
    String keyword = '',
    String status = '',
    int page = 1,
    int pageSize = 20,
  }) async {
    final resolvedPage = page <= 0 ? 1 : page;
    final resolvedPageSize = pageSize <= 0 ? 20 : pageSize;
    final data = await _remoteDataSource.getPracticeUnitList(
      userId: userId,
      subjectId: subjectId,
      categoryCode: categoryCode,
      keyword: keyword,
      status: status,
      page: resolvedPage,
      pageSize: resolvedPageSize,
    );
    final items = _toMapList(data['objects'])
        .map(PracticeUnitPreviewData.fromJson)
        .toList()
      ..sort((a, b) => a.sort.compareTo(b.sort));
    return PracticeUnitListPageData(
      items: items,
      totalSize: _toInt(data['totalSize']),
      page: resolvedPage,
      pageSize: resolvedPageSize,
    );
  }

  QuestionBankDashboardData buildFallback({
    SubjectItem? currentSubject,
  }) {
    final subjectName = currentSubject?.name.trim() ?? '';
    final hasSubject = subjectName.isNotEmpty;
    final practiceModules = _defaultPracticeModules(enabled: hasSubject);
    final practiceCategories =
        practiceModules.map(PracticeCategoryCardData.fromLegacyModule).toList();

    return QuestionBankDashboardData(
      currentSubject: hasSubject
          ? CurrentSubjectViewData(
              subjectId: currentSubject?.id ?? '',
              subjectName: subjectName,
            )
          : null,
      examCountdown: null,
      continueSession: null,
      practiceModules: practiceModules,
      practiceCategories: practiceCategories,
      practiceUnitsPreview: const [],
      assetTools: _defaultAssetTools(enabled: hasSubject),
      todaySummary: const TodaySummaryViewData(
        doneQuestionCount: 0,
        correctRate: 0,
        recentPracticeCount: 0,
        pendingReviewWrongCount: 0,
      ),
      updatedAt: DateTime.now(),
    );
  }

  List<PracticeModuleViewData> _defaultPracticeModules({
    required bool enabled,
  }) {
    return const [
      ('chapter_practice', '章节练习', 'chapter', 10),
      ('knowledge_practice', '知识点练习', 'knowledge', 20),
      ('mock_paper', '模拟试卷', 'mock', 30),
      ('past_paper', '历年真题', 'paper', 40),
      ('high_frequency_point', '高频考点', 'hotpoint', 50),
      ('wrong_question_practice', '高频错题', 'wrong', 60),
    ].map((item) {
      return PracticeModuleViewData(
        moduleCode: item.$1,
        moduleName: item.$2,
        iconKey: item.$3,
        enabled: enabled,
        disabledReason: '',
        sort: item.$4,
        questionCount: 0,
        paperCount: 0,
        doneCount: 0,
        correctRate: 0,
        badgeText: '',
      );
    }).toList();
  }

  List<AssetToolViewData> _defaultAssetTools({
    required bool enabled,
  }) {
    return const [
      ('wrong_questions', '错题本', 'wrongbook', 10),
      ('practice_records', '做题记录', 'record', 20),
      ('question_favorites', '试题收藏', 'favorite', 30),
      ('practice_notes', '做题笔记', 'note', 40),
    ].map((item) {
      return AssetToolViewData(
        toolCode: item.$1,
        toolName: item.$2,
        iconKey: item.$3,
        enabled: enabled,
        disabledReason: '',
        sort: item.$4,
        count: 0,
        unreadCount: 0,
        badgeText: '',
      );
    }).toList();
  }
}

List<Map<String, dynamic>> _toMapList(dynamic raw) {
  if (raw is! List) {
    return const [];
  }
  return raw
      .map(
        (item) => item is Map<String, dynamic>
            ? item
            : item is Map
                ? item.map((key, value) => MapEntry(key.toString(), value))
                : const <String, dynamic>{},
      )
      .toList();
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
