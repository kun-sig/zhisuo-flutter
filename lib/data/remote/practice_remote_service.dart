import '../../services/http_service.dart';

abstract class PracticeRemoteDataSource {
  /// 启动练习会话，只接受新的 `categoryCode + unitId` 入参。
  Future<Map<String, dynamic>> startPracticeSession({
    required String userId,
    required String subjectId,
    required String categoryCode,
    required String unitId,
    required int questionCount,
    required bool continueIfExists,
  });

  Future<Map<String, dynamic>> getPracticeSession({
    required String sessionId,
  });

  Future<Map<String, dynamic>> submitPracticeAnswer({
    required String sessionId,
    required String questionId,
    required List<String> answers,
    required int costSeconds,
  });

  Future<Map<String, dynamic>> finishPracticeSession({
    required String sessionId,
  });

  Future<Map<String, dynamic>> getPracticeReport({
    required String sessionId,
  });
}

class PracticeRemoteService implements PracticeRemoteDataSource {
  PracticeRemoteService(this._httpService);

  static const _startPracticeSessionPath =
      '/api/v1/practice/start_practice_session';
  static const _getPracticeSessionPath =
      '/api/v1/practice/get_practice_session';
  static const _submitPracticeAnswerPath =
      '/api/v1/practice/submit_practice_answer';
  static const _finishPracticeSessionPath =
      '/api/v1/practice/finish_practice_session';
  static const _getPracticeReportPath = '/api/v1/practice/get_practice_report';

  final HttpService _httpService;

  @override

  /// 统一透传开始练习请求，直接切到新的单元参数协议。
  Future<Map<String, dynamic>> startPracticeSession({
    required String userId,
    required String subjectId,
    required String categoryCode,
    required String unitId,
    required int questionCount,
    required bool continueIfExists,
  }) {
    return _httpService.post<Map<String, dynamic>>(
      _startPracticeSessionPath,
      data: {
        'userId': userId.trim(),
        'subjectId': subjectId.trim(),
        'categoryCode': categoryCode.trim(),
        'unitId': unitId.trim(),
        'questionCount': questionCount,
        'continueIfExists': continueIfExists,
      },
    );
  }

  @override
  Future<Map<String, dynamic>> getPracticeSession({
    required String sessionId,
  }) {
    return _httpService.post<Map<String, dynamic>>(
      _getPracticeSessionPath,
      data: {
        'sessionId': sessionId.trim(),
      },
    );
  }

  @override
  Future<Map<String, dynamic>> submitPracticeAnswer({
    required String sessionId,
    required String questionId,
    required List<String> answers,
    required int costSeconds,
  }) {
    return _httpService.post<Map<String, dynamic>>(
      _submitPracticeAnswerPath,
      data: {
        'sessionId': sessionId.trim(),
        'questionId': questionId.trim(),
        'answers': answers,
        'costSeconds': costSeconds,
      },
    );
  }

  @override
  Future<Map<String, dynamic>> finishPracticeSession({
    required String sessionId,
  }) {
    return _httpService.post<Map<String, dynamic>>(
      _finishPracticeSessionPath,
      data: {
        'sessionId': sessionId.trim(),
      },
    );
  }

  @override
  Future<Map<String, dynamic>> getPracticeReport({
    required String sessionId,
  }) {
    return _httpService.post<Map<String, dynamic>>(
      _getPracticeReportPath,
      data: {
        'sessionId': sessionId.trim(),
      },
    );
  }
}
