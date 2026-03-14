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

class PracticeHistoryController extends GetxController {
  PracticeHistoryController(
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
  final scrollController = ScrollController();

  late final Worker _subjectWorker;

  int _page = 1;

  String get subjectId =>
      _currentSubjectService.currentSubject.value?.id.trim() ?? '';
  String get subjectName =>
      _currentSubjectService.currentSubject.value?.name.trim() ?? '';
  bool get hasSubject => subjectId.isNotEmpty;

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

  @override
  Future<void> refresh() async {
    if (!hasSubject) {
      items.clear();
      totalSize.value = 0;
      hasMore.value = false;
      errorText.value = LocaleKeys.practiceHistoryNeedSubject.tr;
      return;
    }

    isLoading.value = true;
    errorText.value = '';

    try {
      final result = await _repository.fetchPracticeRecords(
        userId: _appSessionService.userId,
        subjectId: subjectId,
        page: 1,
        pageSize: _pageSize,
      );
      _page = 1;
      items.assignAll(result.items);
      totalSize.value = result.totalSize;
      hasMore.value = result.hasMore;
    } catch (e, stackTrace) {
      Logger.e(
        'PracticeHistoryController.refresh failed',
        error: e,
        stackTrace: stackTrace,
      );
      errorText.value = LocaleKeys.practiceHistoryLoadFailed.tr;
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
      final result = await _repository.fetchPracticeRecords(
        userId: _appSessionService.userId,
        subjectId: subjectId,
        page: nextPage,
        pageSize: _pageSize,
      );
      _page = nextPage;
      items.addAll(result.items);
      totalSize.value = result.totalSize;
      hasMore.value = result.hasMore;
    } catch (e, stackTrace) {
      Logger.e(
        'PracticeHistoryController.loadMore failed',
        error: e,
        stackTrace: stackTrace,
      );
      errorText.value = LocaleKeys.practiceHistoryLoadFailed.tr;
    } finally {
      isLoadingMore.value = false;
    }
  }

  void openReport(PracticeRecordAssetItem item) {
    final sessionId = item.sessionId.trim();
    if (sessionId.isEmpty) {
      Get.snackbar(
        LocaleKeys.commonNoticeTitle.tr,
        LocaleKeys.practiceHistoryMissingSession.tr,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
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
}
