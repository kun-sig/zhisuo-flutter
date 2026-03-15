import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:zhisuo_flutter/data/models/question_bank/asset_models.dart';
import 'package:zhisuo_flutter/data/models/question_bank/practice_report_models.dart';
import 'package:zhisuo_flutter/data/models/question_bank/practice_session_models.dart';
import 'package:zhisuo_flutter/data/remote/asset_remote_service.dart';
import 'package:zhisuo_flutter/data/repositories/question_bank/practice_asset_repository.dart';
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
        _FakePracticeAssetRepository(),
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
        _FakePracticeAssetRepository(),
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
        _FakePracticeAssetRepository(),
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

    test(
        'single choice submit auto advances when backend stays on answered question',
        () async {
      configureGetTest(arguments: const {'sessionId': 'session-1'});
      final repository = _FakePracticeSessionRepository(
        baseSession: _buildSessionData(
          currentIndex: 0,
          remainingCount: 2,
          answeredCount: 0,
          firstAnswered: false,
          firstAnswers: const [],
          secondAnswered: false,
        ),
        sessionAfterSubmit: _buildSessionData(
          currentIndex: 0,
          remainingCount: 1,
          answeredCount: 1,
          firstAnswered: true,
          firstAnswers: const ['A'],
          secondAnswered: false,
        ),
      );
      final controller = PracticeSessionController(
        repository,
        _FakePracticeAssetRepository(),
        FakeAppSessionService(),
        FakeCurrentSubjectService(subject: buildSubject()),
      );

      controller.onInit();
      await pumpController();
      controller.selectOption('A');
      await pumpController();

      expect(repository.submitAnswerCallCount, 1);
      expect(controller.currentIndex.value, 1);
      expect(controller.currentQuestion?.questionId, 'question-2');
      expect(controller.shouldShowAnalysis, isFalse);
    });

    test('answered question ignores option changes', () async {
      configureGetTest(arguments: const {'sessionId': 'session-1'});
      final controller = PracticeSessionController(
        _FakePracticeSessionRepository(
          baseSession: _buildSessionData(
            currentIndex: 0,
            remainingCount: 1,
            answeredCount: 1,
            firstAnswered: true,
            firstAnswers: const ['A'],
            secondAnswered: false,
          ),
        ),
        _FakePracticeAssetRepository(),
        FakeAppSessionService(),
        FakeCurrentSubjectService(subject: buildSubject()),
      );

      controller.onInit();
      await pumpController();
      controller.selectOption('B');

      expect(controller.selectedAnswers, ['A']);
    });

    test('toggle favorite updates current question state', () async {
      configureGetTest(arguments: const {'sessionId': 'session-1'});
      final assetRepository = _FakePracticeAssetRepository();
      final controller = PracticeSessionController(
        _FakePracticeSessionRepository(
          baseSession: _buildSessionData(
            currentIndex: 0,
            firstAnswered: false,
            firstAnswers: const [],
            secondAnswered: false,
          ),
        ),
        assetRepository,
        FakeAppSessionService(),
        FakeCurrentSubjectService(subject: buildSubject()),
      );

      controller.onInit();
      await pumpController();
      await controller.toggleCurrentQuestionFavorite();

      expect(assetRepository.toggleCallCount, 1);
      expect(controller.currentQuestion?.favorite, isTrue);
    });

    test('create note updates note summary and note count', () async {
      configureGetTest(arguments: const {'sessionId': 'session-1'});
      final assetRepository = _FakePracticeAssetRepository(
        createdNote: const PracticeNoteAssetItem(
          id: 'note-1',
          userId: 'demo-user',
          subjectId: 'subject-1',
          questionId: 'question-1',
          sessionId: 'session-1',
          content: '复习时先排除错误选项',
          createdAt: null,
          updatedAt: null,
          status: 'pending',
          reviewRemark: '',
          reviewedAt: null,
        ),
      );
      final controller = PracticeSessionController(
        _FakePracticeSessionRepository(
          baseSession: _buildSessionData(
            currentIndex: 0,
            firstAnswered: false,
            firstAnswers: const [],
            secondAnswered: false,
          ),
        ),
        assetRepository,
        FakeAppSessionService(),
        FakeCurrentSubjectService(subject: buildSubject()),
      );

      controller.onInit();
      await pumpController();
      await controller.createCurrentQuestionNote('复习时先排除错误选项');

      expect(assetRepository.createNoteCallCount, 1);
      expect(controller.currentQuestion?.noteCount, 1);
      expect(controller.currentQuestion?.noteSummary, '复习时先排除错误选项');
    });
  });
}

class _FakePracticeSessionRepository implements PracticeSessionRepository {
  _FakePracticeSessionRepository({
    this.launchSessionId = 'session-1',
    PracticeSessionData? baseSession,
    this.sessionAfterSubmit,
  }) : _baseSession = baseSession;

  final String launchSessionId;
  final PracticeSessionData? sessionAfterSubmit;
  int startSessionCallCount = 0;
  int submitAnswerCallCount = 0;
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
    if (submitAnswerCallCount > 0 && sessionAfterSubmit != null) {
      return sessionAfterSubmit!;
    }
    return _baseSession ?? _buildSessionData(sessionId: sessionId);
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
        status: 'in_progress',
        questionCount: 2,
        answeredCount: 0,
        correctCount: 0,
        wrongCount: 0,
        startedAt: null,
        finishedAt: null,
        lastAnsweredAt: null,
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
  }) async {
    submitAnswerCallCount += 1;
    return PracticeSubmitResult(
      questionId: questionId,
      isCorrect: true,
      correctAnswers: answers,
      analysis: '',
      answeredCount: 1,
      remainingCount: 1,
    );
  }

  final PracticeSessionData? _baseSession;
}

class _FakePracticeAssetRepository extends PracticeAssetRepository {
  _FakePracticeAssetRepository({
    this.createdNote = const PracticeNoteAssetItem(
      id: 'note-1',
      userId: 'demo-user',
      subjectId: 'subject-1',
      questionId: 'question-1',
      sessionId: 'session-1',
      content: '默认笔记',
      createdAt: null,
      updatedAt: null,
      status: 'pending',
      reviewRemark: '',
      reviewedAt: null,
    ),
  }) : super(_UnsupportedAssetRemoteDataSource());

  final PracticeNoteAssetItem createdNote;
  int toggleCallCount = 0;
  int createNoteCallCount = 0;

  @override
  Future<bool> toggleQuestionFavorite({
    required String userId,
    required String subjectId,
    required String questionId,
    required bool favorite,
  }) async {
    toggleCallCount += 1;
    return favorite;
  }

  @override
  Future<PracticeNoteAssetItem> createPracticeNote({
    required String userId,
    required String subjectId,
    required String questionId,
    String sessionId = '',
    required String content,
  }) async {
    createNoteCallCount += 1;
    return createdNote;
  }
}

class _UnsupportedAssetRemoteDataSource implements AssetRemoteDataSource {
  @override
  Future<Map<String, dynamic>> createPracticeNote({
    required String userId,
    required String subjectId,
    required String questionId,
    required String sessionId,
    required String content,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> deletePracticeNote({
    required String userId,
    required String subjectId,
    required String noteId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> getPracticeNotes({
    required String userId,
    required String subjectId,
    required String questionId,
    required int page,
    required int pageSize,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> getPracticeRecords({
    required String userId,
    required String subjectId,
    required String categoryCode,
    String unitId = '',
    required int page,
    required int pageSize,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> getQuestionFavorites({
    required String userId,
    required String subjectId,
    required int page,
    required int pageSize,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> getReviewRecords({
    required String userId,
    required String subjectId,
    required String categoryCode,
    String unitId = '',
    required int page,
    required int pageSize,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> getWrongQuestions({
    required String userId,
    required String subjectId,
    required String chapterId,
    required String questionCategoryId,
    required int page,
    required int pageSize,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> toggleQuestionFavorite({
    required String userId,
    required String subjectId,
    required String questionId,
    required bool favorite,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> updatePracticeNote({
    required String userId,
    required String subjectId,
    required String noteId,
    required String content,
  }) {
    throw UnimplementedError();
  }
}

PracticeSessionData _buildSessionData({
  String sessionId = 'session-1',
  int currentIndex = 1,
  int remainingCount = 1,
  int answeredCount = 1,
  bool firstAnswered = true,
  List<String> firstAnswers = const ['A'],
  bool secondAnswered = false,
}) {
  return PracticeSessionData(
    session: PracticeSessionSummaryData(
      sessionId: sessionId,
      userId: 'demo-user',
      subjectId: 'subject-1',
      status: 'in_progress',
      questionCount: 2,
      answeredCount: answeredCount,
      correctCount: firstAnswered ? 1 : 0,
      wrongCount: 0,
      startedAt: null,
      finishedAt: null,
      lastAnsweredAt: null,
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
          PracticeQuestionOptionData(
            label: 'B',
            text: '选项 B',
            imageUrl: '',
          ),
        ],
        analysis: '解析 1',
        favorite: false,
        noteCount: 0,
        noteSummary: '',
        noteUpdatedAt: null,
        answered: firstAnswered,
        userAnswers: firstAnswers,
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
        answered: secondAnswered,
        userAnswers: const [],
        chapterId: 'chapter-1',
        chapterName: '第一章',
        questionCategoryId: 'cat-2',
        questionCategoryName: '多选题',
      ),
    ],
    currentIndex: currentIndex,
    remainingCount: remainingCount,
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
