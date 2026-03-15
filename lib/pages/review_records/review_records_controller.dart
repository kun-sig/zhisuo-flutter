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

class ReviewRecordModeOption {
  const ReviewRecordModeOption({
    required this.value,
    required this.labelKey,
  });

  final String value;
  final String labelKey;
}

class ReviewRecordsController extends GetxController {
  ReviewRecordsController(
    this._repository,
    this._appSessionService,
    this._currentSubjectService,
  );

  static const int _pageSize = 20;

  final PracticeAssetRepository _repository;
  final AppSessionService _appSessionService;
  final CurrentSubjectService _currentSubjectService;

  final items = <PracticeRecordAssetItem>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final errorText = ''.obs;
  final hasMore = false.obs;
  final totalSize = 0.obs;
  final categoryCode = ''.obs;
  final scrollController = ScrollController();

  late final Worker _subjectWorker;

  int _page = 1;

  String get subjectId =>
      _currentSubjectService.currentSubject.value?.id.trim() ?? '';
  String get subjectName =>
      _currentSubjectService.currentSubject.value?.name.trim() ?? '';
  bool get hasSubject => subjectId.isNotEmpty;
  bool get hasFilter => categoryCode.value.trim().isNotEmpty;

  List<ReviewRecordModeOption> get modeOptions => const [
        ReviewRecordModeOption(
          value: '',
          labelKey: LocaleKeys.reviewRecordsFilterAll,
        ),
        ReviewRecordModeOption(
          value: 'chapter',
          labelKey: LocaleKeys.practiceSessionCategoryChapter,
        ),
        ReviewRecordModeOption(
          value: 'knowledge_point',
          labelKey: LocaleKeys.practiceSessionCategoryKnowledge,
        ),
        ReviewRecordModeOption(
          value: 'mock_paper',
          labelKey: LocaleKeys.practiceSessionCategoryMock,
        ),
        ReviewRecordModeOption(
          value: 'past_paper',
          labelKey: LocaleKeys.practiceSessionCategoryPastPaper,
        ),
        ReviewRecordModeOption(
          value: 'wrong_question_practice',
          labelKey: LocaleKeys.practiceSessionCategoryWrongQuestion,
        ),
      ];

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
    super.onClose();
  }

  Future<void> retry() async {
    await refresh();
  }

  /// 拉取批改记录列表；当前用户态后端未开放独立接口时，由 repository 内部做兼容回退。
  @override
  Future<void> refresh() async {
    if (!hasSubject) {
      items.clear();
      totalSize.value = 0;
      hasMore.value = false;
      errorText.value = LocaleKeys.reviewRecordsNeedSubject.tr;
      return;
    }

    isLoading.value = true;
    errorText.value = '';

    try {
      final result = await _repository.fetchReviewRecords(
        userId: _appSessionService.userId,
        subjectId: subjectId,
        categoryCode: categoryCode.value,
        page: 1,
        pageSize: _pageSize,
      );
      _page = 1;
      items.assignAll(result.items);
      totalSize.value = result.totalSize;
      hasMore.value = result.hasMore;
    } catch (e, stackTrace) {
      Logger.e(
        'ReviewRecordsController.refresh failed',
        error: e,
        stackTrace: stackTrace,
      );
      errorText.value = LocaleKeys.reviewRecordsLoadFailed.tr;
    } finally {
      isLoading.value = false;
    }
  }

  /// 拉取下一页批改记录，保持与做题记录页一致的分页滚动体验。
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
      final result = await _repository.fetchReviewRecords(
        userId: _appSessionService.userId,
        subjectId: subjectId,
        categoryCode: categoryCode.value,
        page: nextPage,
        pageSize: _pageSize,
      );
      _page = nextPage;
      items.addAll(result.items);
      totalSize.value = result.totalSize;
      hasMore.value = result.hasMore;
    } catch (e, stackTrace) {
      Logger.e(
        'ReviewRecordsController.loadMore failed',
        error: e,
        stackTrace: stackTrace,
      );
      errorText.value = LocaleKeys.reviewRecordsLoadFailed.tr;
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// 切换正式分类筛选后立即重载数据，保证资产页与后端统一按 `categoryCode` 联动。
  Future<void> changeCategoryCode(String value) async {
    final resolvedValue = value.trim();
    if (categoryCode.value == resolvedValue) {
      return;
    }
    categoryCode.value = resolvedValue;
    await refresh();
  }

  /// 统一把正式分类编码转换为用户可读文案，避免页面直接暴露后端协议值。
  String resolveCategoryText(String categoryCode) {
    switch (categoryCode.trim().toLowerCase()) {
      case 'chapter':
        return LocaleKeys.practiceSessionCategoryChapter.tr;
      case 'knowledge_point':
        return LocaleKeys.practiceSessionCategoryKnowledge.tr;
      case 'mock_paper':
        return LocaleKeys.practiceSessionCategoryMock.tr;
      case 'past_paper':
        return LocaleKeys.practiceSessionCategoryPastPaper.tr;
      case 'wrong_question_practice':
        return LocaleKeys.practiceSessionCategoryWrongQuestion.tr;
      default:
        final value = categoryCode.trim();
        if (value.isEmpty) {
          return '--';
        }
        return value;
    }
  }

  /// 记录关联练习会话时，允许继续进入报告页查看练习结果。
  void openReport(PracticeRecordAssetItem item) {
    final sessionId = item.sessionId.trim();
    if (sessionId.isEmpty) {
      _showNotice(LocaleKeys.practiceHistoryMissingSession.tr);
      return;
    }
    AppNavigator.startPracticeReportPage(
      sessionId: sessionId,
      replace: false,
    );
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

  /// 测试或无 UI 容器场景下跳过 snackbar，避免 overlay 缺失导致回归失败。
  void _showNotice(String message) {
    final text = message.trim();
    if (text.isEmpty) {
      return;
    }
    if (Get.overlayContext == null && Get.context == null) {
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
