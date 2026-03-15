import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:zhisuo_flutter/data/models/question_bank/asset_models.dart';
import 'package:zhisuo_flutter/data/models/question_bank/qa_thread_models.dart';
import 'package:zhisuo_flutter/data/repositories/question_bank/qa_thread_repository.dart';
import 'package:zhisuo_flutter/i18n/locale_keys.dart';
import 'package:zhisuo_flutter/pages/qa_threads/qa_threads_controller.dart';

import '../../helpers/get_test_helper.dart';

void main() {
  group('QaThreadsController', () {
    tearDown(disposeGetTest);

    test('refresh without subject returns missing subject error', () async {
      configureGetTest();
      final controller = QaThreadsController(
        _FakeQaThreadRepository(),
        FakeAppSessionService(),
        FakeCurrentSubjectService(),
      );

      controller.onInit();
      await pumpController();

      expect(controller.errorText.value, LocaleKeys.qaThreadsNeedSubject.tr);
      expect(controller.items, isEmpty);
      controller.onClose();
    });

    test('changeStatus forwards filter to repository', () async {
      configureGetTest();
      final repository = _FakeQaThreadRepository();
      final controller = QaThreadsController(
        repository,
        FakeAppSessionService(),
        FakeCurrentSubjectService(subject: buildSubject()),
      );

      controller.onInit();
      await pumpController();

      await controller.changeStatus('closed');
      await pumpController();

      expect(controller.status.value, 'closed');
      expect(repository.lastStatus, 'closed');
      expect(controller.items.single.status, 'closed');
      controller.onClose();
    });
  });
}

class _FakeQaThreadRepository implements QaThreadRepository {
  String lastStatus = '';

  @override
  Future<QaThreadData> createQaThread({
    required String userId,
    required String subjectId,
    required String questionId,
    String sessionId = '',
    required String title,
    required String content,
  }) async {
    return QaThreadData(
      id: 'thread-created',
      userId: userId,
      subjectId: subjectId,
      questionId: questionId,
      sessionId: sessionId,
      title: title,
      content: content,
      status: 'open',
      closeRemark: '',
      lastRepliedAt: null,
      createdAt: DateTime(2026, 3, 15, 12),
      updatedAt: DateTime(2026, 3, 15, 12),
      replies: const [],
    );
  }

  @override
  Future<AssetPageResult<QaThreadData>> fetchQaThreads({
    required String userId,
    required String subjectId,
    String questionId = '',
    String status = '',
    int page = 1,
    int pageSize = 20,
  }) async {
    lastStatus = status;
    return AssetPageResult(
      items: [
        QaThreadData(
          id: 'thread-1',
          userId: userId,
          subjectId: subjectId,
          questionId: 'question-1',
          sessionId: 'session-1',
          title: '第一章第 3 题解析不理解',
          content: '为什么这里不能选 B？',
          status: status.isEmpty ? 'open' : status,
          closeRemark: '',
          lastRepliedAt: DateTime(2026, 3, 15, 11),
          createdAt: DateTime(2026, 3, 15, 10),
          updatedAt: DateTime(2026, 3, 15, 11),
          replies: const [],
        ),
      ],
      totalSize: 1,
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<QaThreadData> fetchQaThreadDetail({
    required String userId,
    required String threadId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<QaReplyData> replyQaThread({
    required String userId,
    required String threadId,
    required String content,
  }) {
    throw UnimplementedError();
  }
}
