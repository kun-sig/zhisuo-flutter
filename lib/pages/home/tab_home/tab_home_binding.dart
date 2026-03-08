import 'package:get/get.dart';

import 'tab_home_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<TabHomeController>(TabHomeController());
  }
}
