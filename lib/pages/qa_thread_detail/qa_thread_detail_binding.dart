import 'package:get/get.dart';

import '../../data/repositories/question_bank/qa_thread_repository.dart';
import '../../services/app_session_service.dart';
import 'qa_thread_detail_controller.dart';

class QaThreadDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QaThreadDetailController>(
      () => QaThreadDetailController(
        Get.find<QaThreadRepository>(),
        Get.find<AppSessionService>(),
      ),
    );
  }
}
