import 'package:get/get.dart';

import '../../data/repositories/question_bank/question_bank_dashboard_repository.dart';
import '../../services/app_session_service.dart';
import '../../services/current_subject_service.dart';
import 'practice_unit_list_controller.dart';

class PracticeUnitListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PracticeUnitListController>(
      () => PracticeUnitListController(
        Get.find<QuestionBankDashboardRepository>(),
        Get.find<AppSessionService>(),
        Get.find<CurrentSubjectService>(),
      ),
    );
  }
}
