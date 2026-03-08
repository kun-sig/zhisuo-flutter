import '../../local/subject_local_data_source.dart';
import '../../remote/subject_remote_service.dart';
import '../../models/subject/subject_models.dart';

/// 科目仓储层。
///
/// 职责：
/// 1. 协调远端与本地数据源。
/// 2. 对页面输出可直接渲染的菜单聚合数据。
/// 3. 管理“热门”虚拟分类与默认选中策略。
class SubjectRepository {
  SubjectRepository(this._localDataSource, this._remoteService);

  /// “热门”虚拟分类 ID（本地拼装，不来自后端）。
  static const String hotCategoryId = '__hot__';

  /// “热门”虚拟分类实体。
  static const SubjectCategoryItem hotCategory = SubjectCategoryItem(
    id: hotCategoryId,
    name: '热门',
    description: '按科目点击次数排行',
    order: -1,
  );

  /// 本地数据源（SQLite）。
  final SubjectLocalDataSource _localDataSource;

  /// 远端数据源（HTTP API）。
  final SubjectRemoteService _remoteService;

  /// 启动初始化：从远端拉全量数据并落地本地。
  Future<void> initializeSubjectData() async {
    final snapshot = await _remoteService.fetchAll();
    await _localDataSource.replaceAll(
      categories: snapshot.categories,
      tags: snapshot.tags,
      subjects: snapshot.subjects,
    );
  }

  Future<SubjectMenuData> fetchMenu({
    required String categoryId,
    required String keyword,
    required bool includeEmptyTags,
  }) async {
    // 分类列表：有点击记录时最前面插入“热门”。
    final categories = await _buildCategoriesWithHot();
    // 当前全局“最近点击”科目，用于每个菜单的默认选中。
    final latestClickedSubjectId =
        await _localDataSource.getLatestClickedSubjectId();

    // 解析当前应展示的分类（入参无效时自动回退）。
    final selectedCategoryId = _resolveCategoryId(categoryId, categories);
    if (selectedCategoryId.isEmpty) {
      return SubjectMenuData(
        categories: categories,
        selectedCategoryId: '',
        defaultSelectedSubjectId: '',
        groups: const [],
      );
    }

    // 热门分类：数据来源为点击统计排行，不走常规标签分组逻辑。
    if (selectedCategoryId == hotCategoryId) {
      var hotSubjects = await _localDataSource.getHotSubjectsRanked();
      final trimmedKeyword = keyword.trim().toLowerCase();
      if (trimmedKeyword.isNotEmpty) {
        // 热门同样支持关键词过滤。
        hotSubjects = hotSubjects
            .where((item) => item.name.toLowerCase().contains(trimmedKeyword))
            .toList();
      }
      final groups = hotSubjects.isEmpty
          ? const <SubjectGroupItem>[]
          : <SubjectGroupItem>[
              SubjectGroupItem(
                tag: const SubjectTagItem(
                  id: 'hot-rank',
                  subjectCategoryId: hotCategoryId,
                  name: '热门排行',
                  description: '',
                  order: 0,
                ),
                subjects: hotSubjects,
              ),
            ];
      return SubjectMenuData(
        categories: categories,
        selectedCategoryId: selectedCategoryId,
        defaultSelectedSubjectId:
            _resolveDefaultSelectedSubjectId(groups, latestClickedSubjectId),
        groups: groups,
      );
    }

    final tags = await _localDataSource.getTagsByCategory(selectedCategoryId);
    var subjects =
        await _localDataSource.getSubjectsByCategory(selectedCategoryId);

    final trimmedKeyword = keyword.trim().toLowerCase();
    if (trimmedKeyword.isNotEmpty) {
      // 常规分类关键词过滤。
      subjects = subjects
          .where((item) => item.name.toLowerCase().contains(trimmedKeyword))
          .toList();
    }

    final groups =
        _groupSubjects(tags, subjects, includeEmptyTags: includeEmptyTags);

    return SubjectMenuData(
      categories: categories,
      selectedCategoryId: selectedCategoryId,
      defaultSelectedSubjectId:
          _resolveDefaultSelectedSubjectId(groups, latestClickedSubjectId),
      groups: groups,
    );
  }

  /// 记录科目点击（用于热门排行与最近点击默认选中）。
  Future<void> recordSubjectClick(String subjectId) async {
    if (subjectId.isEmpty) {
      return;
    }
    await _localDataSource.increaseSubjectClickCount(subjectId);
  }

  /// 是否存在热门数据（是否至少有一个点击记录）。
  Future<bool> hasHotSubjects() async {
    return _localDataSource.hasSubjectClicks();
  }

  /// 组装分类列表：存在点击时注入“热门”固定菜单。
  Future<List<SubjectCategoryItem>> _buildCategoriesWithHot() async {
    final categories = await _localDataSource.getCategories();
    final hasHot = await _localDataSource.hasSubjectClicks();
    if (!hasHot) {
      return categories;
    }
    return <SubjectCategoryItem>[hotCategory, ...categories];
  }

  /// 解析应选中的分类 ID。
  ///
  /// 策略：
  /// - 入参存在且有效：使用入参。
  /// - 否则默认第一个分类（有热门时即默认热门）。
  String _resolveCategoryId(
      String categoryId, List<SubjectCategoryItem> categories) {
    if (categories.isEmpty) {
      return '';
    }
    if (categoryId.isNotEmpty &&
        categories.any((item) => item.id == categoryId)) {
      return categoryId;
    }
    return categories.first.id;
  }

  /// 按标签把科目分组成页面可渲染结构。
  ///
  /// 关键逻辑：
  /// - 只展示有科目的标签（`includeEmptyTags=false`）。
  /// - 无标签科目归并到“未分类”分组。
  List<SubjectGroupItem> _groupSubjects(
    List<SubjectTagItem> tags,
    List<SubjectItem> subjects, {
    required bool includeEmptyTags,
  }) {
    final grouped = <String, List<SubjectItem>>{};
    for (final item in subjects) {
      grouped.putIfAbsent(item.subjectTagId, () => <SubjectItem>[]).add(item);
    }

    final groups = <SubjectGroupItem>[];
    for (final tag in tags) {
      final tagSubjects = grouped[tag.id] ?? const <SubjectItem>[];
      if (tagSubjects.isEmpty && !includeEmptyTags) {
        continue;
      }
      groups.add(SubjectGroupItem(
          tag: tag, subjects: List<SubjectItem>.from(tagSubjects)));
      grouped.remove(tag.id);
    }

    final untagged = <SubjectItem>[];
    untagged.addAll(grouped.remove('') ?? const <SubjectItem>[]);
    grouped.values.forEach(untagged.addAll);
    if (untagged.isNotEmpty) {
      untagged.sort(_byOrderThenName);
      groups.add(
        SubjectGroupItem(
          tag: const SubjectTagItem(
            id: '',
            subjectCategoryId: '',
            name: '未分类',
            description: '',
            order: 1 << 30,
          ),
          subjects: untagged,
        ),
      );
    }

    return groups;
  }

  /// 计算当前菜单下默认选中的科目 ID。
  ///
  /// 若“最近点击科目”存在于当前菜单数据中，则默认选中该科目；
  /// 否则返回空字符串，交由上层保留当前选中态或清空。
  String _resolveDefaultSelectedSubjectId(
    List<SubjectGroupItem> groups,
    String latestClickedSubjectId,
  ) {
    if (latestClickedSubjectId.isEmpty) {
      return '';
    }
    for (final group in groups) {
      for (final subject in group.subjects) {
        if (subject.id == latestClickedSubjectId) {
          return latestClickedSubjectId;
        }
      }
    }
    return '';
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
