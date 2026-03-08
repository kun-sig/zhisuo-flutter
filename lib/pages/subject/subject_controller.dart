import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/subject/subject_models.dart';
import '../../data/repositories/subject/subject_repository.dart';

/// 科目页控制器（UI 状态层）。
///
/// 负责：
/// 1. 页面状态管理（加载态、错误态、当前选中项）。
/// 2. 响应用户交互（分类切换、科目点击、搜索）。
/// 3. 调用仓储获取菜单并应用到 UI。
class SubjectController extends GetxController {
  SubjectController(this._repository);

  /// 科目仓储（数据编排入口）。
  final SubjectRepository _repository;

  /// 左侧分类列表。
  final categories = <SubjectCategoryItem>[].obs;

  /// 右侧分组列表。
  final groups = <SubjectGroupItem>[].obs;

  /// 当前选中分类 ID。
  final selectedCategoryId = ''.obs;

  /// 当前选中科目 ID。
  final selectedSubjectId = ''.obs;

  /// 首屏加载状态。
  final isPageLoading = false.obs;

  /// 分类切换/搜索时右侧分组加载状态。
  final isGroupLoading = false.obs;

  /// 错误文案（展示给页面）。
  final errorText = ''.obs;

  /// 搜索关键字（响应式）。
  final keyword = ''.obs;

  /// 搜索框控制器。
  final searchController = TextEditingController();

  /// 搜索防抖监听器。
  late final Worker _keywordWorker;

  @override
  void onInit() {
    super.onInit();
    // 输入变化同步到 keyword，交由防抖逻辑触发查询。
    searchController.addListener(() {
      keyword.value = searchController.text;
    });
    // 防止每次输入都请求/组装数据，减少 UI 抖动与计算开销。
    _keywordWorker = debounce<String>(
      keyword,
      (_) => refreshCurrentCategory(),
      time: const Duration(milliseconds: 350),
    );
    // 首次进入页面加载菜单。
    loadInitial();
  }

  @override
  void onClose() {
    _keywordWorker.dispose();
    searchController.dispose();
    super.onClose();
  }

  /// 首次加载菜单。
  Future<void> loadInitial() async {
    isPageLoading.value = true;
    errorText.value = '';
    try {
      final menu = await _repository.fetchMenu(
        categoryId: selectedCategoryId.value,
        keyword: keyword.value,
        includeEmptyTags: false,
      );
      _applyMenu(menu);
    } catch (e) {
      errorText.value = e.toString();
    } finally {
      isPageLoading.value = false;
    }
  }

  /// 点击左侧分类。
  Future<void> onCategoryTap(String categoryId) async {
    if (categoryId == selectedCategoryId.value) {
      return;
    }
    selectedCategoryId.value = categoryId;
    await refreshCurrentCategory();
  }

  /// 刷新当前分类下的菜单数据（分类切换/搜索共用）。
  Future<void> refreshCurrentCategory() async {
    if (selectedCategoryId.value.isEmpty && categories.isEmpty) {
      await loadInitial();
      return;
    }
    isGroupLoading.value = true;
    errorText.value = '';
    try {
      final menu = await _repository.fetchMenu(
        categoryId: selectedCategoryId.value,
        keyword: keyword.value,
        includeEmptyTags: false,
      );
      _applyMenu(menu);
    } catch (e) {
      errorText.value = e.toString();
    } finally {
      isGroupLoading.value = false;
    }
  }

  /// 点击科目卡片。
  ///
  /// 关键逻辑：
  /// - 立即更新选中态，保证交互即时反馈；
  /// - 异步记录点击次数，用于热门排行与默认选中策略。
  Future<void> onSubjectTap(String subjectId) async {
    selectedSubjectId.value = subjectId;
    await _repository.recordSubjectClick(subjectId);
    final hasHot = await _repository.hasHotSubjects();
    if (hasHot &&
        !categories.any((item) => item.id == SubjectRepository.hotCategoryId)) {
      // 首次产生点击后，动态插入“热门”分类。
      categories.insert(0, SubjectRepository.hotCategory);
    }
  }

  /// 将仓储返回的菜单数据应用到控制器状态。
  void _applyMenu(SubjectMenuData menu) {
    categories.assignAll(menu.categories);

    if (menu.selectedCategoryId.isNotEmpty) {
      selectedCategoryId.value = menu.selectedCategoryId;
    } else if (selectedCategoryId.value.isEmpty && categories.isNotEmpty) {
      selectedCategoryId.value = categories.first.id;
    }

    groups.assignAll(menu.groups);

    // 统一默认选中策略：若当前菜单命中“最近点击科目”，则优先选中。
    if (menu.defaultSelectedSubjectId.isNotEmpty) {
      selectedSubjectId.value = menu.defaultSelectedSubjectId;
      return;
    }

    // 若当前选中科目已不在新数据中，则清空选中态。
    final existed = groups.any(
      (group) => group.subjects
          .any((subject) => subject.id == selectedSubjectId.value),
    );
    if (!existed) {
      selectedSubjectId.value = '';
    }
  }
}
