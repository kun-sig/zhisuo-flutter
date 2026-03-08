import 'package:get/get.dart';
import 'package:zhisuo_flutter/data/repositories/subject/subject_repository.dart';
import 'package:zhisuo_flutter/logger/logger.dart';

import 'subject_controller.dart';

class SubjectBinding extends Bindings {
  @override
  void dependencies() {
    Logger.d('SubjectBinding dependencies');
    Get.put<SubjectController>(
        SubjectController(Get.find<SubjectRepository>()));
  }
}
