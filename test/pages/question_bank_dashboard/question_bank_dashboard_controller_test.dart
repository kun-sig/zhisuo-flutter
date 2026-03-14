import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:zhisuo_flutter/data/models/question_bank/question_bank_dashboard_models.dart';
import 'package:zhisuo_flutter/data/repositories/question_bank/question_bank_dashboard_repository.dart';
import 'package:zhisuo_flutter/data/models/subject/subject_models.dart';
import 'package:zhisuo_flutter/i18n/locale_keys.dart';
import 'package:zhisuo_flutter/pages/question_bank_dashboard/question_bank_dashboard_controller.dart';

import '../../helpers/get_test_helper.dart';

void main() {
  group('QuestionBankDashboardController', () {
    tearDown(disposeGetTest);

    test('refreshDashboard success updates remote dashboard data', () async {
      configureGetTest();
      final subjectService = FakeCurrentSubjectService(
        subject: buildSubject(),
      );
      final repository = _FakeQuestionBankDashboardRepository(
        dashboardResult: _buildDashboardData(),
      );
      final controller = QuestionBankDashboardController(
        repository,
        subjectService,
        FakeAppSessionService(),
      );

      controller.onInit();
      await pumpController();

      expect(controller.errorText.value, isEmpty);
      expect(controller.subjectName, '软件设计师');
      expect(controller.dashboard.value.practiceCategories.single.enabled,
          isFalse);
      expect(
        controller.dashboard.value.practiceCategories.single.disabledReason,
        '维护中',
      );
      expect(
        controller.dashboard.value.practiceUnitsPreview.single.unitId,
        'chapter-1',
      );
      expect(controller.continueSession, isNull);
      controller.onClose();
    });

    test('continueSession falls back to latest practiced unit preview',
        () async {
      configureGetTest();
      final subjectService = FakeCurrentSubjectService(
        subject: buildSubject(),
      );
      final repository = _FakeQuestionBankDashboardRepository(
        dashboardResult: _buildDashboardDataWithContinueFallback(),
      );
      final controller = QuestionBankDashboardController(
        repository,
        subjectService,
        FakeAppSessionService(),
      );

      controller.onInit();
      await pumpController();

      expect(controller.continueSession, isNotNull);
      expect(controller.continueSession?.categoryCode, 'chapter');
      expect(controller.continueSession?.unitId, 'chapter-2');
      expect(controller.continueSession?.displayTitle, '第二章');
      expect(controller.continueSession?.progressText, '8/20');
      controller.onClose();
    });

    test('refreshDashboard failure falls back and exposes error text',
        () async {
      configureGetTest();
      final subjectService = FakeCurrentSubjectService(
        subject: buildSubject(),
      );
      final repository = _FakeQuestionBankDashboardRepository(
        dashboardError: Exception('network failed'),
      );
      final controller = QuestionBankDashboardController(
        repository,
        subjectService,
        FakeAppSessionService(),
      );

      controller.onInit();
      await pumpController();

      expect(
        controller.errorText.value,
        LocaleKeys.questionBankDashboardLoadFailed.tr,
      );
      expect(controller.dashboard.value.currentSubject?.subjectName, '软件设计师');
      expect(controller.dashboard.value.practiceCategories, isNotEmpty);
      controller.onClose();
    });
  });
}

class _FakeQuestionBankDashboardRepository
    implements QuestionBankDashboardRepository {
  _FakeQuestionBankDashboardRepository({
    this.dashboardResult,
    this.dashboardError,
  });

  final QuestionBankDashboardData? dashboardResult;
  final Object? dashboardError;

  @override
  QuestionBankDashboardData buildFallback({
    SubjectItem? currentSubject,
  }) {
    final subject = currentSubject;
    final hasSubject = subject != null;
    return QuestionBankDashboardData(
      currentSubject: hasSubject
          ? CurrentSubjectViewData(
              subjectId: subject.id,
              subjectName: subject.name,
            )
          : null,
      examCountdown: null,
      continueSession: null,
      practiceModules: const [],
      practiceCategories: [
        const PracticeCategoryCardData(
          categoryCode: 'chapter',
          categoryName: '章节练习',
          iconKey: 'chapter',
          enabled: false,
          disabledReason: '',
          sort: 10,
          unitCount: 0,
          completedUnitCount: 0,
          averageCorrectRate: 0,
          previewUnits: [],
        ),
      ],
      practiceUnitsPreview: const [],
      assetTools: const [],
      todaySummary: const TodaySummaryViewData(
        doneQuestionCount: 0,
        correctRate: 0,
        recentPracticeCount: 0,
        pendingReviewWrongCount: 0,
      ),
      updatedAt: DateTime(2026, 3, 14, 10),
    );
  }

  @override
  Future<QuestionBankDashboardData> fetchDashboard({
    required String userId,
    required String subjectId,
    required String platform,
  }) async {
    if (dashboardError != null) {
      throw dashboardError!;
    }
    return dashboardResult!;
  }

  @override
  Future<PracticeCatalogData> fetchPracticeCatalog({
    required String userId,
    required String subjectId,
    required String platform,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<PracticeUnitListPageData> fetchPracticeUnitList({
    required String userId,
    required String subjectId,
    required String categoryCode,
    String keyword = '',
    String status = '',
    int page = 1,
    int pageSize = 20,
  }) {
    throw UnimplementedError();
  }
}

QuestionBankDashboardData _buildDashboardData() {
  return QuestionBankDashboardData(
    currentSubject: const CurrentSubjectViewData(
      subjectId: 'subject-1',
      subjectName: '软件设计师',
    ),
    examCountdown: null,
    continueSession: null,
    practiceModules: const [],
    practiceCategories: const [
      PracticeCategoryCardData(
        categoryCode: 'chapter',
        categoryName: '章节练习',
        iconKey: 'chapter',
        enabled: false,
        disabledReason: '维护中',
        sort: 10,
        unitCount: 3,
        completedUnitCount: 1,
        averageCorrectRate: 80,
        previewUnits: [],
      ),
    ],
    practiceUnitsPreview: const [
      PracticeUnitPreviewData(
        unitId: 'chapter-1',
        categoryCode: 'chapter',
        refType: 'chapter',
        refId: 'chapter-1',
        title: '第一章',
        subtitle: '基础入门',
        status: 'disabled',
        questionCount: 20,
        completed: false,
        progressStatus: 'not_started',
        doneCount: 0,
        correctRate: 0,
        lastPracticedAt: null,
        sort: 10,
        extJson: '{"disabledReason":"暂未开放"}',
      ),
    ],
    assetTools: const [],
    todaySummary: const TodaySummaryViewData(
      doneQuestionCount: 12,
      correctRate: 75,
      recentPracticeCount: 2,
      pendingReviewWrongCount: 3,
    ),
    updatedAt: DateTime(2026, 3, 14, 10, 30),
  );
}

QuestionBankDashboardData _buildDashboardDataWithContinueFallback() {
  return QuestionBankDashboardData(
    currentSubject: const CurrentSubjectViewData(
      subjectId: 'subject-1',
      subjectName: '软件设计师',
    ),
    examCountdown: null,
    continueSession: null,
    practiceModules: const [],
    practiceCategories: const [
      PracticeCategoryCardData(
        categoryCode: 'chapter',
        categoryName: '章节练习',
        iconKey: 'chapter',
        enabled: true,
        disabledReason: '',
        sort: 10,
        unitCount: 3,
        completedUnitCount: 1,
        averageCorrectRate: 80,
        previewUnits: [],
      ),
    ],
    practiceUnitsPreview: [
      PracticeUnitPreviewData(
        unitId: 'chapter-1',
        categoryCode: 'chapter',
        refType: 'chapter',
        refId: 'chapter-1',
        title: '第一章',
        subtitle: '基础入门',
        status: 'enabled',
        questionCount: 20,
        completed: true,
        progressStatus: 'completed',
        doneCount: 20,
        correctRate: 82,
        lastPracticedAt: DateTime(2026, 3, 14, 10, 30),
        sort: 10,
        extJson: '',
      ),
      PracticeUnitPreviewData(
        unitId: 'chapter-2',
        categoryCode: 'chapter',
        refType: 'chapter',
        refId: 'chapter-2',
        title: '第二章',
        subtitle: '进阶',
        status: 'enabled',
        questionCount: 20,
        completed: false,
        progressStatus: 'in_progress',
        doneCount: 8,
        correctRate: 75,
        lastPracticedAt: DateTime(2026, 3, 14, 11, 00),
        sort: 20,
        extJson: '',
      ),
    ],
    assetTools: const [],
    todaySummary: const TodaySummaryViewData(
      doneQuestionCount: 12,
      correctRate: 75,
      recentPracticeCount: 2,
      pendingReviewWrongCount: 3,
    ),
    updatedAt: DateTime(2026, 3, 14, 11, 30),
  );
}
