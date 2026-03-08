import 'package:get/get.dart';
import 'package:zhisuo_flutter/routes/app_pages.dart';

class TabMineController extends GetxController {
  final userName = "张同学".obs;
  final email = "test@example.com".obs;
  final version = "".obs;

  @override
  void onInit() {
    _loadVersion();
    super.onInit();
  }

  void _loadVersion() async {}

  void logout() {
    Get.defaultDialog(
      title: "确认退出",
      middleText: "是否确认退出登录？",
      textConfirm: "退出",
      textCancel: "取消",
      onConfirm: () {
        Get.offAllNamed(AppRoutes.login);
        Get.snackbar("提示", "已安全退出");
      },
    );
  }
}
