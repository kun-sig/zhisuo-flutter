import 'package:get/get.dart';

import '../data/models/subject/subject_models.dart';
import '../data/repositories/subject/subject_repository.dart';
import '../logger/logger.dart';

/// 当前科目全局服务。
///
/// 统一维护题库上下文，避免多个页面重复持有 subject 状态。
class CurrentSubjectService extends GetxService {
  CurrentSubjectService(this._subjectRepository);

  final SubjectRepository _subjectRepository;

  final currentSubject = Rxn<SubjectItem>();
  final isLoading = false.obs;

  Future<void> refreshCurrentSubject() async {
    isLoading.value = true;
    try {
      currentSubject.value = await _subjectRepository.getLatestClickedSubject();
    } catch (e, stackTrace) {
      Logger.e(
        'CurrentSubjectService.refreshCurrentSubject failed',
        error: e,
        stackTrace: stackTrace,
      );
      currentSubject.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  void setCurrentSubject(SubjectItem subject) {
    currentSubject.value = subject;
  }

  void clearCurrentSubject() {
    currentSubject.value = null;
  }
}
