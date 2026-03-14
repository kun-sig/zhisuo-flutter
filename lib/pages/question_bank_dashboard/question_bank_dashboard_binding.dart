import 'package:get/get.dart';

import '../../data/repositories/question_bank/question_bank_dashboard_repository.dart';
import '../../services/app_session_service.dart';
import '../../services/current_subject_service.dart';
import 'question_bank_dashboard_controller.dart';

class QuestionBankDashboardBinding extends Bindings {
  @override
  void dependencies() {
    if (Get.isRegistered<QuestionBankDashboardController>()) {
      return;
    }
    Get.put<QuestionBankDashboardController>(
      QuestionBankDashboardController(
        Get.find<QuestionBankDashboardRepository>(),
        Get.find<CurrentSubjectService>(),
        Get.find<AppSessionService>(),
      ),
    );
  }
}
