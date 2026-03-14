import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:zhisuo_flutter/data/models/question_bank/question_bank_dashboard_models.dart';
import 'package:zhisuo_flutter/data/repositories/question_bank/question_bank_dashboard_repository.dart';
import 'package:zhisuo_flutter/data/models/subject/subject_models.dart';
import 'package:zhisuo_flutter/i18n/locale_keys.dart';
import 'package:zhisuo_flutter/pages/practice_unit_list/practice_unit_list_controller.dart';

import '../../helpers/get_test_helper.dart';

void main() {
  group('PracticeUnitListController', () {
    tearDown(disposeGetTest);

    test('refresh without subject returns missing subject error', () async {
      configureGetTest(
        arguments: const {
          'categoryCode': 'chapter',
          'categoryName': '章节练习',
        },
      );
      final controller = PracticeUnitListController(
        _FakePracticeUnitListRepository(),
        FakeAppSessionService(),
        FakeCurrentSubjectService(),
      );

      controller.onInit();
      await pumpController();

      expect(
        controller.errorText.value,
        LocaleKeys.practiceUnitListNeedSubject.tr,
      );
      expect(controller.items, isEmpty);
      controller.onClose();
    });

    test('refresh loads category meta and exposes disabled category state',
        () async {
      configureGetTest(
        arguments: const {
          'categoryCode': 'chapter',
          'categoryName': '章节练习',
        },
      );
      final controller = PracticeUnitListController(
        _FakePracticeUnitListRepository(),
        FakeAppSessionService(),
        FakeCurrentSubjectService(subject: buildSubject()),
      );

      controller.onInit();
      await pumpController();

      expect(controller.pageTitle, '章节练习');
      expect(controller.items, hasLength(1));
      expect(controller.totalSize.value, 1);
      expect(controller.isCategoryDisabled, isTrue);
      expect(controller.categoryDisabledReason, '当前分类维护中');
      expect(controller.items.single.unitId, 'chapter-1');
      controller.onClose();
    });
  });
}

class _FakePracticeUnitListRepository
    implements QuestionBankDashboardRepository {
  @override
  QuestionBankDashboardData buildFallback({
    SubjectItem? currentSubject,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<QuestionBankDashboardData> fetchDashboard({
    required String userId,
    required String subjectId,
    required String platform,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<PracticeCatalogData> fetchPracticeCatalog({
    required String userId,
    required String subjectId,
    required String platform,
  }) async {
    return const PracticeCatalogData(
      categories: [
        PracticeCategoryCardData(
          categoryCode: 'chapter',
          categoryName: '章节练习',
          iconKey: 'chapter',
          enabled: false,
          disabledReason: '当前分类维护中',
          sort: 10,
          unitCount: 1,
          completedUnitCount: 0,
          averageCorrectRate: 0,
          previewUnits: [],
        ),
      ],
      updatedAt: null,
    );
  }

  @override
  Future<PracticeUnitListPageData> fetchPracticeUnitList({
    required String userId,
    required String subjectId,
    required String categoryCode,
    String keyword = '',
    String status = '',
    int page = 1,
    int pageSize = 20,
  }) async {
    return const PracticeUnitListPageData(
      items: [
        PracticeUnitPreviewData(
          unitId: 'chapter-1',
          categoryCode: 'chapter',
          refType: 'chapter',
          refId: 'chapter-1',
          title: '第一章',
          subtitle: '基础入门',
          status: 'enabled',
          questionCount: 20,
          completed: false,
          progressStatus: 'not_started',
          doneCount: 0,
          correctRate: 0,
          lastPracticedAt: null,
          sort: 10,
          extJson: '{}',
        ),
      ],
      totalSize: 1,
      page: 1,
      pageSize: 20,
    );
  }
}
