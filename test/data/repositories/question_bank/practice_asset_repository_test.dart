import 'package:flutter_test/flutter_test.dart';
import 'package:zhisuo_flutter/data/remote/asset_remote_service.dart';
import 'package:zhisuo_flutter/data/repositories/question_bank/practice_asset_repository.dart';
import 'package:zhisuo_flutter/services/api_exception.dart';

class _FakeAssetRemoteDataSource implements AssetRemoteDataSource {
  bool reviewRecordsShouldFail = false;

  @override
  Future<Map<String, dynamic>> getPracticeRecords({
    required String userId,
    required String subjectId,
    required String categoryCode,
    String unitId = '',
    required int page,
    required int pageSize,
  }) async {
    return {
      'totalSize': 3,
      'objects': [
        {
          'id': 'record-1',
          'userId': userId,
          'subjectId': subjectId,
          'sessionId': 'session-1',
          'categoryCode': categoryCode.isEmpty ? 'chapter' : categoryCode,
          'unitId': unitId.isEmpty ? 'chapter-1' : unitId,
          'unitTitle': '第一章',
          'questionCount': 20,
          'correctCount': 16,
          'wrongCount': 4,
          'correctRate': 0.8,
          'durationSeconds': 480,
          'finishedAt': 1760000100,
        },
      ],
    };
  }

  @override
  Future<Map<String, dynamic>> getReviewRecords({
    required String userId,
    required String subjectId,
    required String categoryCode,
    String unitId = '',
    required int page,
    required int pageSize,
  }) async {
    if (reviewRecordsShouldFail) {
      throw const ApiException(
        code: 404,
        message: 'not found',
        httpStatus: 404,
      );
    }
    return {
      'totalSize': 1,
      'objects': [
        {
          'id': 'review-1',
          'userId': userId,
          'subjectId': subjectId,
          'sessionId': 'review-session-1',
          'categoryCode': categoryCode.isEmpty ? 'chapter' : categoryCode,
          'unitId': unitId.isEmpty ? 'mock-paper-1' : unitId,
          'unitTitle': '模拟试卷 1',
          'questionCount': 12,
          'correctCount': 9,
          'wrongCount': 3,
          'correctRate': 0.75,
          'durationSeconds': 360,
          'finishedAt': 1760000700,
        },
      ],
    };
  }

  @override
  Future<Map<String, dynamic>> getQuestionFavorites({
    required String userId,
    required String subjectId,
    required int page,
    required int pageSize,
  }) async {
    return {
      'totalSize': 2,
      'objects': [
        {
          'id': 'favorite-1',
          'userId': userId,
          'subjectId': subjectId,
          'questionId': 'question-favorite-1',
          'createdAt': 1760000200,
        },
      ],
    };
  }

  @override
  Future<Map<String, dynamic>> getPracticeNotes({
    required String userId,
    required String subjectId,
    required String questionId,
    required int page,
    required int pageSize,
  }) async {
    return {
      'totalSize': 1,
      'objects': [
        {
          'id': 'note-1',
          'userId': userId,
          'subjectId': subjectId,
          'questionId': questionId.isEmpty ? 'question-note-1' : questionId,
          'sessionId': 'session-1',
          'content': 'note content',
          'createdAt': 1760000300,
          'updatedAt': 1760000400,
          'status': 'pending',
          'reviewRemark': '',
          'reviewedAt': 0,
        },
      ],
    };
  }

  @override
  Future<Map<String, dynamic>> getWrongQuestions({
    required String userId,
    required String subjectId,
    required String chapterId,
    required String questionCategoryId,
    required int page,
    required int pageSize,
  }) async {
    return {
      'totalSize': 21,
      'objects': [
        {
          'id': 'wrong-1',
          'userId': userId,
          'subjectId': subjectId,
          'questionId': 'question-1',
          'wrongCount': 2,
          'lastWrongAt': 1760000000,
          'status': 'active',
        },
      ],
    };
  }

  @override
  Future<Map<String, dynamic>> toggleQuestionFavorite({
    required String userId,
    required String subjectId,
    required String questionId,
    required bool favorite,
  }) async {
    return {
      'favorite': favorite,
    };
  }

  @override
  Future<Map<String, dynamic>> createPracticeNote({
    required String userId,
    required String subjectId,
    required String questionId,
    required String sessionId,
    required String content,
  }) async {
    return {
      'note': {
        'id': 'note-created-1',
        'userId': userId,
        'subjectId': subjectId,
        'questionId': questionId,
        'sessionId': sessionId,
        'content': content,
        'createdAt': 1760000500,
        'updatedAt': 1760000500,
        'status': 'pending',
        'reviewRemark': '',
        'reviewedAt': 0,
      },
    };
  }

  @override
  Future<Map<String, dynamic>> updatePracticeNote({
    required String userId,
    required String subjectId,
    required String noteId,
    required String content,
  }) async {
    return {
      'note': {
        'id': noteId,
        'userId': userId,
        'subjectId': subjectId,
        'questionId': 'question-note-2',
        'sessionId': 'session-2',
        'content': content,
        'createdAt': 1760000500,
        'updatedAt': 1760000600,
        'status': 'approved',
        'reviewRemark': '已更新',
        'reviewedAt': 1760000600,
      },
    };
  }

  @override
  Future<Map<String, dynamic>> deletePracticeNote({
    required String userId,
    required String subjectId,
    required String noteId,
  }) async {
    return {
      'deleted': true,
      'noteId': noteId,
    };
  }
}

void main() {
  group('PracticeAssetRepository', () {
    test('maps wrong questions, records, favorites, and notes responses',
        () async {
      final remote = _FakeAssetRemoteDataSource();
      final repository = PracticeAssetRepository(remote);

      final wrongQuestions = await repository.fetchWrongQuestions(
        userId: 'demo-user',
        subjectId: 'subject-1',
        page: 1,
        pageSize: 20,
      );
      final practiceRecords = await repository.fetchPracticeRecords(
        userId: 'demo-user',
        subjectId: 'subject-1',
        page: 1,
        pageSize: 20,
      );
      final reviewRecords = await repository.fetchReviewRecords(
        userId: 'demo-user',
        subjectId: 'subject-1',
        categoryCode: 'mock_paper',
        page: 1,
        pageSize: 20,
      );
      final favorites = await repository.fetchQuestionFavorites(
        userId: 'demo-user',
        subjectId: 'subject-1',
        page: 1,
        pageSize: 20,
      );
      final favoriteState = await repository.toggleQuestionFavorite(
        userId: 'demo-user',
        subjectId: 'subject-1',
        questionId: 'question-favorite-1',
        favorite: false,
      );
      final notes = await repository.fetchPracticeNotes(
        userId: 'demo-user',
        subjectId: 'subject-1',
        page: 1,
        pageSize: 20,
      );
      final createdNote = await repository.createPracticeNote(
        userId: 'demo-user',
        subjectId: 'subject-1',
        questionId: 'question-note-2',
        sessionId: 'session-2',
        content: 'new note',
      );
      final updatedNote = await repository.updatePracticeNote(
        userId: 'demo-user',
        subjectId: 'subject-1',
        noteId: 'note-created-1',
        content: 'updated note',
      );
      await repository.deletePracticeNote(
        userId: 'demo-user',
        subjectId: 'subject-1',
        noteId: 'note-created-1',
      );

      expect(wrongQuestions.totalSize, 21);
      expect(wrongQuestions.hasMore, isTrue);
      expect(wrongQuestions.items.single.questionId, 'question-1');
      expect(wrongQuestions.items.single.wrongCount, 2);

      expect(practiceRecords.totalSize, 3);
      expect(practiceRecords.hasMore, isFalse);
      expect(practiceRecords.items.single.sessionId, 'session-1');
      expect(practiceRecords.items.single.categoryCode, 'chapter');
      expect(practiceRecords.items.single.unitId, 'chapter-1');
      expect(practiceRecords.items.single.correctRate, 80.0);
      expect(practiceRecords.items.single.durationSeconds, 480);
      expect(reviewRecords.totalSize, 1);
      expect(reviewRecords.items.single.sessionId, 'review-session-1');
      expect(reviewRecords.items.single.categoryCode, 'mock_paper');
      expect(reviewRecords.items.single.unitTitle, '模拟试卷 1');

      expect(favorites.totalSize, 2);
      expect(favorites.items.single.questionId, 'question-favorite-1');
      expect(favoriteState, isFalse);

      expect(notes.totalSize, 1);
      expect(notes.items.single.status, 'pending');
      expect(createdNote.questionId, 'question-note-2');
      expect(createdNote.content, 'new note');
      expect(updatedNote.id, 'note-created-1');
      expect(updatedNote.content, 'updated note');
      expect(updatedNote.status, 'approved');
    });

    test(
        'fetchReviewRecords falls back to practice records when route unavailable',
        () async {
      final remote = _FakeAssetRemoteDataSource()
        ..reviewRecordsShouldFail = true;
      final repository = PracticeAssetRepository(remote);

      final reviewRecords = await repository.fetchReviewRecords(
        userId: 'demo-user',
        subjectId: 'subject-1',
        categoryCode: 'mock_paper',
        page: 1,
        pageSize: 20,
      );

      expect(reviewRecords.totalSize, 3);
      expect(reviewRecords.items.single.sessionId, 'session-1');
      expect(reviewRecords.items.single.categoryCode, 'mock_paper');
    });
  });
}
