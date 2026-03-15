import 'package:get/get.dart';

import '../../data/repositories/question_bank/qa_thread_repository.dart';
import '../../services/app_session_service.dart';
import '../../services/current_subject_service.dart';
import 'qa_threads_controller.dart';

class QaThreadsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QaThreadsController>(
      () => QaThreadsController(
        Get.find<QaThreadRepository>(),
        Get.find<AppSessionService>(),
        Get.find<CurrentSubjectService>(),
      ),
    );
  }
}
