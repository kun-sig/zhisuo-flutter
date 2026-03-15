import 'package:get/get.dart';

import '../../data/repositories/question_bank/practice_asset_repository.dart';
import '../../services/app_session_service.dart';
import '../../services/current_subject_service.dart';
import 'review_records_controller.dart';

class ReviewRecordsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReviewRecordsController>(
      () => ReviewRecordsController(
        Get.find<PracticeAssetRepository>(),
        Get.find<AppSessionService>(),
        Get.find<CurrentSubjectService>(),
      ),
    );
  }
}
