/// 科目分类模型（左侧一级菜单）。
class SubjectCategoryItem {
  /// 分类唯一 ID（后端主键）。
  final String id;

  /// 分类名称（用于左侧菜单展示）。
  final String name;

  /// 分类描述（当前页面未直接展示，保留给后续扩展）。
  final String description;

  /// 排序值，越小越靠前。
  final int order;

  const SubjectCategoryItem({
    required this.id,
    required this.name,
    required this.description,
    required this.order,
  });

  /// 从后端 JSON 转换为分类模型。
  factory SubjectCategoryItem.fromJson(Map<String, dynamic> json) {
    return SubjectCategoryItem(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      order: _toInt(json['order']),
    );
  }
}

/// 科目标签模型（右侧分组标题）。
class SubjectTagItem {
  /// 标签唯一 ID（后端主键）。
  final String id;

  /// 所属分类 ID，用于建立“分类 -> 标签”关系。
  final String subjectCategoryId;

  /// 标签名称（分组标题显示）。
  final String name;

  /// 标签描述（当前页面未直接展示）。
  final String description;

  /// 排序值，越小越靠前。
  final int order;

  const SubjectTagItem({
    required this.id,
    required this.subjectCategoryId,
    required this.name,
    required this.description,
    required this.order,
  });

  /// 从后端 JSON 转换为标签模型。
  factory SubjectTagItem.fromJson(Map<String, dynamic> json) {
    return SubjectTagItem(
      id: (json['id'] ?? '').toString(),
      subjectCategoryId: (json['subjectCategoryId'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      order: _toInt(json['order']),
    );
  }
}

/// 科目模型（右侧卡片项）。
class SubjectItem {
  /// 科目唯一 ID（后端主键）。
  final String id;

  /// 所属分类 ID。
  final String subjectCategoryId;

  /// 所属标签 ID；可能为空（表示未分类标签）。
  final String subjectTagId;

  /// 科目名称（卡片标题显示）。
  final String name;

  /// 科目描述（当前页面简化后未展示）。
  final String description;

  /// 排序值，越小越靠前。
  final int order;

  const SubjectItem({
    required this.id,
    required this.subjectCategoryId,
    required this.subjectTagId,
    required this.name,
    required this.description,
    required this.order,
  });

  /// 从后端 JSON 转换为科目模型。
  factory SubjectItem.fromJson(Map<String, dynamic> json) {
    return SubjectItem(
      id: (json['id'] ?? '').toString(),
      subjectCategoryId: (json['subjectCategoryId'] ?? '').toString(),
      subjectTagId: (json['subjectTagId'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      order: _toInt(json['order']),
    );
  }
}

/// 科目分组模型（一个标签 + 该标签下的科目列表）。
class SubjectGroupItem {
  /// 分组标签信息。
  final SubjectTagItem tag;

  /// 分组内的科目列表。
  final List<SubjectItem> subjects;

  const SubjectGroupItem({
    required this.tag,
    required this.subjects,
  });
}

/// 科目菜单聚合模型（页面渲染所需的完整数据）。
class SubjectMenuData {
  /// 左侧分类列表（可能包含“热门”虚拟分类）。
  final List<SubjectCategoryItem> categories;

  /// 当前选中的分类 ID。
  final String selectedCategoryId;

  /// 当前菜单下默认应选中的科目 ID（如最近点击项）。
  final String defaultSelectedSubjectId;

  /// 右侧分组数据。
  final List<SubjectGroupItem> groups;

  const SubjectMenuData({
    required this.categories,
    required this.selectedCategoryId,
    required this.defaultSelectedSubjectId,
    required this.groups,
  });

  /// 兼容菜单接口 JSON 的反序列化（保留通用能力）。
  factory SubjectMenuData.fromMenuJson(Map<String, dynamic> json) {
    final categories = _toMapList(json['categories'])
        .map(SubjectCategoryItem.fromJson)
        .toList();
    final groups = _toMapList(json['groups']).map((groupJson) {
      final tag = SubjectTagItem.fromJson(_toMap(groupJson['tag']));
      final subjects =
          _toMapList(groupJson['subjects']).map(SubjectItem.fromJson).toList();
      return SubjectGroupItem(tag: tag, subjects: subjects);
    }).toList();

    return SubjectMenuData(
      categories: categories,
      selectedCategoryId: (json['selectedCategoryId'] ?? '').toString(),
      defaultSelectedSubjectId:
          (json['defaultSelectedSubjectId'] ?? '').toString(),
      groups: groups,
    );
  }
}

/// 将动态对象安全转换为 `Map<String, dynamic>`。
Map<String, dynamic> _toMap(dynamic raw) {
  if (raw is Map<String, dynamic>) {
    return raw;
  }
  if (raw is Map) {
    return raw.map((key, value) => MapEntry(key.toString(), value));
  }
  return const {};
}

/// 将动态对象安全转换为 `List<Map<String, dynamic>>`。
List<Map<String, dynamic>> _toMapList(dynamic raw) {
  if (raw is! List) {
    return const [];
  }
  return raw.map(_toMap).toList();
}

/// 将后端动态数值安全转换为 `int`。
int _toInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
