import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../data/models/question_bank/question_bank_dashboard_models.dart';
import '../../data/models/subject/subject_models.dart';
import '../../data/repositories/question_bank/question_bank_dashboard_repository.dart';
import '../../i18n/locale_keys.dart';
import '../../logger/logger.dart';
import '../../routes/app_navigator.dart';
import '../../services/app_session_service.dart';
import '../../services/current_subject_service.dart';

class PracticeUnitStatusFilterOption {
  const PracticeUnitStatusFilterOption({
    required this.value,
    required this.labelKey,
  });

  final String value;
  final String labelKey;
}

class PracticeUnitListController extends GetxController {
  PracticeUnitListController(
    this._repository,
    this._appSessionService,
    this._currentSubjectService,
  );

  static const int _pageSize = 20;

  final QuestionBankDashboardRepository _repository;
  final AppSessionService _appSessionService;
  final CurrentSubjectService _currentSubjectService;

  final items = <PracticeUnitPreviewData>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final errorText = ''.obs;
  final hasMore = false.obs;
  final totalSize = 0.obs;
  final categoryName = ''.obs;
  final category = Rxn<PracticeCategoryCardData>();
  final scrollController = ScrollController();
  final keywordController = TextEditingController();
  final keyword = ''.obs;
  final status = ''.obs;
  final draftStatus = ''.obs;

  late final Worker _subjectWorker;

  String _categoryCode = '';
  int _page = 1;

  String get subjectId =>
      _currentSubjectService.currentSubject.value?.id.trim() ?? '';
  String get subjectName =>
      _currentSubjectService.currentSubject.value?.name.trim() ?? '';
  bool get hasSubject => subjectId.isNotEmpty;
  bool get hasCategoryCode => _categoryCode.isNotEmpty;
  bool get hasFilter =>
      keyword.value.trim().isNotEmpty || status.value.trim().isNotEmpty;
  int get filterCount {
    var count = 0;
    if (keyword.value.trim().isNotEmpty) {
      count += 1;
    }
    if (status.value.trim().isNotEmpty) {
      count += 1;
    }
    return count;
  }

  List<PracticeUnitStatusFilterOption> get statusOptions => const [
        PracticeUnitStatusFilterOption(
          value: '',
          labelKey: LocaleKeys.practiceUnitListFilterStatusAll,
        ),
        PracticeUnitStatusFilterOption(
          value: 'not_started',
          labelKey: LocaleKeys.questionBankDashboardUnitStatusNotStarted,
        ),
        PracticeUnitStatusFilterOption(
          value: 'in_progress',
          labelKey: LocaleKeys.questionBankDashboardUnitStatusInProgress,
        ),
        PracticeUnitStatusFilterOption(
          value: 'completed',
          labelKey: LocaleKeys.questionBankDashboardUnitStatusCompleted,
        ),
      ];

  String get pageTitle {
    final value =
        category.value?.categoryName.trim() ?? categoryName.value.trim();
    if (value.isNotEmpty) {
      return value;
    }
    return LocaleKeys.practiceUnitListTitle.tr;
  }

  int get completedUnitCount => category.value?.completedUnitCount ?? 0;
  double get averageCorrectRate => category.value?.averageCorrectRate ?? 0;
  bool get isCategoryDisabled => category.value?.enabled == false;

  /// 暴露分类禁用原因，供列表页统一渲染灰态说明和空态兜底文案。
  String get categoryDisabledReason {
    final value = category.value?.disabledReason.trim() ?? '';
    if (value.isNotEmpty) {
      return value;
    }
    return LocaleKeys.practiceUnitListCategoryDisabledBanner.tr;
  }

  /// 初始化路由参数、滚动监听和科目联动刷新。
  @override
  void onInit() {
    super.onInit();
    _readArguments();
    scrollController.addListener(_handleScroll);
    _subjectWorker = ever<SubjectItem?>(
      _currentSubjectService.currentSubject,
      (_) => unawaited(refresh()),
    );
    refresh();
  }

  /// 释放滚动监听和科目监听，避免页面销毁后残留回调。
  @override
  void onClose() {
    _subjectWorker.dispose();
    scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    keywordController.dispose();
    super.onClose();
  }

  /// 供错误态按钮触发整页重新加载。
  Future<void> retry() async {
    await refresh();
  }

  /// 重新拉取分类元数据和当前分类下的第一页单元列表。
  @override
  Future<void> refresh() async {
    if (!hasCategoryCode) {
      items.clear();
      totalSize.value = 0;
      hasMore.value = false;
      errorText.value = LocaleKeys.practiceUnitListMissingCategory.tr;
      return;
    }

    if (!hasSubject) {
      items.clear();
      totalSize.value = 0;
      hasMore.value = false;
      errorText.value = LocaleKeys.practiceUnitListNeedSubject.tr;
      return;
    }

    isLoading.value = true;
    errorText.value = '';

    try {
      await _syncCategoryMeta();
      final result = await _repository.fetchPracticeUnitList(
        userId: _appSessionService.userId,
        subjectId: subjectId,
        categoryCode: _categoryCode,
        keyword: keyword.value,
        status: status.value,
        page: 1,
        pageSize: _pageSize,
      );
      _page = 1;
      items.assignAll(result.items);
      totalSize.value = result.totalSize;
      hasMore.value = result.hasMore;
    } catch (e, stackTrace) {
      Logger.e(
        'PracticeUnitListController.refresh failed',
        error: e,
        stackTrace: stackTrace,
      );
      errorText.value = LocaleKeys.practiceUnitListLoadFailed.tr;
    } finally {
      isLoading.value = false;
    }
  }

  /// 拉取下一页单元列表并追加到当前页面。
  Future<void> loadMore() async {
    if (!hasSubject ||
        !hasCategoryCode ||
        isLoading.value ||
        isLoadingMore.value ||
        !hasMore.value) {
      return;
    }

    isLoadingMore.value = true;
    errorText.value = '';
    final nextPage = _page + 1;

    try {
      final result = await _repository.fetchPracticeUnitList(
        userId: _appSessionService.userId,
        subjectId: subjectId,
        categoryCode: _categoryCode,
        keyword: keyword.value,
        status: status.value,
        page: nextPage,
        pageSize: _pageSize,
      );
      _page = nextPage;
      items.addAll(result.items);
      totalSize.value = result.totalSize;
      hasMore.value = result.hasMore;
    } catch (e, stackTrace) {
      Logger.e(
        'PracticeUnitListController.loadMore failed',
        error: e,
        stackTrace: stackTrace,
      );
      errorText.value = LocaleKeys.practiceUnitListLoadFailed.tr;
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// 单元点击后按统一单元参数进入练习会话页。
  void onUnitTap(PracticeUnitPreviewData unit) {
    if (isCategoryDisabled) {
      _showNotice(categoryDisabledReason);
      return;
    }
    if (!unit.isEnabled) {
      _showNotice(
        unit.disabledReason.trim().isNotEmpty
            ? unit.disabledReason
            : LocaleKeys.questionBankDashboardUnitDisabled.tr,
      );
      return;
    }
    final categoryCode = unit.categoryCode.trim();
    final unitId = unit.unitId.trim();
    if (categoryCode.isEmpty || unitId.isEmpty) {
      _showNotice(LocaleKeys.questionBankDashboardUnitPlanned.tr);
      return;
    }
    AppNavigator.startPracticeSessionPage(
      categoryCode: categoryCode,
      unitId: unitId,
      unitTitle: unit.title,
      continueIfExists: true,
    );
  }

  /// 应用搜索词和状态筛选，并回到第一页重新加载列表。
  Future<void> applyFilters() async {
    keyword.value = keywordController.text.trim();
    status.value = draftStatus.value.trim();
    await refresh();
  }

  /// 清空已生效和待生效的筛选条件，保证空结果页也能快速恢复。
  Future<void> clearFilters() async {
    keywordController.clear();
    keyword.value = '';
    status.value = '';
    draftStatus.value = '';
    await refresh();
  }

  /// 切换状态筛选草稿，重复点击同一项时回到“全部”。
  void toggleDraftStatus(String value) {
    final resolvedValue = value.trim();
    if (draftStatus.value == resolvedValue) {
      draftStatus.value = '';
      return;
    }
    draftStatus.value = resolvedValue;
  }

  /// 从路由参数读取当前分类编码和名称。
  void _readArguments() {
    final args = Get.arguments;
    if (args is! Map) {
      return;
    }
    _categoryCode = (args['categoryCode'] ?? '').toString().trim();
    categoryName.value = (args['categoryName'] ?? '').toString().trim();
  }

  /// 使用 catalog 接口补全当前分类名称和统计信息，失败时保留已有路由参数兜底。
  Future<void> _syncCategoryMeta() async {
    try {
      final data = await _repository.fetchPracticeCatalog(
        userId: _appSessionService.userId,
        subjectId: subjectId,
        platform: _appSessionService.platform,
      );
      PracticeCategoryCardData? matched;
      for (final item in data.categories) {
        if (item.categoryCode.trim() == _categoryCode) {
          matched = item;
          break;
        }
      }
      category.value = matched;
      if (matched != null && matched.categoryName.trim().isNotEmpty) {
        categoryName.value = matched.categoryName.trim();
      }
    } catch (e, stackTrace) {
      Logger.e(
        'PracticeUnitListController._syncCategoryMeta failed',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 滚动接近底部时自动加载下一页。
  void _handleScroll() {
    if (!scrollController.hasClients) {
      return;
    }
    final position = scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      unawaited(loadMore());
    }
  }

  /// 统一展示底部提示，避免页面重复拼接 snackbar 配置。
  void _showNotice(String message) {
    final text = message.trim();
    if (text.isEmpty) {
      return;
    }
    Get.snackbar(
      LocaleKeys.commonNoticeTitle.tr,
      text,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }
}
