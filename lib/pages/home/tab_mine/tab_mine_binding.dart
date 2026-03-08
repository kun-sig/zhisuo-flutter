import 'package:get/get.dart';

import 'tab_mine_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<TabMineController>(TabMineController());
  }
}
