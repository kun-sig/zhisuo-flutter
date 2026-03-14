import '../../../logger/logger.dart';
import '../../../services/api_exception.dart';
import '../../models/question_bank/practice_report_models.dart';
import '../../models/question_bank/practice_session_models.dart';
import '../../remote/practice_remote_service.dart';

class PracticeSessionRepository {
  PracticeSessionRepository(this._remoteService);

  final PracticeRemoteDataSource _remoteService;

  /// 启动练习会话，统一按 `categoryCode + unitId` 建立或恢复会话。
  Future<PracticeSessionLaunchData> startSession({
    required String userId,
    required String subjectId,
    required String categoryCode,
    required String unitId,
    int questionCount = 20,
    bool continueIfExists = true,
  }) async {
    try {
      final data = await _remoteService.startPracticeSession(
        userId: userId,
        subjectId: subjectId,
        categoryCode: categoryCode,
        unitId: unitId,
        questionCount: questionCount <= 0 ? 20 : questionCount,
        continueIfExists: continueIfExists,
      );
      return PracticeSessionLaunchData.fromJson(data);
    } on ApiException catch (e) {
      Logger.w(
        'PracticeSessionRepository.startSession business failed: '
        'code=${e.code}, message=${e.message}, requestId=${e.requestId}',
      );
      rethrow;
    } catch (e, stackTrace) {
      Logger.e(
        'PracticeSessionRepository.startSession failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<PracticeSessionData> fetchSession({
    required String sessionId,
  }) async {
    try {
      final data = await _remoteService.getPracticeSession(
        sessionId: sessionId,
      );
      return PracticeSessionData.fromJson(data);
    } on ApiException catch (e) {
      Logger.w(
        'PracticeSessionRepository.fetchSession business failed: '
        'code=${e.code}, message=${e.message}, requestId=${e.requestId}',
      );
      rethrow;
    } catch (e, stackTrace) {
      Logger.e(
        'PracticeSessionRepository.fetchSession failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<PracticeSubmitResult> submitAnswer({
    required String sessionId,
    required String questionId,
    required List<String> answers,
    int costSeconds = 0,
  }) async {
    try {
      final data = await _remoteService.submitPracticeAnswer(
        sessionId: sessionId,
        questionId: questionId,
        answers: answers,
        costSeconds: costSeconds,
      );
      return PracticeSubmitResult.fromJson(data);
    } on ApiException catch (e) {
      Logger.w(
        'PracticeSessionRepository.submitAnswer business failed: '
        'code=${e.code}, message=${e.message}, requestId=${e.requestId}',
      );
      rethrow;
    } catch (e, stackTrace) {
      Logger.e(
        'PracticeSessionRepository.submitAnswer failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<FinishPracticeSessionResult> finishSession({
    required String sessionId,
  }) async {
    try {
      final data = await _remoteService.finishPracticeSession(
        sessionId: sessionId,
      );
      return FinishPracticeSessionResult.fromJson(data);
    } on ApiException catch (e) {
      Logger.w(
        'PracticeSessionRepository.finishSession business failed: '
        'code=${e.code}, message=${e.message}, requestId=${e.requestId}',
      );
      rethrow;
    } catch (e, stackTrace) {
      Logger.e(
        'PracticeSessionRepository.finishSession failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<PracticeReportData> fetchReport({
    required String sessionId,
  }) async {
    try {
      final data = await _remoteService.getPracticeReport(
        sessionId: sessionId,
      );
      return PracticeReportData.fromJson(data);
    } on ApiException catch (e) {
      Logger.w(
        'PracticeSessionRepository.fetchReport business failed: '
        'code=${e.code}, message=${e.message}, requestId=${e.requestId}',
      );
      rethrow;
    } catch (e, stackTrace) {
      Logger.e(
        'PracticeSessionRepository.fetchReport failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
