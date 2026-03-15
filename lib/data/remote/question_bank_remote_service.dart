import '../../services/http_service.dart';

abstract class QuestionBankRemoteDataSource {
  Future<Map<String, dynamic>> fetchDashboard({
    required String userId,
    required String subjectId,
    required String platform,
  });

  Future<Map<String, dynamic>> getPracticeCatalog({
    required String userId,
    required String subjectId,
    required String platform,
  });

  Future<Map<String, dynamic>> getPracticeUnitList({
    required String userId,
    required String subjectId,
    required String categoryCode,
    required String keyword,
    required String status,
    required int page,
    required int pageSize,
  });
}

/// 题库 dashboard 远端接口。
class QuestionBankRemoteService implements QuestionBankRemoteDataSource {
  QuestionBankRemoteService(this._httpService);

  static const _dashboardPath = '/api/v1/practice/get_question_bank_dashboard';
  static const _practiceCatalogPath = '/api/v1/practice/get_practice_catalog';
  static const _practiceUnitListPath =
      '/api/v1/practice/get_practice_unit_list';

  final HttpService _httpService;

  @override
  Future<Map<String, dynamic>> fetchDashboard({
    required String userId,
    required String subjectId,
    required String platform,
  }) async {
    return _httpService.post<Map<String, dynamic>>(
      _dashboardPath,
      data: {
        'userId': userId.trim(),
        'subjectId': subjectId.trim(),
        'platform': platform.trim(),
      },
    );
  }

  @override
  Future<Map<String, dynamic>> getPracticeCatalog({
    required String userId,
    required String subjectId,
    required String platform,
  }) async {
    return _httpService.post<Map<String, dynamic>>(
      _practiceCatalogPath,
      data: {
        'userId': userId.trim(),
        'subjectId': subjectId.trim(),
        'platform': platform.trim(),
      },
    );
  }

  @override
  Future<Map<String, dynamic>> getPracticeUnitList({
    required String userId,
    required String subjectId,
    required String categoryCode,
    required String keyword,
    required String status,
    required int page,
    required int pageSize,
  }) async {
    // 练习单元列表只允许走统一公开接口，避免回退到历史分类别名路径。
    return _httpService.post<Map<String, dynamic>>(
      _practiceUnitListPath,
      data: {
        'userId': userId.trim(),
        'subjectId': subjectId.trim(),
        'categoryCode': categoryCode.trim(),
        'keyword': keyword.trim(),
        'status': status.trim(),
        'page': page,
        'pageSize': pageSize,
      },
    );
  }
}
