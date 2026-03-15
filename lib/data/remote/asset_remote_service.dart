import '../../services/http_service.dart';

abstract class AssetRemoteDataSource {
  Future<Map<String, dynamic>> getWrongQuestions({
    required String userId,
    required String subjectId,
    required String chapterId,
    required String questionCategoryId,
    required int page,
    required int pageSize,
  });

  Future<Map<String, dynamic>> getPracticeRecords({
    required String userId,
    required String subjectId,
    required String categoryCode,
    String unitId = '',
    required int page,
    required int pageSize,
  });

  Future<Map<String, dynamic>> getReviewRecords({
    required String userId,
    required String subjectId,
    required String categoryCode,
    String unitId = '',
    required int page,
    required int pageSize,
  });

  Future<Map<String, dynamic>> toggleQuestionFavorite({
    required String userId,
    required String subjectId,
    required String questionId,
    required bool favorite,
  });

  Future<Map<String, dynamic>> getQuestionFavorites({
    required String userId,
    required String subjectId,
    required int page,
    required int pageSize,
  });

  Future<Map<String, dynamic>> createPracticeNote({
    required String userId,
    required String subjectId,
    required String questionId,
    required String sessionId,
    required String content,
  });

  Future<Map<String, dynamic>> updatePracticeNote({
    required String userId,
    required String subjectId,
    required String noteId,
    required String content,
  });

  Future<Map<String, dynamic>> deletePracticeNote({
    required String userId,
    required String subjectId,
    required String noteId,
  });

  Future<Map<String, dynamic>> getPracticeNotes({
    required String userId,
    required String subjectId,
    required String questionId,
    required int page,
    required int pageSize,
  });
}

class AssetRemoteService implements AssetRemoteDataSource {
  AssetRemoteService(this._httpService);

  static const _getWrongQuestionsPath = '/api/v1/asset/get_wrong_questions';
  static const _getPracticeRecordsPath = '/api/v1/asset/get_practice_records';
  static const _getReviewRecordsPath = '/api/v1/asset/get_review_records';
  static const _toggleQuestionFavoritePath =
      '/api/v1/asset/toggle_question_favorite';
  static const _getQuestionFavoritesPath =
      '/api/v1/asset/get_question_favorites';
  static const _createPracticeNotePath = '/api/v1/asset/create_practice_note';
  static const _updatePracticeNotePath = '/api/v1/asset/update_practice_note';
  static const _deletePracticeNotePath = '/api/v1/asset/delete_practice_note';
  static const _getPracticeNotesPath = '/api/v1/asset/get_practice_notes';

  final HttpService _httpService;

  @override
  Future<Map<String, dynamic>> getWrongQuestions({
    required String userId,
    required String subjectId,
    required String chapterId,
    required String questionCategoryId,
    required int page,
    required int pageSize,
  }) {
    return _httpService.post<Map<String, dynamic>>(
      _getWrongQuestionsPath,
      data: {
        'userId': userId.trim(),
        'subjectId': subjectId.trim(),
        'chapterId': chapterId.trim(),
        'questionCategoryId': questionCategoryId.trim(),
        'page': page,
        'pageSize': pageSize,
      },
    );
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
    return _httpService.post<Map<String, dynamic>>(
      _getPracticeRecordsPath,
      data: {
        'userId': userId.trim(),
        'subjectId': subjectId.trim(),
        'categoryCode': categoryCode.trim(),
        'unitId': unitId.trim(),
        'page': page,
        'pageSize': pageSize,
      },
    );
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
    return _httpService.post<Map<String, dynamic>>(
      _getReviewRecordsPath,
      data: {
        'userId': userId.trim(),
        'subjectId': subjectId.trim(),
        'categoryCode': categoryCode.trim(),
        'unitId': unitId.trim(),
        'page': page,
        'pageSize': pageSize,
      },
    );
  }

  @override
  Future<Map<String, dynamic>> toggleQuestionFavorite({
    required String userId,
    required String subjectId,
    required String questionId,
    required bool favorite,
  }) {
    return _httpService.post<Map<String, dynamic>>(
      _toggleQuestionFavoritePath,
      data: {
        'userId': userId.trim(),
        'subjectId': subjectId.trim(),
        'questionId': questionId.trim(),
        'favorite': favorite,
      },
    );
  }

  @override
  Future<Map<String, dynamic>> getQuestionFavorites({
    required String userId,
    required String subjectId,
    required int page,
    required int pageSize,
  }) {
    return _httpService.post<Map<String, dynamic>>(
      _getQuestionFavoritesPath,
      data: {
        'userId': userId.trim(),
        'subjectId': subjectId.trim(),
        'page': page,
        'pageSize': pageSize,
      },
    );
  }

  @override
  Future<Map<String, dynamic>> createPracticeNote({
    required String userId,
    required String subjectId,
    required String questionId,
    required String sessionId,
    required String content,
  }) {
    return _httpService.post<Map<String, dynamic>>(
      _createPracticeNotePath,
      data: {
        'userId': userId.trim(),
        'subjectId': subjectId.trim(),
        'questionId': questionId.trim(),
        'sessionId': sessionId.trim(),
        'content': content.trim(),
      },
    );
  }

  @override
  Future<Map<String, dynamic>> updatePracticeNote({
    required String userId,
    required String subjectId,
    required String noteId,
    required String content,
  }) {
    return _httpService.post<Map<String, dynamic>>(
      _updatePracticeNotePath,
      data: {
        'userId': userId.trim(),
        'subjectId': subjectId.trim(),
        'noteId': noteId.trim(),
        'content': content.trim(),
      },
    );
  }

  @override
  Future<Map<String, dynamic>> deletePracticeNote({
    required String userId,
    required String subjectId,
    required String noteId,
  }) {
    return _httpService.post<Map<String, dynamic>>(
      _deletePracticeNotePath,
      data: {
        'userId': userId.trim(),
        'subjectId': subjectId.trim(),
        'noteId': noteId.trim(),
      },
    );
  }

  @override
  Future<Map<String, dynamic>> getPracticeNotes({
    required String userId,
    required String subjectId,
    required String questionId,
    required int page,
    required int pageSize,
  }) {
    return _httpService.post<Map<String, dynamic>>(
      _getPracticeNotesPath,
      data: {
        'userId': userId.trim(),
        'subjectId': subjectId.trim(),
        'questionId': questionId.trim(),
        'page': page,
        'pageSize': pageSize,
      },
    );
  }
}
