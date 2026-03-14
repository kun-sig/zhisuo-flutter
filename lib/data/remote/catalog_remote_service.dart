import '../../services/http_service.dart';

/// 目录域远端接口。
///
/// 当前主要为“当前科目”和考试计划预留统一接入点。
class CatalogRemoteService {
  CatalogRemoteService(this._httpService);

  static const _getCurrentSubjectPath = '/api/v1/catalog/get_current_subject';
  static const _setCurrentSubjectPath = '/api/v1/catalog/set_current_subject';
  static const _getExamPlanPath = '/api/v1/catalog/get_exam_plan';

  final HttpService _httpService;

  Future<Map<String, dynamic>> getCurrentSubject({
    required String userId,
  }) async {
    return _httpService.post<Map<String, dynamic>>(
      _getCurrentSubjectPath,
      data: {
        'userId': userId.trim(),
      },
    );
  }

  Future<Map<String, dynamic>> setCurrentSubject({
    required String userId,
    required String subjectId,
  }) async {
    return _httpService.post<Map<String, dynamic>>(
      _setCurrentSubjectPath,
      data: {
        'userId': userId.trim(),
        'subjectId': subjectId.trim(),
      },
    );
  }

  Future<Map<String, dynamic>> getExamPlan({
    required String subjectId,
  }) async {
    return _httpService.post<Map<String, dynamic>>(
      _getExamPlanPath,
      data: {
        'subjectId': subjectId.trim(),
      },
    );
  }
}
