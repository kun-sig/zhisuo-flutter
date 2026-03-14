import 'package:flutter_test/flutter_test.dart';
import 'package:zhisuo_flutter/data/models/question_bank/question_bank_dashboard_models.dart';
import 'package:zhisuo_flutter/data/repositories/question_bank/question_bank_dashboard_repository.dart';
import 'package:zhisuo_flutter/data/remote/question_bank_remote_service.dart';

import '../../../helpers/get_test_helper.dart';

class _FakeQuestionBankRemoteDataSource
    implements QuestionBankRemoteDataSource {
  @override
  Future<Map<String, dynamic>> fetchDashboard({
    required String userId,
    required String subjectId,
    required String platform,
  }) async {
    return {
      'currentSubject': {
        'subjectId': subjectId,
        'subjectName': '软件设计师',
      },
      'examCountdown': {
        'examDate': 1762560000,
        'countdownDays': 30,
      },
      'continueSession': {
        'sessionId': 'session-1',
        'practiceMode': '章节练习',
        'progressText': '8/20',
        'lastAnsweredAt': 1760000000,
        'categoryCode': 'chapter',
        'unitId': 'chapter-1',
        'unitTitle': '第一章',
      },
      'practiceCategories': [
        {
          'categoryCode': 'knowledge_point',
          'categoryName': '知识点练习',
          'iconKey': 'knowledge',
          'enabled': true,
          'disabledReason': '',
          'sort': 20,
          'unitCount': 12,
          'completedUnitCount': 5,
          'averageCorrectRate': 0.815,
          'previewUnits': [
            {
              'unitId': 'kp-1',
              'categoryCode': 'knowledge_point',
              'refType': 'knowledge_point',
              'refId': 'kp-1',
              'title': '缓存一致性',
              'subtitle': '知识点 1',
              'status': 'enabled',
              'questionCount': 18,
              'completed': false,
              'progressStatus': 'in_progress',
              'doneCount': 8,
              'correctRate': 0.815,
              'lastPracticedAt': 1760000000,
              'sort': 20,
              'extJson': '{}',
            },
          ],
        },
        {
          'categoryCode': 'chapter',
          'categoryName': '章节练习',
          'iconKey': 'chapter',
          'enabled': true,
          'disabledReason': '',
          'sort': 10,
          'unitCount': 8,
          'completedUnitCount': 2,
          'averageCorrectRate': 0.88,
          'previewUnits': [
            {
              'unitId': 'chapter-1',
              'categoryCode': 'chapter',
              'refType': 'chapter',
              'refId': 'chapter-1',
              'title': '第一章',
              'subtitle': '基础入门',
              'status': 'enabled',
              'questionCount': 24,
              'completed': true,
              'progressStatus': 'completed',
              'doneCount': 24,
              'correctRate': 0.88,
              'lastPracticedAt': 1760000500,
              'sort': 10,
              'extJson': '{}',
            },
          ],
        },
      ],
      'practiceUnitsPreview': [
        {
          'unitId': 'chapter-1',
          'categoryCode': 'chapter',
          'refType': 'chapter',
          'refId': 'chapter-1',
          'title': '第一章',
          'subtitle': '基础入门',
          'status': 'enabled',
          'questionCount': 24,
          'completed': true,
          'progressStatus': 'completed',
          'doneCount': 24,
          'correctRate': 0.88,
          'lastPracticedAt': 1760000500,
          'sort': 10,
          'extJson': '{}',
        },
      ],
      'assetTools': [
        {
          'toolCode': 'practice_notes',
          'toolName': '做题笔记',
          'iconKey': 'note',
          'enabled': true,
          'disabledReason': '',
          'sort': 40,
          'count': 6,
          'unreadCount': 1,
          'badgeText': '',
        },
      ],
      'todaySummary': {
        'doneQuestionCount': 32,
        'correctRate': 0.782,
        'recentPracticeCount': 4,
        'pendingReviewWrongCount': 3,
      },
      'updatedAt': 1760001000,
    };
  }

  @override
  Future<Map<String, dynamic>> getPracticeCatalog({
    required String userId,
    required String subjectId,
    required String platform,
  }) async {
    return {
      'categories': [
        {
          'categoryCode': 'knowledge_point',
          'categoryName': '知识点练习',
          'iconKey': 'knowledge',
          'enabled': true,
          'disabledReason': '',
          'sort': 20,
          'unitCount': 12,
          'completedUnitCount': 5,
          'averageCorrectRate': 0.815,
          'previewUnits': const [],
        },
        {
          'categoryCode': 'chapter',
          'categoryName': '章节练习',
          'iconKey': 'chapter',
          'enabled': true,
          'disabledReason': '',
          'sort': 10,
          'unitCount': 8,
          'completedUnitCount': 2,
          'averageCorrectRate': 0.88,
          'previewUnits': const [],
        },
      ],
      'updatedAt': 1760002000,
    };
  }

  @override
  Future<Map<String, dynamic>> getPracticeUnitList({
    required String userId,
    required String subjectId,
    required String categoryCode,
    required String keyword,
    required String status,
    required int page,
    required int pageSize,
  }) async {
    return {
      'totalSize': 3,
      'objects': [
        {
          'unitId': 'chapter-2',
          'categoryCode': categoryCode,
          'refType': 'chapter',
          'refId': 'chapter-2',
          'title': '第二章',
          'subtitle': '进阶',
          'status': 'enabled',
          'questionCount': 18,
          'completed': false,
          'progressStatus': 'in_progress',
          'doneCount': 6,
          'correctRate': 0.72,
          'lastPracticedAt': 1760000600,
          'sort': 20,
          'extJson': '{}',
        },
        {
          'unitId': 'chapter-1',
          'categoryCode': categoryCode,
          'refType': 'chapter',
          'refId': 'chapter-1',
          'title': '第一章',
          'subtitle': '基础入门',
          'status': 'enabled',
          'questionCount': 24,
          'completed': true,
          'progressStatus': 'completed',
          'doneCount': 24,
          'correctRate': 0.88,
          'lastPracticedAt': 1760000500,
          'sort': 10,
          'extJson': '{}',
        },
      ],
    };
  }
}

void main() {
  group('QuestionBankDashboardRepository', () {
    tearDown(disposeGetTest);

    test('fetchDashboard maps and sorts remote response', () async {
      final repository = QuestionBankDashboardRepository(
        _FakeQuestionBankRemoteDataSource(),
      );

      final result = await repository.fetchDashboard(
        userId: 'demo-user',
        subjectId: 'subject-1',
        platform: 'phone',
      );

      expect(result.currentSubject?.subjectName, '软件设计师');
      expect(result.practiceCategories.first.categoryCode, 'chapter');
      expect(result.practiceCategories.first.unitCount, 8);
      expect(result.practiceCategories.first.previewUnits.single.unitId,
          'chapter-1');
      expect(result.practiceUnitsPreview.single.categoryCode, 'chapter');
      expect(result.practiceUnitsPreview.single.completed, isTrue);
      expect(result.practiceCategories.first.averageCorrectRate, 88.0);
      expect(result.practiceUnitsPreview.single.correctRate, 88.0);
      expect(result.continueSession?.progressText, '8/20');
      expect(result.continueSession?.unitTitle, '第一章');
      expect(result.continueSession?.displayTitle, '第一章');
      expect(result.todaySummary?.doneQuestionCount, 32);
      expect(result.todaySummary?.correctRate, 78.2);
      expect(result.assetTools.single.toolCode, 'practice_notes');
    });

    test('fetchPracticeCatalog maps and sorts category response', () async {
      final repository = QuestionBankDashboardRepository(
        _FakeQuestionBankRemoteDataSource(),
      );

      final result = await repository.fetchPracticeCatalog(
        userId: 'demo-user',
        subjectId: 'subject-1',
        platform: 'phone',
      );

      expect(result.categories.first.categoryCode, 'chapter');
      expect(result.categories.first.completedUnitCount, 2);
      expect(result.categories.first.averageCorrectRate, 88.0);
      expect(result.categories.last.categoryCode, 'knowledge_point');
    });

    test('fetchPracticeUnitList maps paging data and sorts units', () async {
      final repository = QuestionBankDashboardRepository(
        _FakeQuestionBankRemoteDataSource(),
      );

      final result = await repository.fetchPracticeUnitList(
        userId: 'demo-user',
        subjectId: 'subject-1',
        categoryCode: 'chapter',
        page: 1,
        pageSize: 20,
      );

      expect(result.totalSize, 3);
      expect(result.hasMore, isFalse);
      expect(result.items.first.unitId, 'chapter-1');
      expect(result.items.first.correctRate, 88.0);
      expect(result.items.last.progressStatus, 'in_progress');
      expect(result.items.last.correctRate, 72.0);
    });

    test('continue session displayTitle falls back to localized mode name', () {
      configureGetTest();
      final session = ContinueSessionViewData.fromJson(const {
        'sessionId': 'session-1',
        'practiceMode': 'chapter_practice',
        'progressText': '1/3',
        'categoryCode': 'chapter',
        'unitId': 'chapter-1',
        'unitTitle': '',
      });

      expect(session.displayTitle, '章节练习');
    });
  });
}
