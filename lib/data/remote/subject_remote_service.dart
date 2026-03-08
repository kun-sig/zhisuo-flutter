import '../models/subject/subject_models.dart';
import '../../services/http_service.dart';

/// 远端全量快照（用于启动时一次性同步到本地）。
class SubjectRemoteSnapshot {
  const SubjectRemoteSnapshot({
    required this.categories,
    required this.tags,
    required this.subjects,
  });

  /// 远端返回的分类集合。
  final List<SubjectCategoryItem> categories;

  /// 远端返回的标签集合（跨分类聚合）。
  final List<SubjectTagItem> tags;

  /// 远端返回的科目集合（跨分类聚合）。
  final List<SubjectItem> subjects;
}

/// 科目远端数据源。
///
/// 仅负责调用后端接口并转换模型，不处理本地缓存策略。
class SubjectRemoteService {
  SubjectRemoteService(this._httpService);

  /// 通用 HTTP 客户端封装。
  final HttpService _httpService;

  /// 拉取全量科目数据。
  ///
  /// 流程：
  /// 1. 获取全部分类；
  /// 2. 按分类拉取标签、科目；
  /// 3. 汇总成单次快照返回。
  Future<SubjectRemoteSnapshot> fetchAll() async {
    final categories = await fetchCategories();
    final tags = <SubjectTagItem>[];
    final subjects = <SubjectItem>[];

    for (final category in categories) {
      tags.addAll(await fetchTags(category.id));
      subjects.addAll(await fetchSubjects(category.id));
    }

    return SubjectRemoteSnapshot(
      categories: categories,
      tags: tags,
      subjects: subjects,
    );
  }

  /// 拉取分类列表。
  Future<List<SubjectCategoryItem>> fetchCategories() async {
    final data = await _httpService.post<Map<String, dynamic>>(
      '/api/v1/subject/get_subject_categories',
      data: const {},
    );
    return _toMapList(data['objects'])
        .map(SubjectCategoryItem.fromJson)
        .toList()
      ..sort(_byOrderThenName);
  }

  /// 拉取指定分类下标签列表。
  Future<List<SubjectTagItem>> fetchTags(String categoryId) async {
    final data = await _httpService.post<Map<String, dynamic>>(
      '/api/v1/subject/get_subject_tags',
      data: {
        'subjectCategoryId': categoryId,
      },
    );
    return _toMapList(data['objects']).map(SubjectTagItem.fromJson).toList()
      ..sort(_byOrderThenName);
  }

  /// 拉取指定分类下科目列表。
  Future<List<SubjectItem>> fetchSubjects(String categoryId) async {
    final data = await _httpService.post<Map<String, dynamic>>(
      '/api/v1/subject/get_subjects',
      data: {
        'subjectCategoryId': categoryId,
      },
    );
    return _toMapList(data['objects']).map(SubjectItem.fromJson).toList()
      ..sort(_byOrderThenName);
  }
}

/// 通用排序器：先 `order`，再名称字典序。
int _byOrderThenName(dynamic a, dynamic b) {
  final aOrder = (a as dynamic).order as int;
  final bOrder = (b as dynamic).order as int;
  if (aOrder == bOrder) {
    final aName = (a as dynamic).name.toString();
    final bName = (b as dynamic).name.toString();
    return aName.compareTo(bName);
  }
  return aOrder.compareTo(bOrder);
}

/// 安全转换动态对象为 `Map<String, dynamic>`。
Map<String, dynamic> _toMap(dynamic raw) {
  if (raw is Map<String, dynamic>) {
    return raw;
  }
  if (raw is Map) {
    return raw.map((key, value) => MapEntry(key.toString(), value));
  }
  return const {};
}

/// 安全转换动态对象为 `List<Map<String, dynamic>>`。
List<Map<String, dynamic>> _toMapList(dynamic raw) {
  if (raw is! List) {
    return const [];
  }
  return raw.map(_toMap).toList();
}
