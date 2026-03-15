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
  final updatingNoteId = ''.obs;
  final deletingNoteId = ''.obs;
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

    try {
      final formData = await _openNoteDialog();
      if (formData == null) {
        return;
      }

      if (formData.questionId.isEmpty || formData.content.isEmpty) {
        _showNotice(LocaleKeys.practiceNotesCreateInvalid.tr);
        return;
      }

      isCreating.value = true;
      final note = await _repository.createPracticeNote(
        userId: _appSessionService.userId,
        subjectId: subjectId,
        questionId: formData.questionId,
        sessionId: formData.sessionId,
        content: formData.content,
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
    }
  }

  /// 打开编辑弹窗，允许用户仅修改笔记正文，避免误改关联题目上下文。
  Future<void> openEditDialog(PracticeNoteAssetItem item) async {
    final noteId = item.id.trim();
    if (noteId.isEmpty || updatingNoteId.value == noteId) {
      return;
    }

    try {
      final formData = await _openNoteDialog(
        title: LocaleKeys.practiceNotesEditTitle.tr,
        confirmText: LocaleKeys.practiceNotesEditConfirm.tr,
        initialQuestionId: item.questionId,
        initialSessionId: item.sessionId,
        initialContent: item.content,
        lockIdentityFields: true,
      );
      if (formData == null) {
        return;
      }
      await updateNote(item, formData.content);
    } catch (e, stackTrace) {
      Logger.e(
        'PracticeNotesController.openEditDialog failed',
        error: e,
        stackTrace: stackTrace,
      );
      _showNotice(LocaleKeys.practiceNotesEditFailed.tr);
    }
  }

  /// 更新单条笔记并就地替换列表项，避免整页刷新导致用户上下文丢失。
  Future<void> updateNote(
    PracticeNoteAssetItem item,
    String content,
  ) async {
    final noteId = item.id.trim();
    final resolvedContent = content.trim();
    if (noteId.isEmpty || updatingNoteId.value == noteId) {
      return;
    }
    if (resolvedContent.isEmpty) {
      _showNotice(LocaleKeys.practiceNotesEditInvalid.tr);
      return;
    }

    try {
      updatingNoteId.value = noteId;
      final updated = await _repository.updatePracticeNote(
        userId: _appSessionService.userId,
        subjectId: subjectId,
        noteId: noteId,
        content: resolvedContent,
      );
      final index = items.indexWhere((element) => element.id.trim() == noteId);
      if (index >= 0) {
        items[index] = updated;
      }
      _showNotice(LocaleKeys.practiceNotesEditSuccess.tr);
    } catch (e, stackTrace) {
      Logger.e(
        'PracticeNotesController.updateNote failed',
        error: e,
        stackTrace: stackTrace,
      );
      _showNotice(LocaleKeys.practiceNotesEditFailed.tr);
    } finally {
      updatingNoteId.value = '';
    }
  }

  /// 删除前二次确认，避免误触直接把笔记从资产列表移除。
  Future<void> confirmDeleteNote(PracticeNoteAssetItem item) async {
    final noteId = item.id.trim();
    if (noteId.isEmpty || deletingNoteId.value == noteId) {
      return;
    }

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text(LocaleKeys.practiceNotesDeleteTitle.tr),
        content: Text(LocaleKeys.practiceNotesDeleteMessage.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(LocaleKeys.practiceNotesCreateCancel.tr),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: Text(LocaleKeys.practiceNotesDeleteConfirm.tr),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }
    await deleteNote(item);
  }

  /// 删除成功后直接从当前列表移除，并同步维护总数，减少一次不必要的 reload。
  Future<void> deleteNote(PracticeNoteAssetItem item) async {
    final noteId = item.id.trim();
    if (noteId.isEmpty || deletingNoteId.value == noteId) {
      return;
    }

    try {
      deletingNoteId.value = noteId;
      await _repository.deletePracticeNote(
        userId: _appSessionService.userId,
        subjectId: subjectId,
        noteId: noteId,
      );
      items.removeWhere((element) => element.id.trim() == noteId);
      if (totalSize.value > 0) {
        totalSize.value -= 1;
      }
      _showNotice(LocaleKeys.practiceNotesDeleteSuccess.tr);
    } catch (e, stackTrace) {
      Logger.e(
        'PracticeNotesController.deleteNote failed',
        error: e,
        stackTrace: stackTrace,
      );
      _showNotice(LocaleKeys.practiceNotesDeleteFailed.tr);
    } finally {
      deletingNoteId.value = '';
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
    // 测试或无 UI 容器场景下直接跳过提示，避免 overlay 不存在导致单测失败。
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

  /// 统一打开笔记表单弹窗，复用创建和编辑的输入结构，避免两处字段规则漂移。
  Future<_PracticeNoteFormData?> _openNoteDialog({
    String? title,
    String? confirmText,
    String initialQuestionId = '',
    String initialSessionId = '',
    String initialContent = '',
    bool lockIdentityFields = false,
  }) async {
    final questionController = TextEditingController(text: initialQuestionId);
    final sessionController = TextEditingController(text: initialSessionId);
    final contentController = TextEditingController(text: initialContent);

    try {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: Text(title ?? LocaleKeys.practiceNotesCreateTitle.tr),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: questionController,
                  enabled: !lockIdentityFields,
                  decoration: InputDecoration(
                    labelText: LocaleKeys.practiceNotesCreateQuestionId.tr,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: sessionController,
                  enabled: !lockIdentityFields,
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
              child:
                  Text(confirmText ?? LocaleKeys.practiceNotesCreateConfirm.tr),
            ),
          ],
        ),
      );

      if (confirmed != true) {
        return null;
      }
      return _PracticeNoteFormData(
        questionId: questionController.text.trim(),
        sessionId: sessionController.text.trim(),
        content: contentController.text.trim(),
      );
    } finally {
      questionController.dispose();
      sessionController.dispose();
      contentController.dispose();
    }
  }
}

class _PracticeNoteFormData {
  const _PracticeNoteFormData({
    required this.questionId,
    required this.sessionId,
    required this.content,
  });

  final String questionId;
  final String sessionId;
  final String content;
}
