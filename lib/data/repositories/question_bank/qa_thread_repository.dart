import '../../../logger/logger.dart';
import '../../../services/api_exception.dart';
import '../../models/question_bank/asset_models.dart';
import '../../models/question_bank/qa_thread_models.dart';
import '../../remote/qa_thread_remote_service.dart';

class QaThreadRepository {
  QaThreadRepository(this._remoteService);

  final QaThreadRemoteDataSource _remoteService;

  /// 创建线程后直接返回最新线程对象，供列表页首屏插入和详情页跳转复用。
  Future<QaThreadData> createQaThread({
    required String userId,
    required String subjectId,
    required String questionId,
    String sessionId = '',
    required String title,
    required String content,
  }) async {
    try {
      final data = await _remoteService.createQaThread(
        userId: userId,
        subjectId: subjectId,
        questionId: questionId,
        sessionId: sessionId,
        title: title,
        content: content,
      );
      return QaThreadData.fromJson(_toMap(data['object']));
    } on ApiException catch (e) {
      Logger.w(
        'QaThreadRepository.createQaThread business failed: '
        'code=${e.code}, message=${e.message}, requestId=${e.requestId}',
      );
      rethrow;
    } catch (e, stackTrace) {
      Logger.e(
        'QaThreadRepository.createQaThread failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// 问答列表统一走分页结果模型，便于与其他资产页复用滚动加载逻辑。
  Future<AssetPageResult<QaThreadData>> fetchQaThreads({
    required String userId,
    required String subjectId,
    String questionId = '',
    String status = '',
    int page = 1,
    int pageSize = 20,
  }) async {
    final resolvedPage = page <= 0 ? 1 : page;
    final resolvedPageSize = pageSize <= 0 ? 20 : pageSize;

    try {
      final data = await _remoteService.getQaThreads(
        userId: userId,
        subjectId: subjectId,
        questionId: questionId,
        status: status,
        page: resolvedPage,
        pageSize: resolvedPageSize,
      );
      return mapAssetPageResult(
        data,
        page: resolvedPage,
        pageSize: resolvedPageSize,
        mapper: QaThreadData.fromJson,
      );
    } on ApiException catch (e) {
      Logger.w(
        'QaThreadRepository.fetchQaThreads business failed: '
        'code=${e.code}, message=${e.message}, requestId=${e.requestId}',
      );
      rethrow;
    } catch (e, stackTrace) {
      Logger.e(
        'QaThreadRepository.fetchQaThreads failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// 详情查询返回完整 replies，避免详情页只依赖列表页透传的旧数据。
  Future<QaThreadData> fetchQaThreadDetail({
    required String userId,
    required String threadId,
  }) async {
    try {
      final data = await _remoteService.getQaThreadDetail(
        userId: userId,
        threadId: threadId,
      );
      return QaThreadData.fromJson(_toMap(data['object']));
    } on ApiException catch (e) {
      Logger.w(
        'QaThreadRepository.fetchQaThreadDetail business failed: '
        'code=${e.code}, message=${e.message}, requestId=${e.requestId}',
      );
      rethrow;
    } catch (e, stackTrace) {
      Logger.e(
        'QaThreadRepository.fetchQaThreadDetail failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// 用户追问成功后返回单条 reply，详情页按增量方式回写 replies。
  Future<QaReplyData> replyQaThread({
    required String userId,
    required String threadId,
    required String content,
  }) async {
    try {
      final data = await _remoteService.replyQaThread(
        userId: userId,
        threadId: threadId,
        content: content,
      );
      return QaReplyData.fromJson(_toMap(data['reply']));
    } on ApiException catch (e) {
      Logger.w(
        'QaThreadRepository.replyQaThread business failed: '
        'code=${e.code}, message=${e.message}, requestId=${e.requestId}',
      );
      rethrow;
    } catch (e, stackTrace) {
      Logger.e(
        'QaThreadRepository.replyQaThread failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}

Map<String, dynamic> _toMap(dynamic raw) {
  if (raw is Map<String, dynamic>) {
    return raw;
  }
  if (raw is Map) {
    return raw.map((key, value) => MapEntry(key.toString(), value));
  }
  return const {};
}
