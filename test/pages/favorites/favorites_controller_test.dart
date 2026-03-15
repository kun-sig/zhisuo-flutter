import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:zhisuo_flutter/data/models/question_bank/asset_models.dart';
import 'package:zhisuo_flutter/data/repositories/question_bank/practice_asset_repository.dart';
import 'package:zhisuo_flutter/i18n/locale_keys.dart';
import 'package:zhisuo_flutter/pages/favorites/favorites_controller.dart';

import '../../helpers/get_test_helper.dart';

void main() {
  group('FavoritesController', () {
    tearDown(disposeGetTest);

    test('refresh without subject returns missing subject error', () async {
      configureGetTest();
      final controller = FavoritesController(
        _FakeFavoritesRepository(),
        FakeAppSessionService(),
        FakeCurrentSubjectService(),
      );

      controller.onInit();
      await pumpController();

      expect(controller.errorText.value, LocaleKeys.favoritesNeedSubject.tr);
      expect(controller.items, isEmpty);
      controller.onClose();
    });

    test('loadMore appends next page items', () async {
      configureGetTest();
      final repository = _FakeFavoritesRepository();
      final controller = FavoritesController(
        repository,
        FakeAppSessionService(),
        FakeCurrentSubjectService(subject: buildSubject()),
      );

      controller.onInit();
      await pumpController();
      await controller.loadMore();

      expect(controller.items, hasLength(2));
      expect(controller.items.last.questionId, 'question-2');
      expect(controller.hasMore.value, isFalse);
      expect(repository.requestedPages, [1, 2]);
      controller.onClose();
    });
  });
}

class _FakeFavoritesRepository implements PracticeAssetRepository {
  final List<int> requestedPages = <int>[];

  @override
  Future<AssetPageResult<QuestionFavoriteAssetItem>> fetchQuestionFavorites({
    required String userId,
    required String subjectId,
    int page = 1,
    int pageSize = 20,
  }) async {
    requestedPages.add(page);
    if (page == 1) {
      return const AssetPageResult(
        items: [
          QuestionFavoriteAssetItem(
            id: 'favorite-1',
            userId: 'demo-user',
            subjectId: 'subject-1',
            questionId: 'question-1',
            createdAt: null,
          ),
        ],
        totalSize: 21,
        page: 1,
        pageSize: 20,
      );
    }
    return const AssetPageResult(
      items: [
        QuestionFavoriteAssetItem(
          id: 'favorite-2',
          userId: 'demo-user',
          subjectId: 'subject-1',
          questionId: 'question-2',
          createdAt: null,
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
