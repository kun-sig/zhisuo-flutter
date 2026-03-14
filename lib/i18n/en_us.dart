import 'locale_keys.dart';

class EnUS {
  static const appName = 'ZhiSuo Learning';
  static const authLogin = 'Login';
  static const authWelcome = 'Welcome Back';
  static const authPhone = 'Phone';
  static const authPassword = 'Password';
  static const authForgotPassword = 'Forgot Password?';
  static const authNoAccount = 'No account?';
  static const authSignUp = 'Sign Up';

  static Map<String, String> toMap() => {
        LocaleKeys.appName: appName,
        LocaleKeys.authLogin: authLogin,
        LocaleKeys.authWelcome: authWelcome,
        LocaleKeys.authPhone: authPhone,
        LocaleKeys.authPassword: authPassword,
        LocaleKeys.authForgotPassword: authForgotPassword,
        LocaleKeys.authNoAccount: authNoAccount,
        LocaleKeys.authSignUp: authSignUp,

        // tabs
        LocaleKeys.homeTab: 'Home',
        LocaleKeys.questionBankTab: 'Question Bank',
        LocaleKeys.questionBankCurrentSubjectLabel: 'Current Subject',
        LocaleKeys.questionBankCurrentSubjectStatus: 'Synced',
        LocaleKeys.questionBankCurrentSubjectEmpty: 'No exam subject selected',
        LocaleKeys.questionBankCurrentSubjectHint:
            'After switching from Subject page, the current question-bank subject will appear here.',
        LocaleKeys.questionBankCurrentSubjectReadyHint:
            'Practice content is ready for the selected subject. You can start daily and focused practice directly.',
        LocaleKeys.questionBankCurrentSubjectCountdown: 'Exam Countdown',
        LocaleKeys.questionBankCurrentSubjectCountdownUnit: 'days',
        LocaleKeys.questionBankCurrentSubjectSelect: 'Choose',
        LocaleKeys.questionBankCurrentSubjectSwitch: 'Switch Subject',
        LocaleKeys.questionBankDashboardContinueTitle: 'Continue Practice',
        LocaleKeys.questionBankDashboardContinueAction: 'Resume',
        LocaleKeys.questionBankDashboardPracticeTitle: 'Practice Categories',
        LocaleKeys.questionBankDashboardUnitPreviewTitle: 'Unit Preview',
        LocaleKeys.questionBankDashboardAssetTitle: 'Learning Assets',
        LocaleKeys.questionBankDashboardSummaryTitle: 'Today Summary',
        LocaleKeys.questionBankDashboardSummaryDone: 'Done',
        LocaleKeys.questionBankDashboardSummaryAccuracy: 'Accuracy',
        LocaleKeys.questionBankDashboardSummaryRecent: 'Recent',
        LocaleKeys.questionBankDashboardSummaryPending: 'Pending Review',
        LocaleKeys.questionBankDashboardUpdatedAt: 'Updated',
        LocaleKeys.questionBankDashboardNeedSubject:
            'Select a subject before starting practice',
        LocaleKeys.questionBankDashboardNoSubjectBanner:
            'No current subject is selected. Practice categories and units are now shown in a disabled state.',
        LocaleKeys.questionBankDashboardLoadFailed:
            'Failed to load dashboard. Pull down to retry.',
        LocaleKeys.questionBankDashboardEmptyCategories:
            'No practice categories for this subject',
        LocaleKeys.questionBankDashboardEmptyUnits:
            'No practice unit preview for this subject',
        LocaleKeys.questionBankDashboardCategoryDisabledDefault:
            'This category is currently unavailable. Please try again later.',
        LocaleKeys.questionBankDashboardCategoryPlanned:
            'Unit list page will be connected next',
        LocaleKeys.questionBankDashboardUnitPlanned:
            'Unit practice flow will be connected next',
        LocaleKeys.questionBankDashboardUnitDisabled:
            'This practice unit is currently unavailable',
        LocaleKeys.questionBankDashboardUnitDisabledDefault:
            'This practice unit is currently unavailable. Please try again later.',
        LocaleKeys.questionBankDashboardUnitMetricQuestions: 'Questions',
        LocaleKeys.questionBankDashboardUnitMetricDone: 'Done',
        LocaleKeys.questionBankDashboardUnitMetricAccuracy: 'Accuracy',
        LocaleKeys.questionBankDashboardUnitStatusCompleted: 'Completed',
        LocaleKeys.questionBankDashboardUnitStatusInProgress: 'In Progress',
        LocaleKeys.questionBankDashboardUnitStatusNotStarted: 'Not Started',
        LocaleKeys.questionBankDashboardUnitStatusDisabled: 'Unavailable',
        LocaleKeys.questionBankDashboardPlannedSuffix: 'is planned next',
        LocaleKeys.questionBankDashboardSessionPlanned:
            'Practice session page will be added in Phase 2',
        LocaleKeys.practiceUnitListTitle: 'Practice Units',
        LocaleKeys.practiceUnitListLoadFailed:
            'Failed to load practice units. Retry.',
        LocaleKeys.practiceUnitListRetry: 'Retry',
        LocaleKeys.practiceUnitListEmpty: 'No practice units in this category',
        LocaleKeys.practiceUnitListNeedSubject:
            'Select a current subject before opening practice units',
        LocaleKeys.practiceUnitListMissingCategory:
            'Missing category parameter. Unable to open unit list.',
        LocaleKeys.practiceUnitListCategoryDisabledBanner:
            'This category is currently unavailable. The unit entries below are shown in a disabled state.',
        LocaleKeys.practiceUnitListCategoryDisabledEmpty:
            'This category is currently unavailable and has no accessible practice units yet.',
        LocaleKeys.practiceUnitListSummarySubject: 'Subject',
        LocaleKeys.practiceUnitListSummaryTotal: 'Units',
        LocaleKeys.practiceUnitListSummaryCompleted: 'Completed',
        LocaleKeys.practiceUnitListSummaryAccuracy: 'Avg Accuracy',
        LocaleKeys.practiceUnitListLoadMore: 'Load More',
        LocaleKeys.practiceUnitListNoMore: 'No more practice units',
        LocaleKeys.practiceSessionTitle: 'Practice Session',
        LocaleKeys.practiceSessionLoadFailed:
            'Failed to load practice session. Retry.',
        LocaleKeys.practiceSessionRetry: 'Retry',
        LocaleKeys.practiceSessionEmpty: 'No questions in this session',
        LocaleKeys.practiceSessionMissingSubject:
            'No current subject selected. Unable to start practice.',
        LocaleKeys.practiceSessionMissingUnit:
            'Missing category or unit parameter. Unable to start practice.',
        LocaleKeys.practiceSessionNoOptions:
            'No option data is available for this question',
        LocaleKeys.practiceSessionAnalysisTitle: 'Analysis',
        LocaleKeys.practiceSessionNoAnalysis: 'No analysis yet',
        LocaleKeys.practiceSessionNoStem: 'No question stem yet',
        LocaleKeys.practiceSessionProgressIndex: 'Question @current / @total',
        LocaleKeys.practiceSessionProgressSummary:
            'Answered @answered · Remaining @remaining',
        LocaleKeys.practiceSessionContextCategory: 'Category',
        LocaleKeys.practiceSessionContextDone: 'Done',
        LocaleKeys.practiceSessionContextAccuracy: 'Accuracy',
        LocaleKeys.practiceSessionContextSessions: 'Sessions',
        LocaleKeys.practiceSessionCategoryChapter: 'Chapter Practice',
        LocaleKeys.practiceSessionCategoryKnowledge: 'Knowledge Practice',
        LocaleKeys.practiceSessionCategoryMock: 'Mock Paper',
        LocaleKeys.practiceSessionCategoryPastPaper: 'Past Paper',
        LocaleKeys.practiceSessionCategoryWrongQuestion: 'Wrong Question Retry',
        LocaleKeys.practiceSessionPrevious: 'Previous',
        LocaleKeys.practiceSessionNext: 'Next',
        LocaleKeys.practiceSessionSubmit: 'Submit',
        LocaleKeys.practiceSessionFinish: 'Finish',
        LocaleKeys.practiceSessionSubmitting: 'Submitting...',
        LocaleKeys.practiceSessionFinishing: 'Finishing...',
        LocaleKeys.practiceSessionSubmitEmpty: 'Select an answer first',
        LocaleKeys.practiceSessionSubmitFailed: 'Failed to submit answer',
        LocaleKeys.practiceSessionFinishFailed: 'Failed to finish practice',
        LocaleKeys.practiceSessionAlreadyAnswered:
            'This question has already been submitted',
        LocaleKeys.practiceSessionAnsweredCorrect: 'Correct',
        LocaleKeys.practiceSessionAnsweredWrong: 'Incorrect',
        LocaleKeys.practiceSessionExitTitle: 'Leave Practice',
        LocaleKeys.practiceSessionExitMessage:
            'Your progress will be kept and can be resumed later.',
        LocaleKeys.practiceSessionExitStay: 'Keep Practicing',
        LocaleKeys.practiceSessionExitLeave: 'Leave',
        LocaleKeys.practiceReportTitle: 'Practice Report',
        LocaleKeys.practiceReportLoadFailed:
            'Failed to load practice report. Retry.',
        LocaleKeys.practiceReportEmpty: 'No report data for this session',
        LocaleKeys.practiceReportRetry: 'Retry',
        LocaleKeys.practiceReportSummaryTitle: 'Summary',
        LocaleKeys.practiceReportSummaryAccuracy: 'Accuracy',
        LocaleKeys.practiceReportSummaryCorrect: 'Correct',
        LocaleKeys.practiceReportSummaryWrong: 'Wrong',
        LocaleKeys.practiceReportSummaryDuration: 'Duration',
        LocaleKeys.practiceReportChapterTitle: 'Chapter Stats',
        LocaleKeys.practiceReportCategoryTitle: 'Question Type Stats',
        LocaleKeys.practiceReportWrongTitle: 'Wrong Questions',
        LocaleKeys.practiceReportSuggestionTitle: 'Review Suggestions',
        LocaleKeys.practiceReportSuggestionPerfect:
            'Your overall performance is stable. Move on to the next unit or review the wrong-book for reinforcement.',
        LocaleKeys.practiceReportSuggestionReviewWrong:
            'You got @count questions wrong. Review each explanation first and summarize the common pitfalls.',
        LocaleKeys.practiceReportSuggestionWeakChapter:
            'The weakest chapter is "@name". Review it first before retrying this unit.',
        LocaleKeys.practiceReportSuggestionWeakCategory:
            'The weakest question type is "@name". Focus on the solving pattern for that question type.',
        LocaleKeys.practiceReportSuggestionRetryUnit:
            'After reviewing the wrong questions, retry this unit once more to confirm the knowledge points are stable.',
        LocaleKeys.practiceReportSuggestionSlowDown:
            'Your pace was fast while accuracy stayed average. Slow down a bit on reading and elimination next time.',
        LocaleKeys.practiceReportNoStats: 'No stats available',
        LocaleKeys.practiceReportNoWrongQuestions:
            'There are no wrong questions in this session',
        LocaleKeys.practiceReportContextCategory: 'Category',
        LocaleKeys.practiceReportContextUnitId: 'Unit ID',
        LocaleKeys.practiceReportContextReportId: 'Report ID',
        LocaleKeys.practiceReportCategoryChapter: 'Chapter Practice',
        LocaleKeys.practiceReportCategoryKnowledge: 'Knowledge Practice',
        LocaleKeys.practiceReportCategoryMock: 'Mock Paper',
        LocaleKeys.practiceReportCategoryPastPaper: 'Past Paper',
        LocaleKeys.practiceReportCategoryWrongQuestion: 'Wrong Question Retry',
        LocaleKeys.commonNoticeTitle: 'Notice',
        LocaleKeys.wrongBookTitle: 'Wrong Book',
        LocaleKeys.wrongBookDescription:
            'Browse wrong question records for the current subject.',
        LocaleKeys.wrongBookLoadFailed: 'Failed to load wrong question records',
        LocaleKeys.wrongBookRetry: 'Retry',
        LocaleKeys.wrongBookEmpty: 'No wrong question records yet',
        LocaleKeys.wrongBookNeedSubject:
            'Select a current subject before opening the wrong book',
        LocaleKeys.wrongBookSummarySubject: 'Subject',
        LocaleKeys.wrongBookSummaryTotal: 'Wrong Questions',
        LocaleKeys.wrongBookQuestionId: 'Question ID',
        LocaleKeys.wrongBookWrongCount: 'Wrong Count',
        LocaleKeys.wrongBookLastWrongAt: 'Last Wrong At',
        LocaleKeys.wrongBookStatus: 'Status',
        LocaleKeys.wrongBookStatusUnknown: 'Unknown',
        LocaleKeys.wrongBookStatusActive: 'Active',
        LocaleKeys.wrongBookStatusArchived: 'Archived',
        LocaleKeys.wrongBookLoadMore: 'Load More',
        LocaleKeys.wrongBookNoMore: 'No more wrong questions',
        LocaleKeys.wrongBookSummaryFilters: 'Filters',
        LocaleKeys.wrongBookFilterTitle: 'Filters',
        LocaleKeys.wrongBookFilterChapterId: 'Chapter ID',
        LocaleKeys.wrongBookFilterChapterHint:
            'Enter a chapter ID to filter wrong questions',
        LocaleKeys.wrongBookFilterQuestionCategoryId: 'Question Type ID',
        LocaleKeys.wrongBookFilterQuestionCategoryHint:
            'Enter a question type ID to filter wrong questions',
        LocaleKeys.wrongBookFilterApply: 'Apply',
        LocaleKeys.wrongBookFilterClear: 'Clear',
        LocaleKeys.wrongBookFilterTip:
            'Retry practice currently supports only one source filter. Keep either a chapter ID or a question type ID.',
        LocaleKeys.wrongBookRetryAction: 'Retry Practice',
        LocaleKeys.wrongBookRetryNeedFilter:
            'Enter a chapter ID or question type ID first',
        LocaleKeys.wrongBookRetrySingleFilterOnly:
            'Retry practice supports only one filter at a time',
        LocaleKeys.wrongBookRetryPlanned:
            'Wrong-question retry will be connected after unitId migration',
        LocaleKeys.practiceHistoryTitle: 'Practice History',
        LocaleKeys.practiceHistoryDescription:
            'Browse practice records for the current subject.',
        LocaleKeys.practiceHistoryLoadFailed: 'Failed to load practice history',
        LocaleKeys.practiceHistoryRetry: 'Retry',
        LocaleKeys.practiceHistoryEmpty: 'No practice history yet',
        LocaleKeys.practiceHistoryNeedSubject:
            'Select a current subject before opening practice history',
        LocaleKeys.practiceHistorySummarySubject: 'Subject',
        LocaleKeys.practiceHistorySummaryTotal: 'Records',
        LocaleKeys.practiceHistoryQuestionCount: 'Questions',
        LocaleKeys.practiceHistoryCorrectCount: 'Correct',
        LocaleKeys.practiceHistoryWrongCount: 'Wrong',
        LocaleKeys.practiceHistoryCorrectRate: 'Accuracy',
        LocaleKeys.practiceHistoryDuration: 'Duration',
        LocaleKeys.practiceHistoryFinishedAt: 'Finished At',
        LocaleKeys.practiceHistoryViewReport: 'View Report',
        LocaleKeys.practiceHistoryMissingSession:
            'This record has no session ID',
        LocaleKeys.practiceHistoryLoadMore: 'Load More',
        LocaleKeys.practiceHistoryNoMore: 'No more records',
        LocaleKeys.favoritesTitle: 'Favorites',
        LocaleKeys.favoritesDescription:
            'Browse favorite questions for the current subject.',
        LocaleKeys.favoritesLoadFailed: 'Failed to load favorites',
        LocaleKeys.favoritesRetry: 'Retry',
        LocaleKeys.favoritesEmpty: 'No favorite questions yet',
        LocaleKeys.favoritesNeedSubject:
            'Select a current subject before opening favorites',
        LocaleKeys.favoritesSummarySubject: 'Subject',
        LocaleKeys.favoritesSummaryTotal: 'Favorites',
        LocaleKeys.favoritesQuestionId: 'Question ID',
        LocaleKeys.favoritesCreatedAt: 'Favorited At',
        LocaleKeys.favoritesRemove: 'Remove',
        LocaleKeys.favoritesRemoving: 'Processing...',
        LocaleKeys.favoritesRemoved: 'Removed from favorites',
        LocaleKeys.favoritesToggleFailed: 'Failed to update favorite state',
        LocaleKeys.favoritesLoadMore: 'Load More',
        LocaleKeys.favoritesNoMore: 'No more favorites',
        LocaleKeys.practiceNotesTitle: 'Practice Notes',
        LocaleKeys.practiceNotesDescription:
            'Browse practice notes for the current subject.',
        LocaleKeys.practiceNotesLoadFailed: 'Failed to load practice notes',
        LocaleKeys.practiceNotesRetry: 'Retry',
        LocaleKeys.practiceNotesEmpty: 'No practice notes yet',
        LocaleKeys.practiceNotesNeedSubject:
            'Select a current subject before opening practice notes',
        LocaleKeys.practiceNotesSummarySubject: 'Subject',
        LocaleKeys.practiceNotesSummaryTotal: 'Notes',
        LocaleKeys.practiceNotesQuestionId: 'Question ID',
        LocaleKeys.practiceNotesSessionId: 'Session ID',
        LocaleKeys.practiceNotesStatus: 'Status',
        LocaleKeys.practiceNotesUpdatedAt: 'Updated At',
        LocaleKeys.practiceNotesReviewRemark: 'Review Remark',
        LocaleKeys.practiceNotesContentEmpty: 'No note content yet',
        LocaleKeys.practiceNotesStatusUnknown: 'Unknown',
        LocaleKeys.practiceNotesStatusPending: 'Pending',
        LocaleKeys.practiceNotesStatusApproved: 'Approved',
        LocaleKeys.practiceNotesStatusRejected: 'Rejected',
        LocaleKeys.practiceNotesLoadMore: 'Load More',
        LocaleKeys.practiceNotesNoMore: 'No more notes',
        LocaleKeys.practiceNotesCreateAction: 'New Note',
        LocaleKeys.practiceNotesCreating: 'Creating...',
        LocaleKeys.practiceNotesCreateTitle: 'Create Practice Note',
        LocaleKeys.practiceNotesCreateQuestionId: 'Question ID',
        LocaleKeys.practiceNotesCreateSessionId: 'Session ID (optional)',
        LocaleKeys.practiceNotesCreateContent: 'Note Content',
        LocaleKeys.practiceNotesCreateCancel: 'Cancel',
        LocaleKeys.practiceNotesCreateConfirm: 'Submit',
        LocaleKeys.practiceNotesCreateInvalid:
            'Question ID and note content are required',
        LocaleKeys.practiceNotesCreateSuccess: 'Practice note created',
        LocaleKeys.practiceNotesCreateFailed: 'Failed to create practice note',
        LocaleKeys.studyCenterTab: 'Study Center',
        LocaleKeys.discoverTab: 'Discover',
        LocaleKeys.mineTab: 'Mine',
      };
}
