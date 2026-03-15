import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:zhisuo_flutter/data/models/question_bank/asset_models.dart';
import 'package:zhisuo_flutter/data/repositories/question_bank/practice_asset_repository.dart';
import 'package:zhisuo_flutter/i18n/locale_keys.dart';
import 'package:zhisuo_flutter/pages/review_records/review_records_controller.dart';

import '../../helpers/get_test_helper.dart';

void main() {
  group('ReviewRecordsController', () {
    tearDown(disposeGetTest);

    test('refresh without subject returns missing subject error', () async {
      configureGetTest();
      final controller = ReviewRecordsController(
        _FakeReviewRecordsRepository(),
        FakeAppSessionService(),
        FakeCurrentSubjectService(),
      );

      controller.onInit();
      await pumpController();

      expect(
          controller.errorText.value, LocaleKeys.reviewRecordsNeedSubject.tr);
      expect(controller.items, isEmpty);
      controller.onClose();
    });

    test('changeCategoryCode forwards filter to repository', () async {
      configureGetTest();
      final repository = _FakeReviewRecordsRepository();
      final controller = ReviewRecordsController(
        repository,
        FakeAppSessionService(),
        FakeCurrentSubjectService(subject: buildSubject()),
      );

      controller.onInit();
      await pumpController();

      await controller.changeCategoryCode('mock_paper');
      await pumpController();

      expect(controller.categoryCode.value, 'mock_paper');
      expect(repository.lastCategoryCode, 'mock_paper');
      expect(controller.items.single.categoryCode, 'mock_paper');
      controller.onClose();
    });
  });
}

class _FakeReviewRecordsRepository implements PracticeAssetRepository {
  String lastCategoryCode = '';

  @override
  Future<AssetPageResult<PracticeRecordAssetItem>> fetchReviewRecords({
    required String userId,
    required String subjectId,
    String categoryCode = '',
    String unitId = '',
    int page = 1,
    int pageSize = 20,
  }) async {
    lastCategoryCode = categoryCode;
    return AssetPageResult(
      items: [
        PracticeRecordAssetItem(
          id: 'review-1',
          userId: userId,
          subjectId: subjectId,
          sessionId: 'session-1',
          categoryCode: categoryCode.isEmpty ? 'chapter' : categoryCode,
          unitId: 'chapter-1',
          unitTitle: '第一章',
          questionCount: 20,
          correctCount: 15,
          wrongCount: 5,
          correctRate: 75,
          durationSeconds: 600,
          finishedAt: DateTime(2026, 3, 15, 10),
        ),
      ],
      totalSize: 1,
      page: page,
      pageSize: pageSize,
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
  Future<AssetPageResult<PracticeRecordAssetItem>> fetchPracticeRecords({
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
