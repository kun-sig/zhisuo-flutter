import 'locale_keys.dart';

class EnUS {
  static const appName = 'ZhiSuo Learning';
  static const authLogin = 'Login';
  static const authWelcome = 'Welcome Back';
  static const authPhone = 'Phone';
  static const authPassword = 'Password';
  static const authForgotPassword = 'Forgot Password?';
  static const authNoAccount = 'No account?';
  static const authSignUp = 'Sign Up';

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
        LocaleKeys.homeTab: 'Home',
        LocaleKeys.questionBankTab: 'Question Bank',
        LocaleKeys.questionBankCurrentSubjectLabel: 'Current Subject',
        LocaleKeys.questionBankCurrentSubjectStatus: 'Synced',
        LocaleKeys.questionBankCurrentSubjectEmpty: 'No exam subject selected',
        LocaleKeys.questionBankCurrentSubjectHint:
            'After switching from Subject page, the current question-bank subject will appear here.',
        LocaleKeys.questionBankCurrentSubjectReadyHint:
            'Practice content is ready for the selected subject. You can start daily and focused practice directly.',
        LocaleKeys.questionBankCurrentSubjectCountdown: 'Exam Countdown',
        LocaleKeys.questionBankCurrentSubjectCountdownUnit: 'days',
        LocaleKeys.questionBankCurrentSubjectSelect: 'Choose',
        LocaleKeys.questionBankCurrentSubjectSwitch: 'Switch Subject',
        LocaleKeys.studyCenterTab: 'Study Center',
        LocaleKeys.discoverTab: 'Discover',
        LocaleKeys.mineTab: 'Mine',
      };
}
