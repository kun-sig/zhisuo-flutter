import 'package:get/get.dart';
import 'package:zhisuo_flutter/data/repositories/home/home_repository.dart';
import 'package:zhisuo_flutter/data/repositories/subject/subject_repository.dart';

import 'tab_home_controller.dart';

class TabHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<TabHomeController>(
      TabHomeController(
        Get.find<HomeRepository>(),
        Get.find<SubjectRepository>(),
      ),
    );
  }
}
