import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zhisuo_flutter/logger/logger.dart';

class ServiceController extends GetxController with WidgetsBindingObserver {
  static ServiceController get to => Get.find();

  /// Mocks a login process
  final isLoggedIn = false.obs;
  bool get isLoggedInValue => isLoggedIn.value;

  @override
  void onInit() {
    super.onInit();
    Logger.d("ServiceController initialized");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addObserver(this);
    });
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  void login() {
    isLoggedIn.value = true;
  }

  void logout() {
    isLoggedIn.value = false;
  }

  /// 监听 App 生命周期变化
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        Logger.d("App 回到前台");
        break;
      case AppLifecycleState.inactive:
        Logger.d("App 处于非活动状态");
        break;
      case AppLifecycleState.paused:
        Logger.d("App 已经进入后台");
        break;
      case AppLifecycleState.detached:
        Logger.d("App 已被终止");
        break;
      case AppLifecycleState.hidden:
        Logger.d("App 被隐藏 (hidden)");
        break;
    }
  }
}
