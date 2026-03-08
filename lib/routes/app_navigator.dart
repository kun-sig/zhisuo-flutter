import 'package:get/get.dart';

import 'app_pages.dart';

class AppNavigator {
  AppNavigator._();
  static startSubjectPage() => Get.toNamed(AppRoutes.subject, arguments: {});
}
