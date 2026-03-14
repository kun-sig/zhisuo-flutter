import '../../../logger/logger.dart';
import '../../../services/api_exception.dart';
import '../../../services/http_service.dart';
import '../../models/home/home_models.dart';

/// 首页仓储层。
///
/// 职责：
/// 1. 拉取首页聚合数据（横幅 + 资讯分页）。
/// 2. 统一请求参数归一化。
/// 3. 透传业务异常供上层展示。
class HomeRepository {
  HomeRepository(this._httpService);

  static const String _homeFeedPath = '/api/v1/cms/get_home_feed';
  static const String _homeArticlePath = '/api/v1/cms/get_home_article';

  final HttpService _httpService;

  Future<HomeFeedData> fetchHomeFeed({
    required String subjectId,
    required String platform,
    required int page,
    required int pageSize,
  }) async {
    final safePage = page <= 0 ? 1 : page;
    final safePageSize = pageSize <= 0 ? 10 : pageSize;
    final normalizedSubjectId = subjectId.trim();
    final normalizedPlatform = _normalizePlatform(platform);

    try {
      final data = await _httpService.post<Map<String, dynamic>>(
        _homeFeedPath,
        data: {
          'subjectId': normalizedSubjectId,
          'platform': normalizedPlatform,
          'page': safePage,
          'pageSize': safePageSize,
        },
      );
      return HomeFeedData.fromJson(data);
    } on ApiException catch (e) {
      Logger.w(
        'fetchHomeFeed business failed: code=${e.code}, '
        'message=${e.message}, requestId=${e.requestId}',
      );
      rethrow;
    } catch (e) {
      Logger.w('fetchHomeFeed failed: $e');
      rethrow;
    }
  }

  Future<HomeArticleDetailData> fetchHomeArticle({
    required String articleId,
  }) async {
    final normalizedArticleId = articleId.trim();
    if (normalizedArticleId.isEmpty) {
      throw const ApiException(
        code: -1,
        message: 'article id is required',
      );
    }

    try {
      final data = await _httpService.post<Map<String, dynamic>>(
        _homeArticlePath,
        data: {
          'articleId': normalizedArticleId,
        },
      );
      return HomeArticleDetailData.fromJson(data);
    } on ApiException catch (e) {
      Logger.w(
        'fetchHomeArticle business failed: code=${e.code}, '
        'message=${e.message}, requestId=${e.requestId}',
      );
      rethrow;
    } catch (e) {
      Logger.w('fetchHomeArticle failed: $e');
      rethrow;
    }
  }

  String _normalizePlatform(String platform) {
    final value = platform.trim();
    if (value.isEmpty) {
      return 'phone';
    }
    return value;
  }
}
