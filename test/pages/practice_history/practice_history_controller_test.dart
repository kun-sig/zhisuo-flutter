import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:zhisuo_flutter/data/models/question_bank/asset_models.dart';
import 'package:zhisuo_flutter/data/repositories/question_bank/practice_asset_repository.dart';
import 'package:zhisuo_flutter/i18n/locale_keys.dart';
import 'package:zhisuo_flutter/pages/practice_history/practice_history_controller.dart';

import '../../helpers/get_test_helper.dart';

void main() {
  group('PracticeHistoryController', () {
    tearDown(disposeGetTest);

    test('refresh without subject returns missing subject error', () async {
      configureGetTest();
      final controller = PracticeHistoryController(
        _FakePracticeHistoryRepository(),
        FakeAppSessionService(),
        FakeCurrentSubjectService(),
      );

      controller.onInit();
      await pumpController();

      expect(
        controller.errorText.value,
        LocaleKeys.practiceHistoryNeedSubject.tr,
      );
      expect(controller.items, isEmpty);
      controller.onClose();
    });

    test('loadMore appends next page records', () async {
      configureGetTest();
      final repository = _FakePracticeHistoryRepository();
      final controller = PracticeHistoryController(
        repository,
        FakeAppSessionService(),
        FakeCurrentSubjectService(subject: buildSubject()),
      );

      controller.onInit();
      await pumpController();
      await controller.loadMore();

      expect(controller.items, hasLength(2));
      expect(controller.items.last.sessionId, 'session-2');
      expect(controller.hasMore.value, isFalse);
      expect(repository.requestedPages, [1, 2]);
      controller.onClose();
    });
  });
}

class _FakePracticeHistoryRepository implements PracticeAssetRepository {
  final List<int> requestedPages = <int>[];

  @override
  Future<AssetPageResult<PracticeRecordAssetItem>> fetchPracticeRecords({
    required String userId,
    required String subjectId,
    String categoryCode = '',
    String unitId = '',
    int page = 1,
    int pageSize = 20,
  }) async {
    requestedPages.add(page);
    if (page == 1) {
      return const AssetPageResult(
        items: [
          PracticeRecordAssetItem(
            id: 'record-1',
            userId: 'demo-user',
            subjectId: 'subject-1',
            sessionId: 'session-1',
            categoryCode: 'chapter',
            unitId: 'chapter-1',
            unitTitle: '第一章',
            questionCount: 10,
            correctCount: 8,
            wrongCount: 2,
            correctRate: 80,
            durationSeconds: 120,
            finishedAt: null,
          ),
        ],
        totalSize: 21,
        page: 1,
        pageSize: 20,
      );
    }
    return const AssetPageResult(
      items: [
        PracticeRecordAssetItem(
          id: 'record-2',
          userId: 'demo-user',
          subjectId: 'subject-1',
          sessionId: 'session-2',
          categoryCode: 'mock_paper',
          unitId: 'mock-1',
          unitTitle: '模拟试卷 1',
          questionCount: 20,
          correctCount: 15,
          wrongCount: 5,
          correctRate: 75,
          durationSeconds: 300,
          finishedAt: null,
        ),
      ],
      totalSize: 21,
      page: 2,
      pageSize: 20,
    );
  }

  @override
  Future<AssetPageResult<PracticeNoteAssetItem>> fetchPracticeNotes({
    required String userId,
    required String subjectId,
    String questionId = '',
    int page = 1,
    int pageSize = 20,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AssetPageResult<QuestionFavoriteAssetItem>> fetchQuestionFavorites({
    required String userId,
    required String subjectId,
    int page = 1,
    int pageSize = 20,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AssetPageResult<PracticeRecordAssetItem>> fetchReviewRecords({
    required String userId,
    required String subjectId,
    String categoryCode = '',
    String unitId = '',
    int page = 1,
    int pageSize = 20,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AssetPageResult<WrongQuestionAssetItem>> fetchWrongQuestions({
    required String userId,
    required String subjectId,
    String chapterId = '',
    String questionCategoryId = '',
    int page = 1,
    int pageSize = 20,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<PracticeNoteAssetItem> createPracticeNote({
    required String userId,
    required String subjectId,
    required String questionId,
    String sessionId = '',
    required String content,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<PracticeNoteAssetItem> updatePracticeNote({
    required String userId,
    required String subjectId,
    required String noteId,
    required String content,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> deletePracticeNote({
    required String userId,
    required String subjectId,
    required String noteId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<bool> toggleQuestionFavorite({
    required String userId,
    required String subjectId,
    required String questionId,
    required bool favorite,
  }) {
    throw UnimplementedError();
  }
}
