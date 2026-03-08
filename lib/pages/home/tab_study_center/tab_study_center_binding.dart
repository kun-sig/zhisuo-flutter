import 'package:get/get.dart';

import 'tab_study_center_controller.dart';

class TabStudyCenterBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<TabStudyCenterController>(TabStudyCenterController());
  }
}
