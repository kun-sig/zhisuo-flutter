import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:zhisuo_flutter/data/repositories/question_bank/practice_asset_repository.dart';
import 'package:zhisuo_flutter/i18n/locale_keys.dart';
import 'package:zhisuo_flutter/pages/wrong_book/wrong_book_controller.dart';

import '../../helpers/get_test_helper.dart';

void main() {
  group('WrongBookController', () {
    tearDown(disposeGetTest);

    test('chapter filter resolves to wrong-question practice target', () {
      configureGetTest();
      final controller = WrongBookController(
        _FakePracticeAssetRepository(),
        FakeAppSessionService(),
        FakeCurrentSubjectService(subject: buildSubject()),
      );

      controller.chapterId.value = 'chapter-1';

      expect(controller.resolveRetryPracticeBlockedMessage(), isNull);
      final target = controller.resolveRetryPracticeTarget();
      expect(target, isNotNull);
      expect(target?.categoryCode, 'wrong_question_practice');
      expect(target?.unitId, 'chapter-1');
      expect(controller.isRetryPracticeReady, isTrue);
      expect(
        controller.retryPracticeStatusText,
        LocaleKeys.wrongBookRetryChapterReady.tr,
      );
    });

    test('question category filter is blocked until backend exposes unit ids',
        () {
      configureGetTest();
      final controller = WrongBookController(
        _FakePracticeAssetRepository(),
        FakeAppSessionService(),
        FakeCurrentSubjectService(subject: buildSubject()),
      );

      controller.questionCategoryId.value = 'single_choice';

      expect(
        controller.resolveRetryPracticeBlockedMessage(),
        LocaleKeys.wrongBookRetryQuestionCategoryUnsupported.tr,
      );
      expect(controller.resolveRetryPracticeTarget(), isNull);
      expect(controller.isRetryPracticeReady, isFalse);
      expect(
        controller.retryPracticeStatusText,
        LocaleKeys.wrongBookRetryQuestionCategoryUnsupported.tr,
      );
    });

    test('multiple filters keep single-filter guard', () {
      configureGetTest();
      final controller = WrongBookController(
        _FakePracticeAssetRepository(),
        FakeAppSessionService(),
        FakeCurrentSubjectService(subject: buildSubject()),
      );

      controller.chapterId.value = 'chapter-1';
      controller.questionCategoryId.value = 'single_choice';

      expect(
        controller.resolveRetryPracticeBlockedMessage(),
        LocaleKeys.wrongBookRetrySingleFilterOnly.tr,
      );
      expect(controller.isRetryPracticeReady, isFalse);
      expect(
        controller.retryPracticeStatusText,
        LocaleKeys.wrongBookRetrySingleFilterOnly.tr,
      );
    });
  });
}

class _FakePracticeAssetRepository extends Fake
    implements PracticeAssetRepository {}
