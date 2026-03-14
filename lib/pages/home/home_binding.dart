import 'package:get/get.dart';
import 'package:zhisuo_flutter/data/repositories/home/home_repository.dart';
import 'package:zhisuo_flutter/data/repositories/subject/subject_repository.dart';
import 'package:zhisuo_flutter/pages/home/tab_home/tab_home_controller.dart';
import 'package:zhisuo_flutter/pages/home/tab_mine/tab_mine_controller.dart';
import 'package:zhisuo_flutter/pages/home/tab_study_center/tab_study_center_controller.dart';
import 'package:zhisuo_flutter/pages/question_bank_dashboard/question_bank_dashboard_binding.dart';

import 'home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<HomeController>(HomeController());
    Get.put<TabHomeController>(
      TabHomeController(
        Get.find<HomeRepository>(),
        Get.find<SubjectRepository>(),
      ),
    );
    QuestionBankDashboardBinding().dependencies();
    Get.put<TabStudyCenterController>(TabStudyCenterController());
    Get.put<TabMineController>(TabMineController());
  }
}
