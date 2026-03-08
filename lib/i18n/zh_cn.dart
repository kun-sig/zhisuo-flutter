import 'locale_keys.dart';

class ZhCN {
  static const appName = '知所学习';
  static const authLogin = '登录';
  static const authWelcome = '欢迎回来';
  static const authPhone = '手机号';
  static const authPassword = '密码';
  static const authForgotPassword = '忘记密码?';
  static const authNoAccount = '没有账号?';
  static const authSignUp = '注册';

  static Map<String, String> toMap() => {
        LocaleKeys.appName: appName,
        LocaleKeys.authLogin: authLogin,
        LocaleKeys.authWelcome: authWelcome,
        LocaleKeys.authPhone: authPhone,
        LocaleKeys.authPassword: authPassword,
        LocaleKeys.authForgotPassword: authForgotPassword,
        LocaleKeys.authNoAccount: authNoAccount,
        LocaleKeys.authSignUp: authSignUp,

        // tabs
        LocaleKeys.homeTab: '首页',
        LocaleKeys.questionBankTab: '题库',
        LocaleKeys.studyCenterTab: '学习中心',
        LocaleKeys.discoverTab: '发现',
        LocaleKeys.mineTab: '我的',
      };
}
