import 'package:get/get.dart';

import '../../data/repositories/question_bank/practice_asset_repository.dart';
import '../../data/repositories/question_bank/practice_session_repository.dart';
import '../../services/app_session_service.dart';
import '../../services/current_subject_service.dart';
import 'practice_session_controller.dart';

class PracticeSessionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PracticeSessionController>(
      () => PracticeSessionController(
        Get.find<PracticeSessionRepository>(),
        Get.find<PracticeAssetRepository>(),
        Get.find<AppSessionService>(),
        Get.find<CurrentSubjectService>(),
      ),
    );
  }
}
