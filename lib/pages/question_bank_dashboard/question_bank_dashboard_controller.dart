import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/question_bank/question_bank_dashboard_models.dart';
import '../../data/models/subject/subject_models.dart';
import '../../data/repositories/question_bank/question_bank_dashboard_repository.dart';
import '../../i18n/locale_keys.dart';
import '../../logger/logger.dart';
import '../../routes/app_navigator.dart';
import '../../services/app_session_service.dart';
import '../../services/current_subject_service.dart';

class QuestionBankDashboardController extends GetxController {
  QuestionBankDashboardController(
    this._repository,
    this._currentSubjectService,
    this._appSessionService,
  );

  final QuestionBankDashboardRepository _repository;
  final CurrentSubjectService _currentSubjectService;
  final AppSessionService _appSessionService;

  late final Rx<QuestionBankDashboardData> dashboard;
  final isLoading = false.obs;
  final errorText = ''.obs;

  late final Worker _subjectWorker;

  @override
  void onInit() {
    super.onInit();
    dashboard = _repository
        .buildFallback(
          currentSubject: _currentSubjectService.currentSubject.value,
        )
        .obs;
    _subjectWorker = ever<SubjectItem?>(
      _currentSubjectService.currentSubject,
      (_) {
        dashboard.value = _repository.buildFallback(
          currentSubject: _currentSubjectService.currentSubject.value,
        );
        unawaited(refreshDashboard(showLoading: false));
      },
    );
    refreshDashboard();
  }

  @override
  void onClose() {
    _subjectWorker.dispose();
    super.onClose();
  }

  String get subjectName {
    final remoteName = dashboard.value.currentSubject?.subjectName.trim() ?? '';
    if (remoteName.isNotEmpty) {
      return remoteName;
    }
    return _currentSubjectService.currentSubject.value?.name ?? '';
  }

  /// 判断当前是否已经选择科目，供页面区分“无科目灰态”和真实空态。
  bool get hasSubject =>
      _currentSubjectService.currentSubject.value?.id.trim().isNotEmpty == true;

  String get countdownText {
    final countdownDays = dashboard.value.examCountdown?.countdownDays;
    if (countdownDays == null || countdownDays < 0) {
      return '--';
    }
    return countdownDays.toString();
  }

  /// 继续练习优先使用后端显式返回的会话；缺失时退回最近有进度的单元聚合结果。
  ContinueSessionViewData? get continueSession {
    final remote = dashboard.value.continueSession;
    if (remote != null && remote.hasUnitContext) {
      return remote;
    }
    return _buildContinueSessionFromUnits();
  }

  Future<void> refreshDashboard({bool showLoading = true}) async {
    if (showLoading) {
      isLoading.value = true;
    }
    errorText.value = '';

    try {
      final data = await _repository.fetchDashboard(
        userId: _appSessionService.userId,
        subjectId: _currentSubjectService.currentSubject.value?.id ?? '',
        platform: _appSessionService.platform,
      );
      dashboard.value = data;
    } catch (e, stackTrace) {
      Logger.e(
        'QuestionBankDashboardController.refreshDashboard failed',
        error: e,
        stackTrace: stackTrace,
      );
      errorText.value = LocaleKeys.questionBankDashboardLoadFailed.tr;
      dashboard.value = _repository.buildFallback(
        currentSubject: _currentSubjectService.currentSubject.value,
      );
    } finally {
      if (showLoading) {
        isLoading.value = false;
      }
    }
  }

  void openSubjectSelector() {
    AppNavigator.startSubjectPage();
  }

  /// 一级分类点击后进入统一单元列表页。
  void onPracticeCategoryTap(PracticeCategoryCardData category) {
    if (!category.enabled) {
      _showNotice(
        category.disabledReason.trim().isNotEmpty
            ? category.disabledReason
            : LocaleKeys.questionBankDashboardNeedSubject.tr,
      );
      return;
    }
    final categoryCode = category.categoryCode.trim();
    if (categoryCode.isEmpty) {
      _showNotice(LocaleKeys.questionBankDashboardCategoryPlanned.tr);
      return;
    }
    AppNavigator.startPracticeUnitListPage(
      categoryCode: categoryCode,
      categoryName: category.categoryName,
    );
  }

  /// 二级单元点击后统一按 `categoryCode + unitId` 进入练习。
  void onPracticeUnitTap(PracticeUnitPreviewData unit) {
    if (!unit.isEnabled) {
      _showNotice(
        unit.disabledReason.trim().isNotEmpty
            ? unit.disabledReason
            : LocaleKeys.questionBankDashboardUnitDisabled.tr,
      );
      return;
    }
    final categoryCode = unit.categoryCode.trim();
    final unitId = unit.unitId.trim();
    if (categoryCode.isEmpty || unitId.isEmpty) {
      _showNotice(LocaleKeys.questionBankDashboardUnitPlanned.tr);
      return;
    }
    AppNavigator.startPracticeSessionPage(
      categoryCode: categoryCode,
      unitId: unitId,
      unitTitle: unit.title,
      continueIfExists: true,
    );
  }

  /// 继续练习统一按 `categoryCode + unitId` 进入，由会话启动接口决定恢复哪一个最近会话。
  void onContinueSessionTap() {
    final session = continueSession;
    if (session == null) {
      return;
    }
    if (!session.hasUnitContext) {
      _showNotice(LocaleKeys.practiceSessionMissingUnit.tr);
      return;
    }
    AppNavigator.startPracticeSessionPage(
      categoryCode: session.categoryCode,
      unitId: session.unitId,
      unitTitle: session.displayTitle,
      continueIfExists: true,
    );
  }

  void onAssetToolTap(AssetToolViewData tool) {
    if (!tool.enabled) {
      _showNotice(
        tool.disabledReason.trim().isNotEmpty
            ? tool.disabledReason
            : LocaleKeys.questionBankDashboardNeedSubject.tr,
      );
      return;
    }

    switch (tool.toolCode) {
      case 'wrong_questions':
        AppNavigator.startWrongBookPage();
        return;
      case 'practice_records':
        AppNavigator.startPracticeHistoryPage();
        return;
      case 'question_favorites':
        AppNavigator.startFavoritesPage();
        return;
      case 'practice_notes':
        AppNavigator.startPracticeNotesPage();
        return;
      default:
        _showNotice(
          '${tool.toolName} '
          '${LocaleKeys.questionBankDashboardPlannedSuffix.tr}',
        );
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

  /// 从首页单元预览中挑选最合适的继续练习目标，优先未完成且最近练习过的单元。
  ContinueSessionViewData? _buildContinueSessionFromUnits() {
    final units = dashboard.value.practiceUnitsPreview.isNotEmpty
        ? dashboard.value.practiceUnitsPreview
        : dashboard.value.practiceCategories
            .expand((category) => category.previewUnits)
            .toList();
    final candidates = units.where(_isRecoverableUnit).toList();
    if (candidates.isEmpty) {
      return null;
    }
    candidates.sort((a, b) {
      final priorityCompare =
          _continuePriority(b).compareTo(_continuePriority(a));
      if (priorityCompare != 0) {
        return priorityCompare;
      }
      final timeCompare = (b.lastPracticedAt?.millisecondsSinceEpoch ?? 0)
          .compareTo(a.lastPracticedAt?.millisecondsSinceEpoch ?? 0);
      if (timeCompare != 0) {
        return timeCompare;
      }
      return a.sort.compareTo(b.sort);
    });
    return ContinueSessionViewData.fromUnitPreview(candidates.first);
  }

  /// 仅把有真实练习痕迹的单元作为继续练习候选，避免“未开始”单元误占入口。
  bool _isRecoverableUnit(PracticeUnitPreviewData unit) {
    if (!unit.isEnabled) {
      return false;
    }
    if (unit.lastPracticedAt != null) {
      return true;
    }
    if (unit.doneCount > 0) {
      return true;
    }
    final status = unit.progressStatus.trim().toLowerCase();
    return status == 'in_progress' || unit.completed;
  }

  /// 继续练习排序优先级：未完成中的最近练习最高，其次是有历史记录的最近单元。
  int _continuePriority(PracticeUnitPreviewData unit) {
    final status = unit.progressStatus.trim().toLowerCase();
    if (status == 'in_progress') {
      return 3;
    }
    if (unit.doneCount > 0 || unit.lastPracticedAt != null) {
      return 2;
    }
    if (unit.completed) {
      return 1;
    }
    return 0;
  }
}
