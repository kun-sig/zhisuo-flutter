import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/question_bank/practice_session_models.dart';
import '../../data/repositories/question_bank/practice_session_repository.dart';
import '../../i18n/locale_keys.dart';
import '../../logger/logger.dart';
import '../../routes/app_navigator.dart';
import '../../services/app_session_service.dart';
import '../../services/current_subject_service.dart';

class PracticeSessionController extends GetxController {
  PracticeSessionController(
    this._repository,
    this._appSessionService,
    this._currentSubjectService,
  );

  final PracticeSessionRepository _repository;
  final AppSessionService _appSessionService;
  final CurrentSubjectService _currentSubjectService;

  final isPageLoading = false.obs;
  final isSubmitLoading = false.obs;
  final isFinishLoading = false.obs;
  final errorText = ''.obs;
  final sessionData = Rxn<PracticeSessionData>();
  final currentIndex = 0.obs;

  String _sessionId = '';
  String _categoryCode = '';
  String _categoryName = '';
  String _unitId = '';
  String _unitTitle = '';
  bool _continueIfExists = true;
  int _questionCount = 20;
  DateTime _questionShownAt = DateTime.now();

  PracticeSessionData? get data => sessionData.value;
  PracticeQuestionData? get currentQuestion => data?.currentQuestion;
  PracticeSessionUnitProgressData? get unitProgress => data?.unitProgress;

  /// 页面标题优先展示路由传入的单元标题，其次回退到会话返回的标题。
  String get pageTitle {
    final routeTitle = _unitTitle.trim();
    if (routeTitle.isNotEmpty) {
      return routeTitle;
    }
    final sessionTitle = data?.session.unitTitle.trim().isNotEmpty == true
        ? data!.session.unitTitle.trim()
        : data?.session.sourceTitle.trim() ?? '';
    if (sessionTitle.isNotEmpty) {
      return sessionTitle;
    }
    return LocaleKeys.practiceSessionTitle.tr;
  }

  /// 会话上下文优先显示路由传入分类名，缺失时退回分类编码。
  String get categoryDisplayName {
    final routeName = _categoryName.trim();
    if (routeName.isNotEmpty) {
      return routeName;
    }
    final categoryCode = unitProgress?.categoryCode.trim().isNotEmpty == true
        ? unitProgress!.categoryCode.trim()
        : data?.session.categoryCode.trim() ?? '';
    if (categoryCode.isEmpty) {
      return '--';
    }
    return _resolveCategoryName(categoryCode);
  }

  /// 当前单元的进度状态文案统一在 controller 内归一，避免页面散落判断逻辑。
  String get unitProgressStatusText {
    final progress = unitProgress;
    final value = progress?.progressStatus.trim().toLowerCase() ?? '';
    if (progress?.completed == true || value == 'completed') {
      return LocaleKeys.questionBankDashboardUnitStatusCompleted.tr;
    }
    if (value == 'in_progress') {
      return LocaleKeys.questionBankDashboardUnitStatusInProgress.tr;
    }
    if (value == 'disabled') {
      return LocaleKeys.questionBankDashboardUnitStatusDisabled.tr;
    }
    return LocaleKeys.questionBankDashboardUnitStatusNotStarted.tr;
  }

  /// 当前单元的正确率，优先使用单元进度聚合结果，缺失时退回会话统计。
  String get unitCorrectRateText {
    final progress = unitProgress;
    if (progress != null) {
      return '${progress.correctRate.toStringAsFixed(0)}%';
    }
    final detail = data;
    if (detail == null || detail.session.questionCount <= 0) {
      return '0%';
    }
    final rate = detail.session.correctCount / detail.session.questionCount;
    return '${(rate * 100).toStringAsFixed(0)}%';
  }

  /// 当前单元已完成题量，优先展示单元聚合进度。
  String get unitDoneCountText {
    final progress = unitProgress;
    if (progress != null) {
      return '${progress.doneCount}';
    }
    return '${data?.session.answeredCount ?? 0}';
  }

  /// 当前单元累计练习次数，便于透出“继续练习”的上下文。
  String get unitSessionCountText {
    return '${unitProgress?.sessionCount ?? 0}';
  }

  bool get isLastQuestion =>
      data != null && currentIndex.value >= data!.questions.length - 1;

  List<String> get selectedAnswers {
    final question = currentQuestion;
    if (question == null) {
      return const [];
    }
    return question.userAnswers;
  }

  @override
  void onInit() {
    super.onInit();
    _readArguments();
    _loadInitial();
  }

  Future<void> retry() async {
    await _loadInitial();
  }

  Future<bool> confirmExit() async {
    if (isFinishLoading.value || isSubmitLoading.value) {
      return false;
    }
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(LocaleKeys.practiceSessionExitTitle.tr),
        content: Text(LocaleKeys.practiceSessionExitMessage.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(LocaleKeys.practiceSessionExitStay.tr),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: Text(LocaleKeys.practiceSessionExitLeave.tr),
          ),
        ],
      ),
    );
    return result == true;
  }

  void selectOption(String label) {
    final question = currentQuestion;
    final detail = data;
    if (question == null || detail == null) {
      return;
    }

    final nextAnswers = List<String>.from(question.userAnswers);
    if (question.isMultipleChoice) {
      if (nextAnswers.contains(label)) {
        nextAnswers.remove(label);
      } else {
        nextAnswers.add(label);
      }
      nextAnswers.sort();
    } else {
      nextAnswers
        ..clear()
        ..add(label);
    }

    final nextQuestions = List<PracticeQuestionData>.from(detail.questions);
    nextQuestions[currentIndex.value] = question.copyWith(
      userAnswers: nextAnswers,
    );
    sessionData.value = detail.copyWith(questions: nextQuestions);
    sessionData.refresh();
  }

  void goPrevious() {
    final detail = data;
    if (detail == null || currentIndex.value <= 0) {
      return;
    }
    currentIndex.value -= 1;
    sessionData.value = detail.copyWith(currentIndex: currentIndex.value);
    _questionShownAt = DateTime.now();
  }

  void goNext() {
    final detail = data;
    if (detail == null || currentIndex.value >= detail.questions.length - 1) {
      return;
    }
    currentIndex.value += 1;
    sessionData.value = detail.copyWith(currentIndex: currentIndex.value);
    _questionShownAt = DateTime.now();
  }

  Future<void> submitCurrentAnswer() async {
    final detail = data;
    final question = currentQuestion;
    if (detail == null || question == null) {
      return;
    }
    if (isSubmitLoading.value || isFinishLoading.value) {
      return;
    }
    if (question.answered) {
      _showNotice(LocaleKeys.practiceSessionAlreadyAnswered.tr);
      return;
    }
    if (question.userAnswers.isEmpty) {
      _showNotice(LocaleKeys.practiceSessionSubmitEmpty.tr);
      return;
    }

    isSubmitLoading.value = true;
    try {
      final result = await _repository.submitAnswer(
        sessionId: detail.session.sessionId,
        questionId: question.questionId,
        answers: question.userAnswers,
        costSeconds: _resolveQuestionCostSeconds(),
      );
      await _loadSession(detail.session.sessionId);
      _showNotice(
        result.isCorrect
            ? LocaleKeys.practiceSessionAnsweredCorrect.tr
            : LocaleKeys.practiceSessionAnsweredWrong.tr,
      );
    } catch (e, stackTrace) {
      Logger.e(
        'PracticeSessionController.submitCurrentAnswer failed',
        error: e,
        stackTrace: stackTrace,
      );
      _showNotice(LocaleKeys.practiceSessionSubmitFailed.tr);
    } finally {
      isSubmitLoading.value = false;
    }
  }

  Future<void> finishPractice() async {
    final detail = data;
    if (detail == null || isFinishLoading.value || isSubmitLoading.value) {
      return;
    }

    isFinishLoading.value = true;
    try {
      await _repository.finishSession(
        sessionId: detail.session.sessionId,
      );
      AppNavigator.startPracticeReportPage(
        sessionId: detail.session.sessionId,
        categoryCode: detail.session.categoryCode,
        unitId: detail.session.unitId,
        unitTitle: detail.session.unitTitle,
      );
    } catch (e, stackTrace) {
      Logger.e(
        'PracticeSessionController.finishPractice failed',
        error: e,
        stackTrace: stackTrace,
      );
      _showNotice(LocaleKeys.practiceSessionFinishFailed.tr);
    } finally {
      isFinishLoading.value = false;
    }
  }

  Future<void> _loadInitial() async {
    isPageLoading.value = true;
    errorText.value = '';

    try {
      final hasUnitContext =
          _categoryCode.trim().isNotEmpty && _unitId.trim().isNotEmpty;
      if (hasUnitContext) {
        final subjectId = _currentSubjectService.currentSubject.value?.id ?? '';
        if (subjectId.trim().isEmpty) {
          errorText.value = LocaleKeys.practiceSessionMissingSubject.tr;
          return;
        }

        // 继续练习统一走 startSession，让后端基于 unitProgress.lastSessionId 决定恢复目标。
        final launch = await _repository.startSession(
          userId: _appSessionService.userId,
          subjectId: subjectId,
          categoryCode: _categoryCode,
          unitId: _unitId,
          questionCount: _questionCount,
          continueIfExists: _continueIfExists,
        );
        _sessionId = launch.session.sessionId;
        await _loadSession(_sessionId);
        return;
      }

      if (_sessionId.trim().isNotEmpty) {
        await _loadSession(_sessionId);
        return;
      }

      errorText.value = LocaleKeys.practiceSessionMissingUnit.tr;
    } catch (e, stackTrace) {
      Logger.e(
        'PracticeSessionController._loadInitial failed',
        error: e,
        stackTrace: stackTrace,
      );
      errorText.value = LocaleKeys.practiceSessionLoadFailed.tr;
    } finally {
      isPageLoading.value = false;
    }
  }

  Future<void> _loadSession(String sessionId) async {
    final detail = await _repository.fetchSession(sessionId: sessionId);
    sessionData.value = detail;
    currentIndex.value = detail.currentIndex;
    _questionShownAt = DateTime.now();
  }

  void _readArguments() {
    final args = Get.arguments;
    if (args is! Map) {
      return;
    }

    _sessionId = (args['sessionId'] ?? '').toString().trim();
    _categoryCode = (args['categoryCode'] ?? '').toString().trim();
    _categoryName = (args['categoryName'] ?? '').toString().trim();
    _unitId = (args['unitId'] ?? '').toString().trim();
    _unitTitle = (args['unitTitle'] ?? '').toString().trim();
    _continueIfExists = args['continueIfExists'] != false;
    _questionCount = _toInt(args['questionCount']);
    if (_questionCount <= 0) {
      _questionCount = 20;
    }
  }

  int _resolveQuestionCostSeconds() {
    final elapsed = DateTime.now().difference(_questionShownAt).inSeconds;
    if (elapsed <= 0) {
      return 1;
    }
    return elapsed;
  }

  /// 兼容后端当前仅回传 categoryCode 的阶段，前端先做最小分类名兜底。
  String _resolveCategoryName(String categoryCode) {
    switch (categoryCode.trim().toLowerCase()) {
      case 'chapter':
      case 'chapter_practice':
        return LocaleKeys.practiceSessionCategoryChapter.tr;
      case 'knowledge_point':
      case 'knowledge_practice':
        return LocaleKeys.practiceSessionCategoryKnowledge.tr;
      case 'mock_paper':
      case 'mock_exam':
        return LocaleKeys.practiceSessionCategoryMock.tr;
      case 'past_paper':
        return LocaleKeys.practiceSessionCategoryPastPaper.tr;
      case 'wrong_question_practice':
        return LocaleKeys.practiceSessionCategoryWrongQuestion.tr;
      default:
        return categoryCode.trim();
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

int _toInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
