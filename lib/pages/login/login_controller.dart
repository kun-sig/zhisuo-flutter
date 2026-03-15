import 'dart:async';

import 'package:get/get.dart';
import 'package:zhisuo_flutter/logger/logger.dart';
import 'package:zhisuo_flutter/routes/app_navigator.dart';

class LoginController extends GetxController {
  static LoginController get to => Get.find();
  static const bool _autoLogin = bool.fromEnvironment(
    'AUTO_LOGIN',
    defaultValue: false,
  );

  /// 登录状态
  final isLoggedIn = false.obs;
  bool get isLoggedInValue => isLoggedIn.value;

  /// 界面状态
  final isCodeMode = true.obs; // true=验证码登录，false=密码登录
  final phone = ''.obs;
  final password = ''.obs;
  final code = ''.obs;
  final isLoading = false.obs;

  /// 倒计时发送验证码
  final remainingSeconds = 0.obs;
  Timer? _countdownTimer;

  void switchMode() {
    isCodeMode.value = !isCodeMode.value;
  }

  void updatePhone(String v) => phone.value = v;
  void updatePassword(String v) => password.value = v;
  void updateCode(String v) => code.value = v;

  bool get canSendCode {
    return remainingSeconds.value == 0;
  }

  void sendCode() {
    if (!canSendCode) return;
    // mock send
    Logger.i('sending code to ${phone.value}');
    remainingSeconds.value = 60;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value -= 1;
      } else {
        t.cancel();
      }
    });
  }

  void submit() async {
    if (isLoading.value) return;
    isLoading.value = true;
    Logger.i('attempt login mode=${isCodeMode.value ? 'code' : 'pwd'}');
    await Future.delayed(const Duration(seconds: 1));
    // mock success
    isLoggedIn.value = true;
    isLoading.value = false;
    //Get.offAllNamed('/home');
    //AppNavigator.startSubjectPage();
    AppNavigator.startHomePage();
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    super.onClose();
  }

  @override
  void onReady() {
    super.onReady();
    Logger.d("LoginController is ready");
    // 仅在显式联调开关开启时自动提交登录，避免每次调试都手动点登录按钮。
    if (_autoLogin) {
      Future<void>.delayed(const Duration(milliseconds: 300), submit);
    }
  }
}
