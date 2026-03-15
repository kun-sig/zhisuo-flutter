import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/question_bank/question_display_models.dart';
import '../../data/models/question_bank/practice_session_models.dart';
import '../../data/repositories/question_bank/practice_asset_repository.dart';
import '../../data/repositories/question_bank/practice_session_repository.dart';
import '../../i18n/locale_keys.dart';
import '../../logger/logger.dart';
import '../../routes/app_navigator.dart';
import '../../services/app_session_service.dart';
import '../../services/current_subject_service.dart';

class PracticeSessionController extends GetxController {
  static const bool _autoSubmitCurrentQuestion = bool.fromEnvironment(
    'AUTO_SUBMIT_CURRENT_QUESTION',
    defaultValue: false,
  );
  static const bool _autoFinishWhenCompleted = bool.fromEnvironment(
    'AUTO_FINISH_WHEN_COMPLETED',
    defaultValue: false,
  );

  PracticeSessionController(
    this._repository,
    this._assetRepository,
    this._appSessionService,
    this._currentSubjectService,
  );

  final PracticeSessionRepository _repository;
  final PracticeAssetRepository _assetRepository;
  final AppSessionService _appSessionService;
  final CurrentSubjectService _currentSubjectService;

  final isPageLoading = false.obs;
  final isSubmitLoading = false.obs;
  final isFinishLoading = false.obs;
  final isFavoriteLoading = false.obs;
  final isNoteSubmitting = false.obs;
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
  final Set<String> _autoSubmittedQuestionIds = <String>{};
  bool _hasAutoFinishedPractice = false;

  PracticeSessionData? get data => sessionData.value;
  PracticeQuestionData? get currentQuestion => data?.currentQuestion;
  PracticeSessionUnitProgressData? get unitProgress => data?.unitProgress;

  /// 页面标题优先展示路由传入的单元标题，其次回退到会话返回的标题。
  String get pageTitle {
    // 先触达会话响应式数据，确保依赖该 getter 的 Obx 能稳定建立订阅关系。
    final detail = data;
    final routeTitle = _unitTitle.trim();
    if (routeTitle.isNotEmpty) {
      return routeTitle;
    }
    final sessionTitle = detail?.session.unitTitle.trim().isNotEmpty == true
        ? detail!.session.unitTitle.trim()
        : '';
    if (sessionTitle.isNotEmpty) {
      return sessionTitle;
    }
    final categoryCode = detail?.session.categoryCode.trim() ?? '';
    if (categoryCode.isNotEmpty) {
      return _resolveCategoryName(categoryCode);
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

  /// 当前题是否已提交，页面据此切换“提交”与“下一题/完成”动作。
  bool get isCurrentQuestionAnswered => currentQuestion?.answered == true;

  /// 已作答且后面还有题时，主按钮切换为“下一题”，避免用户停留在已答题上。
  bool get canGoNextAfterAnswered =>
      isCurrentQuestionAnswered && !isLastQuestion;

  /// 解析内容只在当前题完成作答后展示，避免用户在答题前直接看到答案线索。
  bool get shouldShowAnalysis => isCurrentQuestionAnswered;

  /// 当前题答题完成后输出统一反馈协议，供页面和后续报告场景复用同一展示逻辑。
  QuestionFeedbackDisplayData? get questionFeedback {
    final summary = data?.session.lastAnswerSummary;
    final question = currentQuestion;
    if (!isCurrentQuestionAnswered ||
        summary == null ||
        question == null ||
        summary.questionId.trim() != question.questionId.trim()) {
      return null;
    }
    return summary.isCorrect
        ? QuestionFeedbackDisplayData(
            label: LocaleKeys.practiceSessionAnsweredCorrect.tr,
            color: 'success',
          )
        : QuestionFeedbackDisplayData(
            label: LocaleKeys.practiceSessionAnsweredWrong.tr,
            color: 'error',
          );
  }

  /// 当前题收藏状态在会话内做就地维护，避免用户操作后必须整页刷新。
  bool get isCurrentQuestionFavorite => currentQuestion?.favorite == true;

  /// 会话内快捷笔记入口透出当前题已有笔记数量，帮助用户判断是否需要补充记录。
  int get currentQuestionNoteCount => currentQuestion?.noteCount ?? 0;

  /// 当前题最近一条笔记摘要，优先在会话内做轻量展示，减少频繁跳转资产页。
  String get currentQuestionNoteSummary =>
      currentQuestion?.noteSummary.trim() ?? '';

  /// 会话页的高频资产操作统一输出展示协议，避免页面层重复拼接收藏/笔记按钮文案。
  QuestionActionBarDisplayData get questionActionBar {
    return QuestionActionBarDisplayData(
      title: LocaleKeys.practiceSessionAssetsTitle.tr,
      actions: [
        QuestionActionDisplayData(
          label: isFavoriteLoading.value
              ? LocaleKeys.practiceSessionFavoriteLoading.tr
              : isCurrentQuestionFavorite
                  ? LocaleKeys.practiceSessionFavoriteActive.tr
                  : LocaleKeys.practiceSessionFavoriteInactive.tr,
          iconName: isCurrentQuestionFavorite ? 'star_filled' : 'star_outline',
          onPressed: isFavoriteLoading.value || isNoteSubmitting.value
              ? null
              : toggleCurrentQuestionFavorite,
        ),
        QuestionActionDisplayData(
          label: isNoteSubmitting.value
              ? LocaleKeys.practiceSessionNoteSubmitting.tr
              : currentQuestionNoteCount > 0
                  ? LocaleKeys.practiceSessionNoteAppend.trParams({
                      'count': '$currentQuestionNoteCount',
                    })
                  : LocaleKeys.practiceSessionNoteCreate.tr,
          iconName: 'note',
          onPressed: isNoteSubmitting.value || isFavoriteLoading.value
              ? null
              : openCreateNoteDialog,
          isPrimary: true,
        ),
      ],
    );
  }

  /// 题目进度头部统一输出展示协议，页面只负责渲染，不再自己拼接数字文案。
  QuestionProgressDisplayData get questionProgress {
    final detail = data;
    return QuestionProgressDisplayData(
      title: pageTitle,
      currentNumber: currentIndex.value + 1,
      totalCount: detail?.session.questionCount ?? 0,
      answeredCount: detail?.session.answeredCount ?? 0,
      remainingCount: detail?.remainingCount ?? 0,
    );
  }

  /// 题目底部答题动作统一输出展示协议，避免页面散落判断“提交/下一题/完成”切换逻辑。
  QuestionBottomActionBarDisplayData get questionBottomActionBar {
    final canOperate = !isSubmitLoading.value && !isFinishLoading.value;
    final leadingAction = QuestionBottomActionDisplayData(
      label: LocaleKeys.practiceSessionPrevious.tr,
      onPressed: currentIndex.value > 0 && canOperate ? goPrevious : null,
    );

    final primaryLabel = isSubmitLoading.value
        ? LocaleKeys.practiceSessionSubmitting.tr
        : canGoNextAfterAnswered
            ? LocaleKeys.practiceSessionNext.tr
            : isCurrentQuestionAnswered
                ? LocaleKeys.practiceSessionFinish.tr
                : LocaleKeys.practiceSessionSubmit.tr;
    final primaryAction = QuestionBottomActionDisplayData(
      label: primaryLabel,
      onPressed: canOperate
          ? canGoNextAfterAnswered
              ? goNext
              : isCurrentQuestionAnswered
                  ? finishPractice
                  : submitCurrentAnswer
          : null,
      isPrimary: true,
    );

    final secondaryAction = QuestionBottomActionDisplayData(
      label: isFinishLoading.value
          ? LocaleKeys.practiceSessionFinishing.tr
          : LocaleKeys.practiceSessionFinish.tr,
      onPressed: canOperate ? finishPractice : null,
      isExpanded: true,
    );

    return QuestionBottomActionBarDisplayData(
      leadingAction: leadingAction,
      primaryAction: primaryAction,
      secondaryAction: secondaryAction,
    );
  }

  /// 答题卡统一输出题号导航协议，页面只负责渲染题号，不再自行遍历 questions 拼状态。
  QuestionAnswerSheetDisplayData get questionAnswerSheet {
    final questions = data?.questions ?? const <PracticeQuestionData>[];
    return QuestionAnswerSheetDisplayData(
      title: LocaleKeys.practiceSessionAnswerSheetTitle.tr,
      items: List<QuestionAnswerSheetItemDisplayData>.generate(
        questions.length,
        (index) {
          final question = questions[index];
          return QuestionAnswerSheetItemDisplayData(
            index: index,
            label: '${index + 1}',
            answered: question.answered,
            current: index == currentIndex.value,
          );
        },
      ),
    );
  }

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
    if (question.answered || isSubmitLoading.value || isFinishLoading.value) {
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

    // 单选和判断题在用户点击后直接提交，减少额外交互步骤；多选仍保留显式提交。
    if (!question.isMultipleChoice) {
      submitCurrentAnswer();
    }
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

  /// 通过答题卡直接跳转到指定题号，统一复用已有 currentIndex 与题目计时刷新逻辑。
  void jumpToQuestion(int index) {
    final detail = data;
    if (detail == null || index < 0 || index >= detail.questions.length) {
      return;
    }
    if (index == currentIndex.value) {
      return;
    }
    currentIndex.value = index;
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
      final previousIndex = currentIndex.value;
      final previousQuestionId = question.questionId;
      final result = await _repository.submitAnswer(
        sessionId: detail.session.sessionId,
        questionId: question.questionId,
        answers: question.userAnswers,
        costSeconds: _resolveQuestionCostSeconds(),
      );
      await _loadSession(detail.session.sessionId);
      _advanceAfterSubmit(
        previousQuestionId: previousQuestionId,
        previousIndex: previousIndex,
      );
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

  /// 切换当前题收藏状态，并把最新收藏标记回写到当前会话数据。
  Future<void> toggleCurrentQuestionFavorite() async {
    final detail = data;
    final question = currentQuestion;
    final subjectId =
        _currentSubjectService.currentSubject.value?.id.trim() ?? '';
    if (detail == null || question == null || subjectId.isEmpty) {
      _showNotice(LocaleKeys.practiceSessionFavoriteFailed.tr);
      return;
    }
    if (isFavoriteLoading.value) {
      return;
    }

    final nextFavorite = !question.favorite;
    isFavoriteLoading.value = true;
    try {
      final resolvedFavorite = await _assetRepository.toggleQuestionFavorite(
        userId: _appSessionService.userId,
        subjectId: subjectId,
        questionId: question.questionId,
        favorite: nextFavorite,
      );
      _replaceCurrentQuestion(
        question.copyWith(favorite: resolvedFavorite),
      );
      _showNotice(
        resolvedFavorite
            ? LocaleKeys.practiceSessionFavoriteAdded.tr
            : LocaleKeys.practiceSessionFavoriteRemoved.tr,
      );
    } catch (e, stackTrace) {
      Logger.e(
        'PracticeSessionController.toggleCurrentQuestionFavorite failed',
        error: e,
        stackTrace: stackTrace,
      );
      _showNotice(LocaleKeys.practiceSessionFavoriteFailed.tr);
    } finally {
      isFavoriteLoading.value = false;
    }
  }

  /// 打开当前题快捷笔记弹窗，只暴露正文输入，题目和会话上下文由当前页面自动带入。
  Future<void> openCreateNoteDialog() async {
    final question = currentQuestion;
    final detail = data;
    if (question == null || detail == null || isNoteSubmitting.value) {
      return;
    }

    final contentController = TextEditingController(
      text: currentQuestionNoteSummary,
    );
    try {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: Text(LocaleKeys.practiceSessionNoteTitle.tr),
          content: TextField(
            controller: contentController,
            minLines: 4,
            maxLines: 8,
            decoration: InputDecoration(
              labelText: LocaleKeys.practiceSessionNoteInputLabel.tr,
              hintText: LocaleKeys.practiceSessionNoteInputHint.tr,
              alignLabelWithHint: true,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text(LocaleKeys.practiceSessionNoteCancel.tr),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              child: Text(LocaleKeys.practiceSessionNoteConfirm.tr),
            ),
          ],
        ),
      );
      if (confirmed != true) {
        return;
      }
      await createCurrentQuestionNote(contentController.text);
    } finally {
      contentController.dispose();
    }
  }

  /// 创建当前题笔记后只增量更新当前题的笔记摘要和数量，保证答题上下文不被打断。
  Future<void> createCurrentQuestionNote(String content) async {
    final detail = data;
    final question = currentQuestion;
    final subjectId =
        _currentSubjectService.currentSubject.value?.id.trim() ?? '';
    final resolvedContent = content.trim();
    if (detail == null || question == null || subjectId.isEmpty) {
      _showNotice(LocaleKeys.practiceSessionNoteCreateFailed.tr);
      return;
    }
    if (resolvedContent.isEmpty) {
      _showNotice(LocaleKeys.practiceSessionNoteInputEmpty.tr);
      return;
    }
    if (isNoteSubmitting.value) {
      return;
    }

    isNoteSubmitting.value = true;
    try {
      final note = await _assetRepository.createPracticeNote(
        userId: _appSessionService.userId,
        subjectId: subjectId,
        questionId: question.questionId,
        sessionId: detail.session.sessionId,
        content: resolvedContent,
      );
      _replaceCurrentQuestion(
        question.copyWith(
          noteCount: question.noteCount + 1,
          noteSummary: note.content,
          noteUpdatedAt: note.updatedAt ?? note.createdAt,
        ),
      );
      _showNotice(LocaleKeys.practiceSessionNoteCreateSuccess.tr);
    } catch (e, stackTrace) {
      Logger.e(
        'PracticeSessionController.createCurrentQuestionNote failed',
        error: e,
        stackTrace: stackTrace,
      );
      _showNotice(LocaleKeys.practiceSessionNoteCreateFailed.tr);
    } finally {
      isNoteSubmitting.value = false;
    }
  }

  Future<void> _loadInitial() async {
    isPageLoading.value = true;
    errorText.value = '';
    // 每次重新进入会话初始化时重置联调辅助状态，保证 retry 或重新启动后仍可完整自动跑链路。
    _autoSubmittedQuestionIds.clear();
    _hasAutoFinishedPractice = false;

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
    _maybeAutoSubmitCurrentQuestion(detail);
    _maybeAutoFinishPractice(detail);
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

  /// 联调模式下按题目逐题自动作答，保证整场练习可以连续推进到最后一题。
  void _maybeAutoSubmitCurrentQuestion(PracticeSessionData detail) {
    if (!_autoSubmitCurrentQuestion) {
      return;
    }
    final question = detail.currentQuestion;
    if (question == null || question.answered || question.options.isEmpty) {
      return;
    }
    final questionId = question.questionId.trim();
    if (questionId.isEmpty || _autoSubmittedQuestionIds.contains(questionId)) {
      return;
    }
    _autoSubmittedQuestionIds.add(questionId);
    Future<void>.delayed(const Duration(milliseconds: 300), () async {
      selectOption(question.options.first.label);
      if (question.isMultipleChoice) {
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await submitCurrentAnswer();
      }
    });
  }

  /// 联调模式下，当会话已经答完全部题目时自动交卷，继续把链路推进到报告页。
  void _maybeAutoFinishPractice(PracticeSessionData detail) {
    if (!_autoFinishWhenCompleted || _hasAutoFinishedPractice) {
      return;
    }
    final allAnswered = detail.remainingCount <= 0 ||
        detail.session.answeredCount >= detail.session.questionCount;
    if (!allAnswered) {
      return;
    }
    _hasAutoFinishedPractice = true;
    Future<void>.delayed(const Duration(milliseconds: 300), finishPractice);
  }

  /// 把当前题的局部变更回写到 questions 列表，避免收藏/笔记等轻量操作触发整页 reload。
  void _replaceCurrentQuestion(PracticeQuestionData nextQuestion) {
    final detail = data;
    if (detail == null) {
      return;
    }
    final questions = List<PracticeQuestionData>.from(detail.questions);
    if (currentIndex.value < 0 || currentIndex.value >= questions.length) {
      return;
    }
    questions[currentIndex.value] = nextQuestion;
    sessionData.value = detail.copyWith(questions: questions);
    sessionData.refresh();
  }

  /// 提交后优先尊重服务端回传的 currentIndex；若后端仍停留在原题，前端本地补一次推进，避免用户卡在已作答题。
  void _advanceAfterSubmit({
    required String previousQuestionId,
    required int previousIndex,
  }) {
    final detail = data;
    final question = currentQuestion;
    if (detail == null || question == null || detail.remainingCount <= 0) {
      return;
    }
    final serverMoved = detail.currentIndex != previousIndex ||
        question.questionId != previousQuestionId;
    if (serverMoved || !question.answered) {
      return;
    }

    final nextIndex = _findNextPendingQuestionIndex(
      questions: detail.questions,
      startIndex: previousIndex + 1,
    );
    if (nextIndex < 0) {
      return;
    }
    currentIndex.value = nextIndex;
    sessionData.value = detail.copyWith(currentIndex: nextIndex);
    _questionShownAt = DateTime.now();
  }

  /// 自动推进时优先向后找未答题；若后面没有，再回头找前面的未答题，保证 remainingCount 与页面位置一致。
  int _findNextPendingQuestionIndex({
    required List<PracticeQuestionData> questions,
    required int startIndex,
  }) {
    for (var index = startIndex; index < questions.length; index += 1) {
      if (!questions[index].answered) {
        return index;
      }
    }
    for (var index = 0;
        index < startIndex && index < questions.length;
        index += 1) {
      if (!questions[index].answered) {
        return index;
      }
    }
    return -1;
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
    // 单测场景通常没有 overlay，上浮提示在这种情况下直接跳过，避免影响状态流转验证。
    if (Get.context == null && Get.overlayContext == null) {
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
