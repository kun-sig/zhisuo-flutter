import 'package:get/get.dart';

import '../pages/home/home_binding.dart';
import '../pages/home/home_page.dart';
import '../pages/login/login_binding.dart';
import '../pages/login/login_page.dart';
import '../pages/splash/splash_binding.dart';
import '../pages/splash/splash_page.dart';
import '../pages/subject/subject_binding.dart';
import '../pages/subject/subject_page.dart';

part 'app_routes.dart';

class AppPages {
  static const initial = AppRoutes.splash;

  static _pageBuilder({
    required String name,
    required GetPageBuilder page,
    Bindings? binding,
    bool preventDuplicates = true,
    bool popGesture = true,
  }) =>
      GetPage(
        name: name,
        page: page,
        binding: binding,
        preventDuplicates: preventDuplicates,
        transition: Transition.cupertino,
        popGesture: popGesture,
      );
  static final routes = <GetPage>[
    _pageBuilder(
      name: AppRoutes.splash,
      page: () => SplashPage(),
      binding: SplashBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.login,
      page: () => LoginPage(),
      binding: LoginBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.home,
      page: () => HomePage(),
      binding: HomeBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.subject,
      page: () => SubjectPage(),
      binding: SubjectBinding(),
    )
  ];
}
