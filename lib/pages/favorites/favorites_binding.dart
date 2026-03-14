import 'package:get/get.dart';

import '../../data/repositories/question_bank/practice_asset_repository.dart';
import '../../services/app_session_service.dart';
import '../../services/current_subject_service.dart';
import 'favorites_controller.dart';

class FavoritesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FavoritesController>(
      () => FavoritesController(
        Get.find<PracticeAssetRepository>(),
        Get.find<AppSessionService>(),
        Get.find<CurrentSubjectService>(),
      ),
    );
  }
}
