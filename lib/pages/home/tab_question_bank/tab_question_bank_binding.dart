import 'package:get/get.dart';

import '../../../services/service_controller.dart';
import 'tab_question_bank_controller.dart';

class TabQuestionBankBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<TabQuestionBankController>(
      TabQuestionBankController(Get.find<ServiceController>()),
    );
  }
}
