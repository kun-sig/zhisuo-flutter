import 'package:flutter_test/flutter_test.dart';
import 'package:zhisuo_flutter/data/models/question_bank/asset_models.dart';
import 'package:zhisuo_flutter/data/models/question_bank/qa_thread_models.dart';
import 'package:zhisuo_flutter/data/repositories/question_bank/qa_thread_repository.dart';
import 'package:zhisuo_flutter/pages/qa_thread_detail/qa_thread_detail_controller.dart';

import '../../helpers/get_test_helper.dart';

void main() {
  group('QaThreadDetailController', () {
    tearDown(disposeGetTest);

    test('replyThread appends reply into current thread', () async {
      configureGetTest(arguments: {
        'thread': QaThreadData(
          id: 'thread-1',
          userId: 'demo-user',
          subjectId: 'subject-1',
          questionId: 'question-1',
          sessionId: 'session-1',
          title: '标题',
          content: '内容',
          status: 'open',
          closeRemark: '',
          lastRepliedAt: null,
          createdAt: DateTime(2026, 3, 15, 10),
          updatedAt: DateTime(2026, 3, 15, 10),
          replies: const [],
        ),
      });
      final repository = _FakeQaThreadDetailRepository();
      final controller = QaThreadDetailController(
        repository,
        FakeAppSessionService(),
      );

      controller.onInit();
      await pumpController();
      await controller.replyThread('这是补充说明');

      expect(repository.lastThreadId, 'thread-1');
      expect(controller.data?.replies, hasLength(1));
      expect(controller.data?.replies.single.content, '这是补充说明');
    });
  });
}

class _FakeQaThreadDetailRepository implements QaThreadRepository {
  String lastThreadId = '';

  @override
  Future<QaThreadData> createQaThread({
    required String userId,
    required String subjectId,
    required String questionId,
    String sessionId = '',
    required String title,
    required String content,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AssetPageResult<QaThreadData>> fetchQaThreads({
    required String userId,
    required String subjectId,
    String questionId = '',
    String status = '',
    int page = 1,
    int pageSize = 20,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<QaThreadData> fetchQaThreadDetail({
    required String userId,
    required String threadId,
  }) async {
    return QaThreadData(
      id: threadId,
      userId: userId,
      subjectId: 'subject-1',
      questionId: 'question-1',
      sessionId: 'session-1',
      title: '标题',
      content: '内容',
      status: 'open',
      closeRemark: '',
      lastRepliedAt: null,
      createdAt: DateTime(2026, 3, 15, 10),
      updatedAt: DateTime(2026, 3, 15, 10),
      replies: const [],
    );
  }

  @override
  Future<QaReplyData> replyQaThread({
    required String userId,
    required String threadId,
    required String content,
  }) async {
    lastThreadId = threadId;
    return QaReplyData(
      id: 'reply-1',
      threadId: threadId,
      authorRole: 'user',
      authorId: userId,
      content: content,
      createdAt: DateTime(2026, 3, 15, 12),
    );
  }
}
