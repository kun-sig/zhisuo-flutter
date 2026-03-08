import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:zhisuo_flutter/logger/logger.dart';

class ThemeController extends GetxController {
  final _mode = ThemeMode.light.obs;

  ThemeMode get mode => _mode.value;
  @override
  void onInit() {
    super.onInit();
    Logger.d("ThemeController initialized with mode: ${_mode.value}");
  }

  void toggle() {
    _mode.value =
        _mode.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    Get.changeThemeMode(_mode.value);
  }
}
