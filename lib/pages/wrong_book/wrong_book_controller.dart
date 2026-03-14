import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../data/models/question_bank/asset_models.dart';
import '../../data/models/subject/subject_models.dart';
import '../../data/repositories/question_bank/practice_asset_repository.dart';
import '../../i18n/locale_keys.dart';
import '../../logger/logger.dart';
import '../../services/app_session_service.dart';
import '../../services/current_subject_service.dart';

class WrongBookController extends GetxController {
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

  String get subjectId =>
      _currentSubjectService.currentSubject.value?.id.trim() ?? '';
  String get subjectName =>
      _currentSubjectService.currentSubject.value?.name.trim() ?? '';
  bool get hasSubject => subjectId.isNotEmpty;
  bool get hasFilter =>
      chapterId.value.trim().isNotEmpty ||
      questionCategoryId.value.trim().isNotEmpty;
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

  void startRetryPractice() {
    if (!hasFilter) {
      _showNotice(LocaleKeys.wrongBookRetryNeedFilter.tr);
      return;
    }
    if (filterCount > 1) {
      _showNotice(LocaleKeys.wrongBookRetrySingleFilterOnly.tr);
      return;
    }
    _showNotice(LocaleKeys.wrongBookRetryPlanned.tr);
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
