import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/question_bank/qa_thread_models.dart';
import '../../data/models/subject/subject_models.dart';
import '../../data/repositories/question_bank/qa_thread_repository.dart';
import '../../i18n/locale_keys.dart';
import '../../logger/logger.dart';
import '../../routes/app_navigator.dart';
import '../../services/api_exception.dart';
import '../../services/app_session_service.dart';
import '../../services/current_subject_service.dart';

class QaThreadStatusOption {
  const QaThreadStatusOption({
    required this.value,
    required this.labelKey,
  });

  final String value;
  final String labelKey;
}

class QaThreadsController extends GetxController {
  static const bool _autoCreateQaThread = bool.fromEnvironment(
    'AUTO_CREATE_QA_THREAD',
    defaultValue: false,
  );
  static const bool _autoOpenFirstQaThread = bool.fromEnvironment(
    'AUTO_OPEN_FIRST_QA_THREAD',
    defaultValue: false,
  );
  static const String _autoQaQuestionId = String.fromEnvironment(
    'AUTO_QA_QUESTION_ID',
    defaultValue: 'qa-question-auto',
  );
  static const String _autoQaSessionId = String.fromEnvironment(
    'AUTO_QA_SESSION_ID',
    defaultValue: 'qa-session-auto',
  );
  static const String _autoQaTitle = String.fromEnvironment(
    'AUTO_QA_TITLE',
    defaultValue: 'QA 自动联调线程',
  );
  static const String _autoQaContent = String.fromEnvironment(
    'AUTO_QA_CONTENT',
    defaultValue: '这是一条由 Flutter 自动联调创建的 QA 线程',
  );

  QaThreadsController(
    this._repository,
    this._appSessionService,
    this._currentSubjectService,
  );

  static const int _pageSize = 20;

  final QaThreadRepository _repository;
  final AppSessionService _appSessionService;
  final CurrentSubjectService _currentSubjectService;

  final items = <QaThreadData>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final errorText = ''.obs;
  final hasMore = false.obs;
  final totalSize = 0.obs;
  final status = ''.obs;
  final scrollController = ScrollController();

  late final Worker _subjectWorker;

  int _page = 1;
  bool _isAutoFlowRunning = false;
  bool _hasAutoCreatedThread = false;
  bool _hasAutoOpenedThread = false;

  String get subjectId =>
      _currentSubjectService.currentSubject.value?.id.trim() ?? '';
  String get subjectName =>
      _currentSubjectService.currentSubject.value?.name.trim() ?? '';
  bool get hasSubject => subjectId.isNotEmpty;
  bool get hasFilter => status.value.trim().isNotEmpty;

  List<QaThreadStatusOption> get statusOptions => const [
        QaThreadStatusOption(
          value: '',
          labelKey: LocaleKeys.qaThreadsFilterAll,
        ),
        QaThreadStatusOption(
          value: 'open',
          labelKey: LocaleKeys.qaThreadsStatusOpen,
        ),
        QaThreadStatusOption(
          value: 'closed',
          labelKey: LocaleKeys.qaThreadsStatusClosed,
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

  /// 拉取问答线程列表，统一维护首屏 loading、空态和错误态。
  @override
  Future<void> refresh() async {
    if (!hasSubject) {
      items.clear();
      totalSize.value = 0;
      hasMore.value = false;
      errorText.value = LocaleKeys.qaThreadsNeedSubject.tr;
      return;
    }

    isLoading.value = true;
    errorText.value = '';

    try {
      final result = await _repository.fetchQaThreads(
        userId: _appSessionService.userId,
        subjectId: subjectId,
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
        'QaThreadsController.refresh failed',
        error: e,
        stackTrace: stackTrace,
      );
      errorText.value = _resolveLoadError(e);
    } finally {
      isLoading.value = false;
      _maybeRunAutoFlow();
    }
  }

  /// 继续分页拉取问答线程，保持与其他资产列表一致的滚动体验。
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
      final result = await _repository.fetchQaThreads(
        userId: _appSessionService.userId,
        subjectId: subjectId,
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
        'QaThreadsController.loadMore failed',
        error: e,
        stackTrace: stackTrace,
      );
      errorText.value = _resolveLoadError(e);
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// 切换问答状态筛选后立即刷新，减少额外确认步骤。
  Future<void> changeStatus(String value) async {
    final resolvedValue = value.trim();
    if (status.value == resolvedValue) {
      return;
    }
    status.value = resolvedValue;
    await refresh();
  }

  /// 打开线程详情页时先透传当前线程，再由详情页补拉最新数据。
  void openThread(QaThreadData thread) {
    AppNavigator.startQaThreadDetailPage(
      threadId: thread.id,
      thread: thread,
    );
  }

  /// 创建问答线程时先收集接口最小必填字段，保证用户态提问链路可直接联调。
  Future<void> openCreateThreadDialog() async {
    if (!hasSubject) {
      _showNotice(LocaleKeys.qaThreadsNeedSubject.tr);
      return;
    }
    final questionController = TextEditingController();
    final sessionController = TextEditingController();
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    try {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: Text(LocaleKeys.qaThreadsCreateTitle.tr),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: questionController,
                  decoration: InputDecoration(
                    labelText: LocaleKeys.qaThreadsCreateQuestionId.tr,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: sessionController,
                  decoration: InputDecoration(
                    labelText: LocaleKeys.qaThreadsCreateSessionId.tr,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: LocaleKeys.qaThreadsCreateThreadTitle.tr,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  minLines: 4,
                  maxLines: 8,
                  decoration: InputDecoration(
                    labelText: LocaleKeys.qaThreadsCreateContent.tr,
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text(LocaleKeys.qaThreadsCreateCancel.tr),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              child: Text(LocaleKeys.qaThreadsCreateConfirm.tr),
            ),
          ],
        ),
      );
      if (confirmed != true) {
        return;
      }
      await createThread(
        questionId: questionController.text,
        sessionId: sessionController.text,
        title: titleController.text,
        content: contentController.text,
      );
    } finally {
      questionController.dispose();
      sessionController.dispose();
      titleController.dispose();
      contentController.dispose();
    }
  }

  /// 创建成功后把新线程插入列表头部，并直接进入详情页继续查看回复。
  Future<void> createThread({
    required String questionId,
    required String sessionId,
    required String title,
    required String content,
    bool openDetail = true,
  }) async {
    final resolvedQuestionId = questionId.trim();
    final resolvedContent = content.trim();
    if (resolvedQuestionId.isEmpty || resolvedContent.isEmpty) {
      _showNotice(LocaleKeys.qaThreadsCreateInvalid.tr);
      return;
    }
    try {
      final created = await _repository.createQaThread(
        userId: _appSessionService.userId,
        subjectId: subjectId,
        questionId: resolvedQuestionId,
        sessionId: sessionId.trim(),
        title: title.trim(),
        content: resolvedContent,
      );
      items.insert(0, created);
      totalSize.value += 1;
      _showNotice(LocaleKeys.qaThreadsCreateSuccess.tr);
      if (openDetail) {
        _hasAutoOpenedThread = true;
        AppNavigator.startQaThreadDetailPage(
          threadId: created.id,
          thread: created,
        );
      }
    } catch (e, stackTrace) {
      Logger.e(
        'QaThreadsController.createThread failed',
        error: e,
        stackTrace: stackTrace,
      );
      _showNotice(_resolveCreateError(e));
    }
  }

  /// 统一把后端线程状态转换为用户可读文案。
  String resolveStatusText(String threadStatus) {
    switch (threadStatus.trim().toLowerCase()) {
      case 'open':
        return LocaleKeys.qaThreadsStatusOpen.tr;
      case 'closed':
        return LocaleKeys.qaThreadsStatusClosed.tr;
      default:
        return LocaleKeys.qaThreadsStatusUnknown.tr;
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

  /// 把“服务不可用”与普通加载失败区分显示，避免联调阶段误判为前端渲染问题。
  String _resolveLoadError(Object error) {
    if (error is ApiException) {
      if (error.httpStatus == 404 || error.code == 404) {
        return LocaleKeys.qaThreadsUnavailable.tr;
      }
    }
    return LocaleKeys.qaThreadsLoadFailed.tr;
  }

  String _resolveCreateError(Object error) {
    if (error is ApiException) {
      if (error.httpStatus == 404 || error.code == 404) {
        return LocaleKeys.qaThreadsCreateUnavailable.tr;
      }
    }
    return LocaleKeys.qaThreadsCreateFailed.tr;
  }

  /// 仅在显式联调开关开启时自动创建或自动进入首条线程，避免每次验证都依赖手工点击。
  void _maybeRunAutoFlow() {
    if ((!_autoCreateQaThread && !_autoOpenFirstQaThread) ||
        _isAutoFlowRunning ||
        !hasSubject) {
      return;
    }
    _isAutoFlowRunning = true;
    Future<void>(() async {
      try {
        if (_autoCreateQaThread && !_hasAutoCreatedThread) {
          _hasAutoCreatedThread = true;
          await Future<void>.delayed(const Duration(milliseconds: 300));
          await createThread(
            questionId: _autoQaQuestionId,
            sessionId: _autoQaSessionId,
            title: _autoQaTitle,
            content: _autoQaContent,
            openDetail: _autoOpenFirstQaThread,
          );
          return;
        }
        if (_autoOpenFirstQaThread &&
            !_hasAutoOpenedThread &&
            items.isNotEmpty) {
          _hasAutoOpenedThread = true;
          await Future<void>.delayed(const Duration(milliseconds: 300));
          openThread(items.first);
        }
      } finally {
        _isAutoFlowRunning = false;
      }
    });
  }

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
