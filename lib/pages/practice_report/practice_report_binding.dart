import 'package:get/get.dart';

import '../../data/repositories/question_bank/practice_session_repository.dart';
import 'practice_report_controller.dart';

class PracticeReportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PracticeReportController>(
      () => PracticeReportController(
        Get.find<PracticeSessionRepository>(),
      ),
    );
  }
}
