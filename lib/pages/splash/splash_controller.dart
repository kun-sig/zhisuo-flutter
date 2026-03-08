import 'package:get/get.dart';
import 'package:zhisuo_flutter/data/repositories/subject/subject_repository.dart';
import 'package:zhisuo_flutter/logger/logger.dart';

import '../../routes/app_pages.dart';

class SplashController extends GetxController {
  final isInitializing = true.obs;
  final initErrorText = ''.obs;

  bool _navigated = false;

  @override
  void onInit() {
    super.onInit();
    Logger.d("SplashController initialized");
  }

  @override
  void onReady() {
    super.onReady();

    Logger.d("SplashController onReady");
    _initialize();
  }

  Future<void> retryInitialize() async {
    await _initialize();
  }

  Future<void> _initialize() async {
    if (_navigated) {
      return;
    }
    isInitializing.value = true;
    initErrorText.value = '';

    try {
      await Get.find<SubjectRepository>().initializeSubjectData();
      _goNext();
    } catch (e, stackTrace) {
      Logger.e('Splash initialize subject data failed',
          error: e, stackTrace: stackTrace);
      initErrorText.value = '初始化失败，请检查后端服务后重试';
    } finally {
      isInitializing.value = false;
    }
  }

  void _goNext() {
    if (_navigated) return;
    _navigated = true;

    Logger.i("Splash -> Login");

    Get.offAllNamed(AppRoutes.login);
  }

  @override
  void onClose() {
    Logger.d("SplashController disposed");
    super.onClose();
  }
}
