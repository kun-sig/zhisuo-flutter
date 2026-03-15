import 'package:flutter_test/flutter_test.dart';
import 'package:zhisuo_flutter/data/models/question_bank/asset_models.dart';
import 'package:zhisuo_flutter/data/repositories/question_bank/practice_asset_repository.dart';
import 'package:zhisuo_flutter/pages/practice_notes/practice_notes_controller.dart';

import '../../helpers/get_test_helper.dart';

void main() {
  group('PracticeNotesController', () {
    tearDown(disposeGetTest);

    test('updateNote replaces item in place', () async {
      configureGetTest();
      final repository = _FakePracticeNotesRepository();
      final controller = PracticeNotesController(
        repository,
        FakeAppSessionService(),
        FakeCurrentSubjectService(subject: buildSubject()),
      );

      controller.onInit();
      await pumpController();

      expect(controller.items.single.content, '原始笔记');
      await controller.updateNote(controller.items.single, '更新后的笔记');

      expect(controller.items.single.content, '更新后的笔记');
      expect(repository.updatedNoteId, 'note-1');
      controller.onClose();
    });

    test('deleteNote removes item and updates total size', () async {
      configureGetTest();
      final repository = _FakePracticeNotesRepository();
      final controller = PracticeNotesController(
        repository,
        FakeAppSessionService(),
        FakeCurrentSubjectService(subject: buildSubject()),
      );

      controller.onInit();
      await pumpController();

      expect(controller.items, hasLength(1));
      expect(controller.totalSize.value, 1);

      await controller.deleteNote(controller.items.single);

      expect(controller.items, isEmpty);
      expect(controller.totalSize.value, 0);
      expect(repository.deletedNoteId, 'note-1');
      controller.onClose();
    });
  });
}

class _FakePracticeNotesRepository implements PracticeAssetRepository {
  String updatedNoteId = '';
  String deletedNoteId = '';

  @override
  Future<AssetPageResult<PracticeNoteAssetItem>> fetchPracticeNotes({
    required String userId,
    required String subjectId,
    String questionId = '',
    int page = 1,
    int pageSize = 20,
  }) async {
    return const AssetPageResult(
      items: [
        PracticeNoteAssetItem(
          id: 'note-1',
          userId: 'demo-user',
          subjectId: 'subject-1',
          questionId: 'question-1',
          sessionId: 'session-1',
          content: '原始笔记',
          createdAt: null,
          updatedAt: null,
          status: 'pending',
          reviewRemark: '',
          reviewedAt: null,
        ),
      ],
      totalSize: 1,
      page: 1,
      pageSize: 20,
    );
  }

  @override
  Future<PracticeNoteAssetItem> updatePracticeNote({
    required String userId,
    required String subjectId,
    required String noteId,
    required String content,
  }) async {
    updatedNoteId = noteId;
    return PracticeNoteAssetItem(
      id: noteId,
      userId: userId,
      subjectId: subjectId,
      questionId: 'question-1',
      sessionId: 'session-1',
      content: content,
      createdAt: null,
      updatedAt: DateTime(2026, 3, 15),
      status: 'approved',
      reviewRemark: '',
      reviewedAt: null,
    );
  }

  @override
  Future<void> deletePracticeNote({
    required String userId,
    required String subjectId,
    required String noteId,
  }) async {
    deletedNoteId = noteId;
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
  Future<bool> toggleQuestionFavorite({
    required String userId,
    required String subjectId,
    required String questionId,
    required bool favorite,
  }) {
    throw UnimplementedError();
  }
}
