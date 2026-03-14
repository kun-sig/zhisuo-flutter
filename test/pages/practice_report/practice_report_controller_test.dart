import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:zhisuo_flutter/data/models/question_bank/practice_report_models.dart';
import 'package:zhisuo_flutter/data/models/question_bank/practice_session_models.dart';
import 'package:zhisuo_flutter/data/repositories/question_bank/practice_session_repository.dart';
import 'package:zhisuo_flutter/i18n/locale_keys.dart';
import 'package:zhisuo_flutter/pages/practice_report/practice_report_controller.dart';

import '../../helpers/get_test_helper.dart';

void main() {
  group('PracticeReportController', () {
    tearDown(disposeGetTest);

    test('loadReport without sessionId returns empty error', () async {
      configureGetTest(arguments: const {});
      final controller = PracticeReportController(
        _FakePracticeReportRepository(),
      );

      controller.onInit();
      await pumpController();

      expect(controller.errorText.value, LocaleKeys.practiceReportEmpty.tr);
      expect(controller.data, isNull);
    });

    test('loadReport success exposes report context', () async {
      configureGetTest(
        arguments: const {
          'sessionId': 'session-1',
          'categoryCode': 'chapter',
          'unitId': 'chapter-1',
          'unitTitle': '第一章',
        },
      );
      final controller = PracticeReportController(
        _FakePracticeReportRepository(),
      );

      controller.onInit();
      await pumpController();

      expect(controller.errorText.value, isEmpty);
      expect(controller.pageTitle, '第一章');
      expect(controller.categoryDisplayName, '章节练习');
      expect(controller.unitIdText, 'chapter-1');
      expect(controller.data?.wrongQuestionIds, ['question-2']);
    });

    test('reviewSuggestions returns targeted actions for weak report',
        () async {
      configureGetTest(
        arguments: const {
          'sessionId': 'session-1',
          'categoryCode': 'chapter',
          'unitId': 'chapter-1',
          'unitTitle': '第一章',
        },
      );
      final controller = PracticeReportController(
        _FakePracticeReportRepository(),
      );

      controller.onInit();
      await pumpController();

      expect(
        controller.reviewSuggestions,
        [
          '本次共有 1 道错题，建议先逐题回看解析并整理易错点。',
          '当前最薄弱章节是“第一章”，建议优先回顾该章节后再重做本单元。',
          '当前最薄弱题型是“单选题”，建议集中复习对应题型的解题方法。',
          '本次答题节奏偏快且正确率一般，建议下一次适当放慢审题与排除步骤。',
          '建议在整理完错题后重新完成一次本单元练习，确认知识点已经稳定掌握。',
        ],
      );
    });

    test('reviewSuggestions falls back to stable suggestion for good report',
        () async {
      configureGetTest(
        arguments: const {
          'sessionId': 'session-2',
          'categoryCode': 'chapter',
          'unitId': 'chapter-2',
          'unitTitle': '第二章',
        },
      );
      final controller = PracticeReportController(
        _FakePerfectPracticeReportRepository(),
      );

      controller.onInit();
      await pumpController();

      expect(
        controller.reviewSuggestions,
        [
          '本次练习整体表现稳定，建议直接进入下一单元或用错题本做巩固复盘。',
        ],
      );
    });
  });
}

class _FakePracticeReportRepository implements PracticeSessionRepository {
  @override
  Future<PracticeReportData> fetchReport({
    required String sessionId,
  }) async {
    return const PracticeReportData(
      reportId: 'report-1',
      sessionId: 'session-1',
      categoryCode: 'chapter',
      unitId: 'chapter-1',
      unitTitle: '第一章',
      totalCount: 2,
      correctCount: 1,
      wrongCount: 1,
      correctRate: 50,
      durationSeconds: 40,
      chapterStats: [
        PracticeReportStatData(
          id: 'chapter-1',
          name: '第一章',
          totalCount: 2,
          correctCount: 1,
          correctRate: 50,
        ),
      ],
      questionCategoryStats: [
        PracticeReportStatData(
          id: 'cat-1',
          name: '单选题',
          totalCount: 2,
          correctCount: 1,
          correctRate: 50,
        ),
      ],
      wrongQuestionIds: ['question-2'],
    );
  }

  @override
  Future<PracticeSessionData> fetchSession({
    required String sessionId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<FinishPracticeSessionResult> finishSession({
    required String sessionId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<PracticeSessionLaunchData> startSession({
    required String userId,
    required String subjectId,
    required String categoryCode,
    required String unitId,
    int questionCount = 20,
    bool continueIfExists = true,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<PracticeSubmitResult> submitAnswer({
    required String sessionId,
    required String questionId,
    required List<String> answers,
    int costSeconds = 0,
  }) {
    throw UnimplementedError();
  }
}

class _FakePerfectPracticeReportRepository
    implements PracticeSessionRepository {
  @override
  Future<PracticeReportData> fetchReport({
    required String sessionId,
  }) async {
    return const PracticeReportData(
      reportId: 'report-2',
      sessionId: 'session-2',
      categoryCode: 'chapter',
      unitId: 'chapter-2',
      unitTitle: '第二章',
      totalCount: 10,
      correctCount: 10,
      wrongCount: 0,
      correctRate: 100,
      durationSeconds: 600,
      chapterStats: [
        PracticeReportStatData(
          id: 'chapter-2',
          name: '第二章',
          totalCount: 10,
          correctCount: 10,
          correctRate: 100,
        ),
      ],
      questionCategoryStats: [
        PracticeReportStatData(
          id: 'cat-1',
          name: '单选题',
          totalCount: 10,
          correctCount: 10,
          correctRate: 100,
        ),
      ],
      wrongQuestionIds: [],
    );
  }

  @override
  Future<PracticeSessionData> fetchSession({
    required String sessionId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<FinishPracticeSessionResult> finishSession({
    required String sessionId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<PracticeSessionLaunchData> startSession({
    required String userId,
    required String subjectId,
    required String categoryCode,
    required String unitId,
    int questionCount = 20,
    bool continueIfExists = true,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<PracticeSubmitResult> submitAnswer({
    required String sessionId,
    required String questionId,
    required List<String> answers,
    int costSeconds = 0,
  }) {
    throw UnimplementedError();
  }
}
