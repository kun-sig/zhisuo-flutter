import '../../services/http_service.dart';

abstract class QaThreadRemoteDataSource {
  /// 创建用户态问答线程，透传题目与会话上下文给后端。
  Future<Map<String, dynamic>> createQaThread({
    required String userId,
    required String subjectId,
    required String questionId,
    required String sessionId,
    required String title,
    required String content,
  });

  /// 按用户和筛选条件获取问答线程列表。
  Future<Map<String, dynamic>> getQaThreads({
    required String userId,
    required String subjectId,
    required String questionId,
    required String status,
    required int page,
    required int pageSize,
  });

  /// 获取单条问答线程详情及完整回复列表。
  Future<Map<String, dynamic>> getQaThreadDetail({
    required String userId,
    required String threadId,
  });

  /// 用户对自己的问答线程追加追问内容。
  Future<Map<String, dynamic>> replyQaThread({
    required String userId,
    required String threadId,
    required String content,
  });
}

class QaThreadRemoteService implements QaThreadRemoteDataSource {
  QaThreadRemoteService(this._httpService);

  static const _createQaThreadPath = '/api/v1/asset/create_qa_thread';
  static const _getQaThreadsPath = '/api/v1/asset/get_qa_threads';
  static const _getQaThreadDetailPath = '/api/v1/asset/get_qa_thread_detail';
  static const _replyQaThreadPath = '/api/v1/asset/reply_qa_thread';

  final HttpService _httpService;

  @override
  Future<Map<String, dynamic>> createQaThread({
    required String userId,
    required String subjectId,
    required String questionId,
    required String sessionId,
    required String title,
    required String content,
  }) {
    // 用户态提问接口与后端 proto 契约对齐，字段保持 lowerCamelCase。
    return _httpService.post<Map<String, dynamic>>(
      _createQaThreadPath,
      data: {
        'userId': userId.trim(),
        'subjectId': subjectId.trim(),
        'questionId': questionId.trim(),
        'sessionId': sessionId.trim(),
        'title': title.trim(),
        'content': content.trim(),
      },
    );
  }

  @override
  Future<Map<String, dynamic>> getQaThreads({
    required String userId,
    required String subjectId,
    required String questionId,
    required String status,
    required int page,
    required int pageSize,
  }) {
    // 列表接口继续沿用现有网关分页字段，方便和其他资产页保持一致。
    return _httpService.post<Map<String, dynamic>>(
      _getQaThreadsPath,
      data: {
        'userId': userId.trim(),
        'subjectId': subjectId.trim(),
        'questionId': questionId.trim(),
        'status': status.trim(),
        'page': page,
        'pageSize': pageSize,
      },
    );
  }

  @override
  Future<Map<String, dynamic>> getQaThreadDetail({
    required String userId,
    required String threadId,
  }) {
    // 详情接口只接受 userId + threadId，两者都由前端显式透传。
    return _httpService.post<Map<String, dynamic>>(
      _getQaThreadDetailPath,
      data: {
        'userId': userId.trim(),
        'threadId': threadId.trim(),
      },
    );
  }

  @override
  Future<Map<String, dynamic>> replyQaThread({
    required String userId,
    required String threadId,
    required String content,
  }) {
    // 用户追问接口不再使用管理端字段，改为用户态真实契约。
    return _httpService.post<Map<String, dynamic>>(
      _replyQaThreadPath,
      data: {
        'userId': userId.trim(),
        'threadId': threadId.trim(),
        'content': content.trim(),
      },
    );
  }
}
