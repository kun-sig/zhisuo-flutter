import 'package:get/get.dart';

class HomeController extends GetxController {
  static const int _initialHomeTab = int.fromEnvironment(
    'APP_INITIAL_HOME_TAB',
    defaultValue: 0,
  );

  final currentIndex = _sanitizeInitialTab(_initialHomeTab).obs;

  /// 只允许联调开关把首页初始 tab 落在合法范围内，避免非法值导致 IndexedStack 越界。
  static int _sanitizeInitialTab(int value) {
    if (value < 0 || value > 3) {
      return 0;
    }
    return value;
  }

  void changeTab(int index) {
    currentIndex.value = index;
  }
}
