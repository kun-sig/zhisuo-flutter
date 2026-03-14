import 'package:get/get.dart';

/// 应用级会话上下文。
///
/// 当前登录体系尚未接入真实鉴权，默认使用联调种子用户。
class AppSessionService extends GetxService {
  static const String _defaultUserId = String.fromEnvironment(
    'APP_USER_ID',
    defaultValue: 'demo-user',
  );
  static const String _defaultPlatform = String.fromEnvironment(
    'APP_PLATFORM',
    defaultValue: 'phone',
  );

  final currentUserId = _defaultUserId.obs;

  String get userId {
    final value = currentUserId.value.trim();
    if (value.isEmpty) {
      return 'demo-user';
    }
    return value;
  }

  String get platform {
    final value = _defaultPlatform.trim();
    if (value.isEmpty) {
      return 'phone';
    }
    return value;
  }

  void updateUserId(String userId) {
    currentUserId.value = userId.trim();
  }
}
