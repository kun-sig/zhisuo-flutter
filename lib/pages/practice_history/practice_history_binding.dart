import 'package:get/get.dart';

import '../../data/repositories/question_bank/practice_asset_repository.dart';
import '../../services/app_session_service.dart';
import '../../services/current_subject_service.dart';
import 'practice_history_controller.dart';

class PracticeHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PracticeHistoryController>(
      () => PracticeHistoryController(
        Get.find<PracticeAssetRepository>(),
        Get.find<AppSessionService>(),
        Get.find<CurrentSubjectService>(),
      ),
    );
  }
}
