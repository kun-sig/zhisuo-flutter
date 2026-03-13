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
        LocaleKeys.questionBankCurrentSubjectLabel: '当前科目',
        LocaleKeys.questionBankCurrentSubjectStatus: '已同步',
        LocaleKeys.questionBankCurrentSubjectEmpty: '暂未选择报考科目',
        LocaleKeys.questionBankCurrentSubjectHint: '通过科目页切换后，这里会同步展示当前题库科目。',
        LocaleKeys.questionBankCurrentSubjectReadyHint:
            '题库练习已按当前科目准备完成，可直接开始每日一练和专项练习。',
        LocaleKeys.questionBankCurrentSubjectCountdown: '考试倒计时',
        LocaleKeys.questionBankCurrentSubjectCountdownUnit: '天',
        LocaleKeys.questionBankCurrentSubjectSelect: '去选择',
        LocaleKeys.questionBankCurrentSubjectSwitch: '切换科目',
        LocaleKeys.studyCenterTab: '学习中心',
        LocaleKeys.discoverTab: '发现',
        LocaleKeys.mineTab: '我的',
      };
}
