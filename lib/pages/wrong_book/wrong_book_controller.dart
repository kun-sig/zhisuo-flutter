import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../data/models/question_bank/asset_models.dart';
import '../../data/models/subject/subject_models.dart';
import '../../data/repositories/question_bank/practice_asset_repository.dart';
import '../../i18n/locale_keys.dart';
import '../../logger/logger.dart';
import '../../routes/app_navigator.dart';
import '../../services/app_session_service.dart';
import '../../services/current_subject_service.dart';

class WrongBookRetryPracticeTarget {
  const WrongBookRetryPracticeTarget({
    required this.categoryCode,
    required this.unitId,
    this.unitTitle,
  });

  final String categoryCode;
  final String unitId;
  final String? unitTitle;
}

class WrongBookController extends GetxController {
  static const bool _autoApplyWrongBookFilter = bool.fromEnvironment(
    'AUTO_APPLY_WRONG_BOOK_FILTER',
    defaultValue: false,
  );
  static const bool _autoStartWrongBookRetry = bool.fromEnvironment(
    'AUTO_START_WRONG_BOOK_RETRY',
    defaultValue: false,
  );
  static const String _autoWrongBookChapterId = String.fromEnvironment(
    'AUTO_WRONG_BOOK_CHAPTER_ID',
    defaultValue: 'seed-practice-chapter',
  );

  WrongBookController(
    this._repository,
    this._appSessionService,
    this._currentSubjectService,
  );

  static const int _pageSize = 20;

  final PracticeAssetRepository _repository;
  final AppSessionService _appSessionService;
  final CurrentSubjectService _currentSubjectService;

  final items = <WrongQuestionAssetItem>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final errorText = ''.obs;
  final hasMore = false.obs;
  final totalSize = 0.obs;
  final scrollController = ScrollController();
  final chapterIdController = TextEditingController();
  final questionCategoryIdController = TextEditingController();
  final chapterId = ''.obs;
  final questionCategoryId = ''.obs;

  late final Worker _subjectWorker;

  int _page = 1;
  bool _isAutoFlowRunning = false;
  bool _hasAutoAppliedFilter = false;
  bool _hasAutoStartedRetry = false;

  String get subjectId =>
      _currentSubjectService.currentSubject.value?.id.trim() ?? '';
  String get subjectName =>
      _currentSubjectService.currentSubject.value?.name.trim() ?? '';
  bool get hasSubject => subjectId.isNotEmpty;
  bool get hasFilter =>
      chapterId.value.trim().isNotEmpty ||
      questionCategoryId.value.trim().isNotEmpty;
  bool get isRetryPracticeReady => resolveRetryPracticeTarget() != null;
  String get retryPracticeStatusText {
    final blockedMessage = resolveRetryPracticeBlockedMessage();
    if (blockedMessage != null) {
      return blockedMessage;
    }
    if (chapterId.value.trim().isNotEmpty) {
      return LocaleKeys.wrongBookRetryChapterReady.tr;
    }
    return '';
  }

  int get filterCount {
    var count = 0;
    if (chapterId.value.trim().isNotEmpty) {
      count += 1;
    }
    if (questionCategoryId.value.trim().isNotEmpty) {
      count += 1;
    }
    return count;
  }

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_handleScroll);
    _subjectWorker = ever<SubjectItem?>(
      _currentSubjectService.currentSubject,
      (_) => unawaited(refresh()),
    );
    refresh();
  }

  @override
  void onClose() {
    _subjectWorker.dispose();
    scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    chapterIdController.dispose();
    questionCategoryIdController.dispose();
    super.onClose();
  }

  Future<void> retry() async {
    await refresh();
  }

  @override
  Future<void> refresh() async {
    if (!hasSubject) {
      items.clear();
      totalSize.value = 0;
      hasMore.value = false;
      errorText.value = LocaleKeys.wrongBookNeedSubject.tr;
      return;
    }

    isLoading.value = true;
    errorText.value = '';

    try {
      final result = await _repository.fetchWrongQuestions(
        userId: _appSessionService.userId,
        subjectId: subjectId,
        chapterId: chapterId.value,
        questionCategoryId: questionCategoryId.value,
        page: 1,
        pageSize: _pageSize,
      );
      _page = 1;
      items.assignAll(result.items);
      totalSize.value = result.totalSize;
      hasMore.value = result.hasMore;
    } catch (e, stackTrace) {
      Logger.e(
        'WrongBookController.refresh failed',
        error: e,
        stackTrace: stackTrace,
      );
      errorText.value = LocaleKeys.wrongBookLoadFailed.tr;
    } finally {
      isLoading.value = false;
      _maybeRunAutoFlow();
    }
  }

  Future<void> loadMore() async {
    if (!hasSubject ||
        isLoading.value ||
        isLoadingMore.value ||
        !hasMore.value) {
      return;
    }

    isLoadingMore.value = true;
    errorText.value = '';
    final nextPage = _page + 1;

    try {
      final result = await _repository.fetchWrongQuestions(
        userId: _appSessionService.userId,
        subjectId: subjectId,
        chapterId: chapterId.value,
        questionCategoryId: questionCategoryId.value,
        page: nextPage,
        pageSize: _pageSize,
      );
      _page = nextPage;
      items.addAll(result.items);
      totalSize.value = result.totalSize;
      hasMore.value = result.hasMore;
    } catch (e, stackTrace) {
      Logger.e(
        'WrongBookController.loadMore failed',
        error: e,
        stackTrace: stackTrace,
      );
      errorText.value = LocaleKeys.wrongBookLoadFailed.tr;
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> applyFilters() async {
    chapterId.value = chapterIdController.text.trim();
    questionCategoryId.value = questionCategoryIdController.text.trim();
    await refresh();
  }

  Future<void> clearFilters() async {
    chapterIdController.clear();
    questionCategoryIdController.clear();
    chapterId.value = '';
    questionCategoryId.value = '';
    await refresh();
  }

  /// 统一校验错题本回练入口的筛选前置条件，避免把无效筛选直接带入练习页。
  String? resolveRetryPracticeBlockedMessage() {
    if (!hasFilter) {
      return LocaleKeys.wrongBookRetryNeedFilter.tr;
    }
    if (filterCount > 1) {
      return LocaleKeys.wrongBookRetrySingleFilterOnly.tr;
    }
    if (questionCategoryId.value.trim().isNotEmpty) {
      return LocaleKeys.wrongBookRetryQuestionCategoryUnsupported.tr;
    }
    return null;
  }

  /// 把错题本筛选条件映射为统一练习入口。
  /// 当前后端已把错题专项单元收敛到 `wrong_question_practice + chapterId`，
  /// 因此前端直接复用章节 ID 作为错题专项单元 ID 即可进入真实回练闭环。
  WrongBookRetryPracticeTarget? resolveRetryPracticeTarget() {
    final blockedMessage = resolveRetryPracticeBlockedMessage();
    if (blockedMessage != null) {
      return null;
    }
    final unitId = chapterId.value.trim();
    if (unitId.isEmpty) {
      return null;
    }
    return WrongBookRetryPracticeTarget(
      categoryCode: 'wrong_question_practice',
      unitId: unitId,
    );
  }

  /// 从错题本进入真实练习链路；当前先支持章节维度错题专项回练，题型维度等待后端补齐二级单元。
  void startRetryPractice() {
    final blockedMessage = resolveRetryPracticeBlockedMessage();
    if (blockedMessage != null) {
      _showNotice(blockedMessage);
      return;
    }
    final target = resolveRetryPracticeTarget();
    if (target == null) {
      _showNotice(LocaleKeys.wrongBookRetryPlanned.tr);
      return;
    }
    AppNavigator.startPracticeSessionPage(
      categoryCode: target.categoryCode,
      unitId: target.unitId,
      unitTitle: target.unitTitle,
      continueIfExists: true,
    );
  }

  String resolveStatusText(String status) {
    switch (status.trim().toLowerCase()) {
      case 'active':
        return LocaleKeys.wrongBookStatusActive.tr;
      case 'archived':
        return LocaleKeys.wrongBookStatusArchived.tr;
      case '':
        return LocaleKeys.wrongBookStatusUnknown.tr;
      default:
        return status;
    }
  }

  void _handleScroll() {
    if (!scrollController.hasClients) {
      return;
    }
    final position = scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      unawaited(loadMore());
    }
  }

  /// 仅在联调开关开启时自动回填章节筛选并触发重练，减少模拟器手工点击成本。
  void _maybeRunAutoFlow() {
    if (_isAutoFlowRunning || !hasSubject || isLoading.value) {
      return;
    }
    if (_autoApplyWrongBookFilter && !_hasAutoAppliedFilter) {
      final chapterId = _autoWrongBookChapterId.trim();
      if (chapterId.isEmpty) {
        return;
      }
      _hasAutoAppliedFilter = true;
      _isAutoFlowRunning = true;
      chapterIdController.text = chapterId;
      questionCategoryIdController.clear();
      Future<void>.delayed(const Duration(milliseconds: 300), () async {
        try {
          await applyFilters();
        } finally {
          _isAutoFlowRunning = false;
          _maybeRunAutoFlow();
        }
      });
      return;
    }
    if (_autoStartWrongBookRetry && !_hasAutoStartedRetry) {
      final blockedMessage = resolveRetryPracticeBlockedMessage();
      if (blockedMessage != null) {
        return;
      }
      _hasAutoStartedRetry = true;
      Future<void>.delayed(
          const Duration(milliseconds: 300), startRetryPractice);
    }
  }

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
