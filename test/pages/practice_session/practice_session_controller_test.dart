import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:zhisuo_flutter/data/models/question_bank/practice_report_models.dart';
import 'package:zhisuo_flutter/data/models/question_bank/practice_session_models.dart';
import 'package:zhisuo_flutter/data/repositories/question_bank/practice_session_repository.dart';
import 'package:zhisuo_flutter/i18n/locale_keys.dart';
import 'package:zhisuo_flutter/pages/practice_session/practice_session_controller.dart';

import '../../helpers/get_test_helper.dart';

void main() {
  group('PracticeSessionController', () {
    tearDown(disposeGetTest);

    test('loadInitial without subject returns missing subject error', () async {
      configureGetTest(
        arguments: const {
          'categoryCode': 'chapter',
          'unitId': 'chapter-1',
          'unitTitle': '第一章',
        },
      );
      final controller = PracticeSessionController(
        _FakePracticeSessionRepository(),
        FakeAppSessionService(),
        FakeCurrentSubjectService(),
      );

      controller.onInit();
      await pumpController();

      expect(
        controller.errorText.value,
        LocaleKeys.practiceSessionMissingSubject.tr,
      );
    });

    test('loadInitial success exposes route context and question state',
        () async {
      configureGetTest(
        arguments: const {
          'categoryCode': 'chapter',
          'unitId': 'chapter-1',
          'unitTitle': '第一章',
          'questionCount': 10,
        },
      );
      final controller = PracticeSessionController(
        _FakePracticeSessionRepository(),
        FakeAppSessionService(),
        FakeCurrentSubjectService(subject: buildSubject()),
      );

      controller.onInit();
      await pumpController();

      expect(controller.errorText.value, isEmpty);
      expect(controller.pageTitle, '第一章');
      expect(controller.categoryDisplayName, '章节练习');
      expect(controller.unitProgressStatusText, '进行中');
      expect(controller.unitCorrectRateText, '75%');
      expect(controller.unitDoneCountText, '12');
      expect(controller.currentQuestion?.questionId, 'question-2');

      controller.selectOption('A');

      expect(controller.selectedAnswers, ['A']);
      controller.goPrevious();
      expect(controller.currentIndex.value, 0);
      expect(controller.currentQuestion?.questionId, 'question-1');
    });

    test('loadInitial with unit context prefers startSession recovery',
        () async {
      configureGetTest(
        arguments: const {
          'sessionId': 'stale-session',
          'categoryCode': 'chapter',
          'unitId': 'chapter-1',
          'unitTitle': '第一章',
        },
      );
      final repository = _FakePracticeSessionRepository(
        launchSessionId: 'session-2',
      );
      final controller = PracticeSessionController(
        repository,
        FakeAppSessionService(),
        FakeCurrentSubjectService(subject: buildSubject()),
      );

      controller.onInit();
      await pumpController();

      expect(repository.startSessionCallCount, 1);
      expect(repository.fetchSessionIds, ['session-2']);
      expect(controller.data?.session.sessionId, 'session-2');
      expect(controller.pageTitle, '第一章');
    });
  });
}

class _FakePracticeSessionRepository implements PracticeSessionRepository {
  _FakePracticeSessionRepository({
    this.launchSessionId = 'session-1',
  });

  final String launchSessionId;
  int startSessionCallCount = 0;
  final List<String> fetchSessionIds = <String>[];

  @override
  Future<PracticeReportData> fetchReport({
    required String sessionId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<PracticeSessionData> fetchSession({
    required String sessionId,
  }) async {
    fetchSessionIds.add(sessionId);
    return PracticeSessionData(
      session: PracticeSessionSummaryData(
        sessionId: sessionId,
        userId: 'demo-user',
        subjectId: 'subject-1',
        practiceMode: 'chapter_practice',
        status: 'in_progress',
        questionCount: 2,
        answeredCount: 1,
        correctCount: 1,
        wrongCount: 0,
        startedAt: null,
        finishedAt: null,
        lastAnsweredAt: null,
        sourceType: 'practice_unit',
        sourceId: 'chapter-1',
        sourceTitle: '章节练习',
        categoryCode: 'chapter',
        unitId: 'chapter-1',
        unitTitle: '第一章',
        lastAnswerSummary: null,
      ),
      questions: [
        PracticeQuestionData(
          questionId: 'question-1',
          questionType: 'single',
          stem: '示例题干 1',
          options: [
            PracticeQuestionOptionData(
              label: 'A',
              text: '选项 A',
              imageUrl: '',
            ),
          ],
          analysis: '解析 1',
          favorite: false,
          noteCount: 0,
          noteSummary: '',
          noteUpdatedAt: null,
          answered: true,
          userAnswers: ['A'],
          chapterId: 'chapter-1',
          chapterName: '第一章',
          questionCategoryId: 'cat-1',
          questionCategoryName: '单选题',
        ),
        PracticeQuestionData(
          questionId: 'question-2',
          questionType: 'multiple',
          stem: '示例题干 2',
          options: [
            PracticeQuestionOptionData(
              label: 'A',
              text: '选项 A',
              imageUrl: '',
            ),
            PracticeQuestionOptionData(
              label: 'B',
              text: '选项 B',
              imageUrl: '',
            ),
          ],
          analysis: '解析 2',
          favorite: false,
          noteCount: 0,
          noteSummary: '',
          noteUpdatedAt: null,
          answered: false,
          userAnswers: [],
          chapterId: 'chapter-1',
          chapterName: '第一章',
          questionCategoryId: 'cat-2',
          questionCategoryName: '多选题',
        ),
      ],
      currentIndex: 1,
      remainingCount: 1,
      unitProgress: PracticeSessionUnitProgressData(
        unitId: 'chapter-1',
        categoryCode: 'chapter',
        completed: false,
        progressStatus: 'in_progress',
        sessionCount: 3,
        answeredCount: 12,
        correctCount: 9,
        wrongCount: 3,
        correctRate: 75,
        doneCount: 12,
        lastSessionId: sessionId,
        lastPracticedAt: null,
      ),
    );
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
  }) async {
    startSessionCallCount += 1;
    return PracticeSessionLaunchData(
      session: PracticeSessionSummaryData(
        sessionId: launchSessionId,
        userId: 'demo-user',
        subjectId: 'subject-1',
        practiceMode: 'chapter_practice',
        status: 'in_progress',
        questionCount: 2,
        answeredCount: 0,
        correctCount: 0,
        wrongCount: 0,
        startedAt: null,
        finishedAt: null,
        lastAnsweredAt: null,
        sourceType: 'practice_unit',
        sourceId: 'chapter-1',
        sourceTitle: '章节练习',
        categoryCode: 'chapter',
        unitId: 'chapter-1',
        unitTitle: '第一章',
        lastAnswerSummary: null,
      ),
      currentQuestion: null,
      currentIndex: 0,
      remainingCount: 2,
      unitProgress: null,
    );
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
