import 'package:get/get.dart';
import 'package:zhisuo_flutter/pages/home/tab_home/tab_home_controller.dart';
import 'package:zhisuo_flutter/pages/home/tab_mine/tab_mine_controller.dart';
import 'package:zhisuo_flutter/pages/home/tab_question_bank/tab_question_bank_controller.dart';
import 'package:zhisuo_flutter/pages/home/tab_study_center/tab_study_center_controller.dart';

import 'home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<HomeController>(HomeController());
    Get.put<TabHomeController>(TabHomeController());
    Get.put<TabQuestionBankController>(TabQuestionBankController());
    Get.put<TabStudyCenterController>(TabStudyCenterController());
    Get.put<TabMineController>(TabMineController());
  }
}
