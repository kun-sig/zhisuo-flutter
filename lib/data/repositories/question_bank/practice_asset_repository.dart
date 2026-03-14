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
    String practiceMode = '',
    int page = 1,
    int pageSize = 20,
  }) async {
    final resolvedPage = page <= 0 ? 1 : page;
    final resolvedPageSize = pageSize <= 0 ? 20 : pageSize;

    try {
      final data = await _remoteService.getPracticeRecords(
        userId: userId,
        subjectId: subjectId,
        practiceMode: practiceMode,
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
      final noteData = data['note'];
      if (noteData is Map<String, dynamic>) {
        return PracticeNoteAssetItem.fromJson(noteData);
      }
      if (noteData is Map) {
        return PracticeNoteAssetItem.fromJson(
          noteData.map((key, value) => MapEntry(key.toString(), value)),
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
