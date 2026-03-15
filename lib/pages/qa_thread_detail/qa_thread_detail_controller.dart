import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/question_bank/qa_thread_models.dart';
import '../../data/repositories/question_bank/qa_thread_repository.dart';
import '../../i18n/locale_keys.dart';
import '../../logger/logger.dart';
import '../../services/api_exception.dart';
import '../../services/app_session_service.dart';

class QaThreadDetailController extends GetxController {
  static const bool _autoReplyQaThread = bool.fromEnvironment(
    'AUTO_REPLY_QA_THREAD',
    defaultValue: false,
  );
  static const String _autoQaReplyContent = String.fromEnvironment(
    'AUTO_QA_REPLY_CONTENT',
    defaultValue: '这是一条由 Flutter 自动联调追加的 QA 回复',
  );

  QaThreadDetailController(
    this._repository,
    this._appSessionService,
  );

  final QaThreadRepository _repository;
  final AppSessionService _appSessionService;

  final thread = Rxn<QaThreadData>();
  final isReplySubmitting = false.obs;
  final isLoading = false.obs;
  final errorText = ''.obs;

  QaThreadData? get data => thread.value;
  String _threadId = '';
  bool _hasAutoReplied = false;

  /// 页面标题优先展示线程标题，缺失时退回通用标题。
  String get pageTitle {
    final value = data?.title.trim() ?? '';
    if (value.isNotEmpty) {
      return value;
    }
    return LocaleKeys.qaThreadDetailTitle.tr;
  }

  @override
  void onInit() {
    super.onInit();
    _readArguments();
    _loadThreadDetail();
  }

  /// 回复入口通过弹窗收集内容，避免当前阶段额外引入独立编辑页。
  Future<void> openReplyDialog() async {
    final current = data;
    if (current == null || current.isClosed || isReplySubmitting.value) {
      return;
    }
    final contentController = TextEditingController();
    try {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: Text(LocaleKeys.qaThreadDetailReplyTitle.tr),
          content: TextField(
            controller: contentController,
            minLines: 4,
            maxLines: 8,
            decoration: InputDecoration(
              labelText: LocaleKeys.qaThreadDetailReplyInput.tr,
              hintText: LocaleKeys.qaThreadDetailReplyHint.tr,
              alignLabelWithHint: true,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text(LocaleKeys.qaThreadDetailReplyCancel.tr),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              child: Text(LocaleKeys.qaThreadDetailReplyConfirm.tr),
            ),
          ],
        ),
      );
      if (confirmed != true) {
        return;
      }
      await replyThread(contentController.text);
    } finally {
      contentController.dispose();
    }
  }

  /// 回复成功后只增量追加到当前线程 replies，确保详情页上下文不被整页刷新打断。
  Future<void> replyThread(String content) async {
    final current = data;
    final resolvedContent = content.trim();
    if (current == null) {
      errorText.value = LocaleKeys.qaThreadDetailMissingThread.tr;
      return;
    }
    if (current.isClosed) {
      _showNotice(LocaleKeys.qaThreadDetailClosedNotice.tr);
      return;
    }
    if (resolvedContent.isEmpty) {
      _showNotice(LocaleKeys.qaThreadDetailReplyInvalid.tr);
      return;
    }
    if (isReplySubmitting.value) {
      return;
    }

    isReplySubmitting.value = true;
    errorText.value = '';
    try {
      final reply = await _repository.replyQaThread(
        userId: _appSessionService.userId,
        threadId: current.id,
        content: resolvedContent,
      );
      thread.value = current.copyWith(
        lastRepliedAt: reply.createdAt ?? DateTime.now(),
        updatedAt: reply.createdAt ?? DateTime.now(),
        replies: [...current.replies, reply],
      );
      _showNotice(LocaleKeys.qaThreadDetailReplySuccess.tr);
    } catch (e, stackTrace) {
      Logger.e(
        'QaThreadDetailController.replyThread failed',
        error: e,
        stackTrace: stackTrace,
      );
      errorText.value = _resolveReplyError(e);
      _showNotice(errorText.value);
    } finally {
      isReplySubmitting.value = false;
    }
  }

  /// 兼容 Get.arguments 直接透传对象或 map 的两种进入方式。
  void _readArguments() {
    final args = Get.arguments;
    if (args is Map) {
      _threadId = (args['threadId'] ?? '').toString().trim();
      final raw = args['thread'];
      if (raw is QaThreadData) {
        thread.value = raw;
      }
      if (raw is Map<String, dynamic>) {
        thread.value = QaThreadData.fromJson(raw);
      }
      if (raw is Map) {
        thread.value = QaThreadData.fromJson(
          raw.map((key, value) => MapEntry(key.toString(), value)),
        );
      }
    }
  }

  /// 详情页优先读取后端最新回复列表，避免只依赖列表页透传造成数据过期。
  Future<void> _loadThreadDetail() async {
    if (_threadId.isEmpty) {
      final current = data;
      _threadId = current?.id.trim() ?? '';
    }
    if (_threadId.isEmpty) {
      errorText.value = LocaleKeys.qaThreadDetailMissingThread.tr;
      return;
    }
    isLoading.value = true;
    try {
      thread.value = await _repository.fetchQaThreadDetail(
        userId: _appSessionService.userId,
        threadId: _threadId,
      );
      errorText.value = '';
    } catch (e, stackTrace) {
      Logger.e(
        'QaThreadDetailController._loadThreadDetail failed',
        error: e,
        stackTrace: stackTrace,
      );
      if (data == null) {
        errorText.value = _resolveDetailError(e);
      }
    } finally {
      isLoading.value = false;
      _maybeAutoReply();
    }
  }

  String _resolveReplyError(Object error) {
    if (error is ApiException) {
      if (error.httpStatus == 404 || error.code == 404) {
        return LocaleKeys.qaThreadDetailReplyUnavailable.tr;
      }
    }
    return LocaleKeys.qaThreadDetailReplyFailed.tr;
  }

  String _resolveDetailError(Object error) {
    if (error is ApiException) {
      if (error.httpStatus == 404 || error.code == 404) {
        return LocaleKeys.qaThreadDetailMissingThread.tr;
      }
    }
    return LocaleKeys.qaThreadsLoadFailed.tr;
  }

  /// 仅在联调开关开启时自动回复当前线程，并在回复后回拉详情校验后端最新状态。
  void _maybeAutoReply() {
    if (!_autoReplyQaThread || _hasAutoReplied || isReplySubmitting.value) {
      return;
    }
    final current = data;
    if (current == null || current.isClosed) {
      return;
    }
    _hasAutoReplied = true;
    Future<void>(() async {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await replyThread(_autoQaReplyContent);
      await _loadThreadDetail();
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
