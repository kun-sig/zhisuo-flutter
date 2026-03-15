import '../../../logger/logger.dart';
import '../../../services/api_exception.dart';
import '../../models/question_bank/asset_models.dart';
import '../../remote/asset_remote_service.dart';

class PracticeAssetRepository {
  PracticeAssetRepository(this._remoteService);

  final AssetRemoteDataSource _remoteService;

  Future<AssetPageResult<WrongQuestionAssetItem>> fetchWrongQuestions({
    required String userId,
    required String subjectId,
    String chapterId = '',
    String questionCategoryId = '',
    int page = 1,
    int pageSize = 20,
  }) async {
    final resolvedPage = page <= 0 ? 1 : page;
    final resolvedPageSize = pageSize <= 0 ? 20 : pageSize;

    try {
      final data = await _remoteService.getWrongQuestions(
        userId: userId,
        subjectId: subjectId,
        chapterId: chapterId,
        questionCategoryId: questionCategoryId,
        page: resolvedPage,
        pageSize: resolvedPageSize,
      );
      return mapAssetPageResult(
        data,
        page: resolvedPage,
        pageSize: resolvedPageSize,
        mapper: WrongQuestionAssetItem.fromJson,
      );
    } on ApiException catch (e) {
      Logger.w(
        'PracticeAssetRepository.fetchWrongQuestions business failed: '
        'code=${e.code}, message=${e.message}, requestId=${e.requestId}',
      );
      rethrow;
    } catch (e, stackTrace) {
      Logger.e(
        'PracticeAssetRepository.fetchWrongQuestions failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<AssetPageResult<PracticeRecordAssetItem>> fetchPracticeRecords({
    required String userId,
    required String subjectId,
    String categoryCode = '',
    String unitId = '',
    int page = 1,
    int pageSize = 20,
  }) async {
    final resolvedPage = page <= 0 ? 1 : page;
    final resolvedPageSize = pageSize <= 0 ? 20 : pageSize;

    try {
      final data = await _remoteService.getPracticeRecords(
        userId: userId,
        subjectId: subjectId,
        categoryCode: categoryCode,
        unitId: unitId,
        page: resolvedPage,
        pageSize: resolvedPageSize,
      );
      return mapAssetPageResult(
        data,
        page: resolvedPage,
        pageSize: resolvedPageSize,
        mapper: PracticeRecordAssetItem.fromJson,
      );
    } on ApiException catch (e) {
      Logger.w(
        'PracticeAssetRepository.fetchPracticeRecords business failed: '
        'code=${e.code}, message=${e.message}, requestId=${e.requestId}',
      );
      rethrow;
    } catch (e, stackTrace) {
      Logger.e(
        'PracticeAssetRepository.fetchPracticeRecords failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// 优先联调真实批改记录接口；若用户态网关尚未开放，再回退到练习记录接口保证页面可用。
  Future<AssetPageResult<PracticeRecordAssetItem>> fetchReviewRecords({
    required String userId,
    required String subjectId,
    String categoryCode = '',
    String unitId = '',
    int page = 1,
    int pageSize = 20,
  }) async {
    final resolvedPage = page <= 0 ? 1 : page;
    final resolvedPageSize = pageSize <= 0 ? 20 : pageSize;

    try {
      final data = await _remoteService.getReviewRecords(
        userId: userId,
        subjectId: subjectId,
        categoryCode: categoryCode,
        unitId: unitId,
        page: resolvedPage,
        pageSize: resolvedPageSize,
      );
      return mapAssetPageResult(
        data,
        page: resolvedPage,
        pageSize: resolvedPageSize,
        mapper: PracticeRecordAssetItem.fromJson,
      );
    } on ApiException catch (e) {
      Logger.w(
        'PracticeAssetRepository.fetchReviewRecords fallback to practice records: '
        'code=${e.code}, message=${e.message}, requestId=${e.requestId}',
      );
      return fetchPracticeRecords(
        userId: userId,
        subjectId: subjectId,
        categoryCode: categoryCode,
        unitId: unitId,
        page: resolvedPage,
        pageSize: resolvedPageSize,
      );
    } catch (e, stackTrace) {
      Logger.e(
        'PracticeAssetRepository.fetchReviewRecords unexpected error before fallback',
        error: e,
        stackTrace: stackTrace,
      );
      return fetchPracticeRecords(
        userId: userId,
        subjectId: subjectId,
        categoryCode: categoryCode,
        unitId: unitId,
        page: resolvedPage,
        pageSize: resolvedPageSize,
      );
    }
  }

  Future<bool> toggleQuestionFavorite({
    required String userId,
    required String subjectId,
    required String questionId,
    required bool favorite,
  }) async {
    try {
      final data = await _remoteService.toggleQuestionFavorite(
        userId: userId,
        subjectId: subjectId,
        questionId: questionId,
        favorite: favorite,
      );
      return data['favorite'] == true;
    } on ApiException catch (e) {
      Logger.w(
        'PracticeAssetRepository.toggleQuestionFavorite business failed: '
        'code=${e.code}, message=${e.message}, requestId=${e.requestId}',
      );
      rethrow;
    } catch (e, stackTrace) {
      Logger.e(
        'PracticeAssetRepository.toggleQuestionFavorite failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<AssetPageResult<QuestionFavoriteAssetItem>> fetchQuestionFavorites({
    required String userId,
    required String subjectId,
    int page = 1,
    int pageSize = 20,
  }) async {
    final resolvedPage = page <= 0 ? 1 : page;
    final resolvedPageSize = pageSize <= 0 ? 20 : pageSize;

    try {
      final data = await _remoteService.getQuestionFavorites(
        userId: userId,
        subjectId: subjectId,
        page: resolvedPage,
        pageSize: resolvedPageSize,
      );
      return mapAssetPageResult(
        data,
        page: resolvedPage,
        pageSize: resolvedPageSize,
        mapper: QuestionFavoriteAssetItem.fromJson,
      );
    } on ApiException catch (e) {
      Logger.w(
        'PracticeAssetRepository.fetchQuestionFavorites business failed: '
        'code=${e.code}, message=${e.message}, requestId=${e.requestId}',
      );
      rethrow;
    } catch (e, stackTrace) {
      Logger.e(
        'PracticeAssetRepository.fetchQuestionFavorites failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<PracticeNoteAssetItem> createPracticeNote({
    required String userId,
    required String subjectId,
    required String questionId,
    String sessionId = '',
    required String content,
  }) async {
    try {
      final data = await _remoteService.createPracticeNote(
        userId: userId,
        subjectId: subjectId,
        questionId: questionId,
        sessionId: sessionId,
        content: content,
      );
      return _mapNoteItem(data['note']);
    } on ApiException catch (e) {
      Logger.w(
        'PracticeAssetRepository.createPracticeNote business failed: '
        'code=${e.code}, message=${e.message}, requestId=${e.requestId}',
      );
      rethrow;
    } catch (e, stackTrace) {
      Logger.e(
        'PracticeAssetRepository.createPracticeNote failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<PracticeNoteAssetItem> updatePracticeNote({
    required String userId,
    required String subjectId,
    required String noteId,
    required String content,
  }) async {
    try {
      final data = await _remoteService.updatePracticeNote(
        userId: userId,
        subjectId: subjectId,
        noteId: noteId,
        content: content,
      );
      return _mapNoteItem(data['note']);
    } on ApiException catch (e) {
      Logger.w(
        'PracticeAssetRepository.updatePracticeNote business failed: '
        'code=${e.code}, message=${e.message}, requestId=${e.requestId}',
      );
      rethrow;
    } catch (e, stackTrace) {
      Logger.e(
        'PracticeAssetRepository.updatePracticeNote failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> deletePracticeNote({
    required String userId,
    required String subjectId,
    required String noteId,
  }) async {
    try {
      await _remoteService.deletePracticeNote(
        userId: userId,
        subjectId: subjectId,
        noteId: noteId,
      );
    } on ApiException catch (e) {
      Logger.w(
        'PracticeAssetRepository.deletePracticeNote business failed: '
        'code=${e.code}, message=${e.message}, requestId=${e.requestId}',
      );
      rethrow;
    } catch (e, stackTrace) {
      Logger.e(
        'PracticeAssetRepository.deletePracticeNote failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<AssetPageResult<PracticeNoteAssetItem>> fetchPracticeNotes({
    required String userId,
    required String subjectId,
    String questionId = '',
    int page = 1,
    int pageSize = 20,
  }) async {
    final resolvedPage = page <= 0 ? 1 : page;
    final resolvedPageSize = pageSize <= 0 ? 20 : pageSize;

    try {
      final data = await _remoteService.getPracticeNotes(
        userId: userId,
        subjectId: subjectId,
        questionId: questionId,
        page: resolvedPage,
        pageSize: resolvedPageSize,
      );
      return mapAssetPageResult(
        data,
        page: resolvedPage,
        pageSize: resolvedPageSize,
        mapper: PracticeNoteAssetItem.fromJson,
      );
    } on ApiException catch (e) {
      Logger.w(
        'PracticeAssetRepository.fetchPracticeNotes business failed: '
        'code=${e.code}, message=${e.message}, requestId=${e.requestId}',
      );
      rethrow;
    } catch (e, stackTrace) {
      Logger.e(
        'PracticeAssetRepository.fetchPracticeNotes failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}

/// 统一解析笔记接口返回，兼容不同接口都把对象包裹在 `note` 字段下的结构。
PracticeNoteAssetItem _mapNoteItem(dynamic raw) {
  if (raw is Map<String, dynamic>) {
    return PracticeNoteAssetItem.fromJson(raw);
  }
  if (raw is Map) {
    return PracticeNoteAssetItem.fromJson(
      raw.map((key, value) => MapEntry(key.toString(), value)),
    );
  }
  return const PracticeNoteAssetItem(
    id: '',
    userId: '',
    subjectId: '',
    questionId: '',
    sessionId: '',
    content: '',
    createdAt: null,
    updatedAt: null,
    status: '',
    reviewRemark: '',
    reviewedAt: null,
  );
}
