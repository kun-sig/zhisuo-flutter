import 'package:flutter_test/flutter_test.dart';
import 'package:zhisuo_flutter/data/remote/practice_remote_service.dart';
import 'package:zhisuo_flutter/data/repositories/question_bank/practice_session_repository.dart';

class _FakePracticeRemoteDataSource implements PracticeRemoteDataSource {
  @override
  Future<Map<String, dynamic>> startPracticeSession({
    required String userId,
    required String subjectId,
    required String categoryCode,
    required String unitId,
    required int questionCount,
    required bool continueIfExists,
  }) async {
    return {
      'session': {
        'sessionId': 'session-1',
        'userId': userId,
        'subjectId': subjectId,
        'practiceMode': categoryCode,
        'status': 'in_progress',
        'questionCount': questionCount,
        'answeredCount': 0,
        'correctCount': 0,
        'wrongCount': 0,
        'sourceType': 'practice_unit',
        'sourceId': unitId,
        'sourceTitle': '章节练习',
        'categoryCode': categoryCode,
        'unitId': unitId,
        'unitTitle': unitId.isEmpty ? '' : '第一章',
      },
      'currentQuestion': {
        'questionId': 'question-1',
        'questionType': 'single',
        'stem': '示例题干',
        'options': [
          {'label': 'A', 'text': '选项 A', 'imageUrl': ''},
          {'label': 'B', 'text': '选项 B', 'imageUrl': ''},
        ],
        'analysis': '解析',
        'favorite': false,
        'answered': false,
        'userAnswers': const <String>[],
        'noteCount': 0,
        'noteSummary': '',
        'noteUpdatedAt': 0,
        'chapterId': 'chapter-1',
        'chapterName': '第一章',
        'questionCategoryId': 'cat-1',
        'questionCategoryName': '单选题',
      },
      'currentIndex': 0,
      'remainingCount': questionCount,
      'unitProgress': {
        'unitId': unitId,
        'categoryCode': categoryCode,
        'completed': false,
        'progressStatus': 'in_progress',
        'sessionCount': 2,
        'answeredCount': 6,
        'correctCount': 5,
        'wrongCount': 1,
        'correctRate': 0.833,
        'doneCount': 6,
        'lastSessionId': 'session-1',
        'lastPracticedAt': 1760000100,
      },
    };
  }

  @override
  Future<Map<String, dynamic>> getPracticeSession({
    required String sessionId,
  }) async {
    return {
      'session': {
        'sessionId': sessionId,
        'userId': 'demo-user',
        'subjectId': 'subject-1',
        'practiceMode': 'chapter_practice',
        'status': 'in_progress',
        'questionCount': 2,
        'answeredCount': 1,
        'correctCount': 1,
        'wrongCount': 0,
        'sourceType': 'subject',
        'sourceId': '',
        'sourceTitle': '章节练习',
        'categoryCode': 'chapter',
        'unitId': 'chapter-1',
        'unitTitle': '第一章',
      },
      'questions': [
        {
          'questionId': 'question-1',
          'questionType': 'single',
          'stem': '示例题干 1',
          'options': [
            {'label': 'A', 'text': '选项 A', 'imageUrl': ''},
          ],
          'analysis': '解析 1',
          'favorite': true,
          'answered': true,
          'userAnswers': ['A'],
          'noteCount': 1,
          'noteSummary': '记笔记',
          'noteUpdatedAt': 1760000000,
          'chapterId': 'chapter-1',
          'chapterName': '第一章',
          'questionCategoryId': 'cat-1',
          'questionCategoryName': '单选题',
        },
        {
          'questionId': 'question-2',
          'questionType': 'multiple',
          'stem': '示例题干 2',
          'options': [
            {'label': 'A', 'text': '选项 A', 'imageUrl': ''},
            {'label': 'B', 'text': '选项 B', 'imageUrl': ''},
          ],
          'analysis': '解析 2',
          'favorite': false,
          'answered': false,
          'userAnswers': const <String>[],
          'noteCount': 0,
          'noteSummary': '',
          'noteUpdatedAt': 0,
          'chapterId': 'chapter-1',
          'chapterName': '第一章',
          'questionCategoryId': 'cat-2',
          'questionCategoryName': '多选题',
        },
      ],
      'currentIndex': 1,
      'remainingCount': 1,
      'unitProgress': {
        'unitId': 'chapter-1',
        'categoryCode': 'chapter',
        'completed': false,
        'progressStatus': 'in_progress',
        'sessionCount': 3,
        'answeredCount': 12,
        'correctCount': 9,
        'wrongCount': 3,
        'correctRate': 0.75,
        'doneCount': 12,
        'lastSessionId': sessionId,
        'lastPracticedAt': 1760000200,
      },
    };
  }

  @override
  Future<Map<String, dynamic>> submitPracticeAnswer({
    required String sessionId,
    required String questionId,
    required List<String> answers,
    required int costSeconds,
  }) async {
    return {
      'questionId': questionId,
      'isCorrect': true,
      'correctAnswers': ['A'],
      'analysis': '提交解析',
      'answeredCount': 2,
      'remainingCount': 0,
    };
  }

  @override
  Future<Map<String, dynamic>> finishPracticeSession({
    required String sessionId,
  }) async {
    return {
      'sessionId': sessionId,
      'status': 'finished',
      'reportId': 'report-1',
    };
  }

  @override
  Future<Map<String, dynamic>> getPracticeReport({
    required String sessionId,
  }) async {
    return {
      'report': {
        'reportId': 'report-1',
        'sessionId': sessionId,
        'categoryCode': 'chapter',
        'unitId': 'chapter-1',
        'unitTitle': '第一章',
        'totalCount': 2,
        'correctCount': 1,
        'wrongCount': 1,
        'correctRate': 0.5,
        'durationSeconds': 120,
        'chapterStats': [
          {
            'chapterId': 'chapter-1',
            'chapterName': '第一章',
            'totalCount': 2,
            'correctCount': 1,
            'correctRate': 0.5,
          },
        ],
        'questionCategoryStats': [
          {
            'questionCategoryId': 'cat-1',
            'questionCategoryName': '单选题',
            'totalCount': 2,
            'correctCount': 1,
            'correctRate': 0.5,
          },
        ],
        'wrongQuestionIds': ['question-2'],
      },
    };
  }
}

void main() {
  group('PracticeSessionRepository', () {
    test('maps practice session and report responses', () async {
      final repository = PracticeSessionRepository(
        _FakePracticeRemoteDataSource(),
      );

      final launch = await repository.startSession(
        userId: 'demo-user',
        subjectId: 'subject-1',
        categoryCode: 'chapter',
        unitId: 'chapter-1',
      );
      final detail = await repository.fetchSession(sessionId: 'session-1');
      final submit = await repository.submitAnswer(
        sessionId: 'session-1',
        questionId: 'question-2',
        answers: const ['A'],
      );
      final finish = await repository.finishSession(sessionId: 'session-1');
      final report = await repository.fetchReport(sessionId: 'session-1');

      expect(launch.session.sessionId, 'session-1');
      expect(launch.session.categoryCode, 'chapter');
      expect(launch.session.unitId, 'chapter-1');
      expect(launch.session.unitTitle, '第一章');
      expect(launch.unitProgress?.doneCount, 6);
      expect(launch.unitProgress?.correctRate, 83.3);
      expect(launch.currentQuestion?.questionId, 'question-1');
      expect(detail.session.practiceMode, 'chapter_practice');
      expect(detail.session.unitId, 'chapter-1');
      expect(detail.unitProgress?.sessionCount, 3);
      expect(detail.unitProgress?.answeredCount, 12);
      expect(detail.currentQuestion?.questionId, 'question-2');
      expect(detail.questions.first.favorite, isTrue);
      expect(detail.remainingCount, 1);
      expect(submit.isCorrect, isTrue);
      expect(submit.correctAnswers, ['A']);
      expect(finish.reportId, 'report-1');
      expect(report.correctRate, 50.0);
      expect(report.categoryCode, 'chapter');
      expect(report.unitId, 'chapter-1');
      expect(report.unitTitle, '第一章');
      expect(report.chapterStats.single.name, '第一章');
      expect(report.chapterStats.single.correctRate, 50.0);
      expect(report.questionCategoryStats.single.correctRate, 50.0);
      expect(report.wrongQuestionIds, ['question-2']);
    });
  });
}
