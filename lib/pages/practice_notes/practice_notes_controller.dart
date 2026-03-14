import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/question_bank/asset_models.dart';
import '../../data/models/subject/subject_models.dart';
import '../../data/repositories/question_bank/practice_asset_repository.dart';
import '../../i18n/locale_keys.dart';
import '../../logger/logger.dart';
import '../../services/app_session_service.dart';
import '../../services/current_subject_service.dart';

class PracticeNotesController extends GetxController {
  PracticeNotesController(
    this._repository,
    this._appSessionService,
    this._currentSubjectService,
  );

  static const int _pageSize = 20;

  final PracticeAssetRepository _repository;
  final AppSessionService _appSessionService;
  final CurrentSubjectService _currentSubjectService;

  final items = <PracticeNoteAssetItem>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final isCreating = false.obs;
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
      errorText.value = LocaleKeys.practiceNotesNeedSubject.tr;
      return;
    }

    isLoading.value = true;
    errorText.value = '';

    try {
      final result = await _repository.fetchPracticeNotes(
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
        'PracticeNotesController.refresh failed',
        error: e,
        stackTrace: stackTrace,
      );
      errorText.value = LocaleKeys.practiceNotesLoadFailed.tr;
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
      final result = await _repository.fetchPracticeNotes(
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
        'PracticeNotesController.loadMore failed',
        error: e,
        stackTrace: stackTrace,
      );
      errorText.value = LocaleKeys.practiceNotesLoadFailed.tr;
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> openCreateDialog() async {
    if (!hasSubject || isCreating.value) {
      return;
    }

    final questionController = TextEditingController();
    final sessionController = TextEditingController();
    final contentController = TextEditingController();

    try {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: Text(LocaleKeys.practiceNotesCreateTitle.tr),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: questionController,
                  decoration: InputDecoration(
                    labelText: LocaleKeys.practiceNotesCreateQuestionId.tr,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: sessionController,
                  decoration: InputDecoration(
                    labelText: LocaleKeys.practiceNotesCreateSessionId.tr,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  minLines: 4,
                  maxLines: 8,
                  decoration: InputDecoration(
                    labelText: LocaleKeys.practiceNotesCreateContent.tr,
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text(LocaleKeys.practiceNotesCreateCancel.tr),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              child: Text(LocaleKeys.practiceNotesCreateConfirm.tr),
            ),
          ],
        ),
      );

      if (confirmed != true) {
        return;
      }

      final questionId = questionController.text.trim();
      final sessionId = sessionController.text.trim();
      final content = contentController.text.trim();

      if (questionId.isEmpty || content.isEmpty) {
        _showNotice(LocaleKeys.practiceNotesCreateInvalid.tr);
        return;
      }

      isCreating.value = true;
      final note = await _repository.createPracticeNote(
        userId: _appSessionService.userId,
        subjectId: subjectId,
        questionId: questionId,
        sessionId: sessionId,
        content: content,
      );
      items.insert(0, note);
      totalSize.value += 1;
      _showNotice(LocaleKeys.practiceNotesCreateSuccess.tr);
    } catch (e, stackTrace) {
      Logger.e(
        'PracticeNotesController.openCreateDialog failed',
        error: e,
        stackTrace: stackTrace,
      );
      _showNotice(LocaleKeys.practiceNotesCreateFailed.tr);
    } finally {
      isCreating.value = false;
      questionController.dispose();
      sessionController.dispose();
      contentController.dispose();
    }
  }

  String resolveStatusText(String status) {
    switch (status.trim().toLowerCase()) {
      case 'pending':
        return LocaleKeys.practiceNotesStatusPending.tr;
      case 'approved':
        return LocaleKeys.practiceNotesStatusApproved.tr;
      case 'rejected':
        return LocaleKeys.practiceNotesStatusRejected.tr;
      case '':
        return LocaleKeys.practiceNotesStatusUnknown.tr;
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
