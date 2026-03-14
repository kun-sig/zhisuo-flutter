import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:zhisuo_flutter/data/models/subject/subject_models.dart';
import 'package:zhisuo_flutter/i18n/app_translations.dart';
import 'package:zhisuo_flutter/services/app_session_service.dart';
import 'package:zhisuo_flutter/services/current_subject_service.dart';

/// 初始化 GetX 测试环境，统一注入多语言和路由参数上下文。
void configureGetTest({
  Object? arguments,
}) {
  TestWidgetsFlutterBinding.ensureInitialized();
  Get.testMode = true;
  Get.reset();
  Get.clearTranslations();
  Get.addTranslations(AppTranslations().keys);
  Get.locale = const Locale('zh', 'CN');
  Get.fallbackLocale = const Locale('zh', 'CN');
  Get.routing.args = arguments;
}

/// 清理 GetX 测试状态，避免不同用例之间相互污染。
void disposeGetTest() {
  Get.routing.args = null;
  Get.reset();
  Get.clearTranslations();
}

/// 等待 controller 的异步初始化链路执行完成。
Future<void> pumpController() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

/// 构造最小可用的科目数据，供 dashboard / 练习链路测试复用。
SubjectItem buildSubject({
  String id = 'subject-1',
  String name = '软件设计师',
}) {
  return SubjectItem(
    id: id,
    subjectCategoryId: 'category-1',
    subjectTagId: 'tag-1',
    name: name,
    description: '',
    order: 1,
  );
}

/// 轻量会话服务替身，仅维护测试需要的用户和平台上下文。
class FakeAppSessionService extends GetxService implements AppSessionService {
  FakeAppSessionService({
    String userId = 'demo-user',
    this.platformValue = 'phone',
  }) : currentUserId = userId.obs;

  @override
  final RxString currentUserId;

  final String platformValue;

  @override
  String get platform => platformValue;

  @override
  String get userId {
    final value = currentUserId.value.trim();
    if (value.isEmpty) {
      return 'demo-user';
    }
    return value;
  }

  @override
  void updateUserId(String userId) {
    currentUserId.value = userId.trim();
  }
}

/// 轻量当前科目服务替身，仅暴露 controller 测试所需的响应式状态。
class FakeCurrentSubjectService extends GetxService
    implements CurrentSubjectService {
  FakeCurrentSubjectService({
    SubjectItem? subject,
  }) : currentSubject = Rxn<SubjectItem>(subject);

  @override
  final Rxn<SubjectItem> currentSubject;

  @override
  final RxBool isLoading = false.obs;

  @override
  void clearCurrentSubject() {
    currentSubject.value = null;
  }

  @override
  Future<void> refreshCurrentSubject() async {}

  @override
  void setCurrentSubject(SubjectItem subject) {
    currentSubject.value = subject;
  }
}
