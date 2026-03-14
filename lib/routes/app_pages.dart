import 'package:get/get.dart';

import '../pages/favorites/favorites_binding.dart';
import '../pages/favorites/favorites_page.dart';
import '../pages/home/home_binding.dart';
import '../pages/home/home_page.dart';
import '../pages/login/login_binding.dart';
import '../pages/login/login_page.dart';
import '../pages/practice_history/practice_history_binding.dart';
import '../pages/practice_history/practice_history_page.dart';
import '../pages/practice_notes/practice_notes_binding.dart';
import '../pages/practice_notes/practice_notes_page.dart';
import '../pages/practice_report/practice_report_binding.dart';
import '../pages/practice_report/practice_report_page.dart';
import '../pages/practice_session/practice_session_binding.dart';
import '../pages/practice_session/practice_session_page.dart';
import '../pages/practice_unit_list/practice_unit_list_binding.dart';
import '../pages/practice_unit_list/practice_unit_list_page.dart';
import '../pages/splash/splash_binding.dart';
import '../pages/splash/splash_page.dart';
import '../pages/subject/subject_binding.dart';
import '../pages/subject/subject_page.dart';
import '../pages/wrong_book/wrong_book_binding.dart';
import '../pages/wrong_book/wrong_book_page.dart';

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
    ),
    _pageBuilder(
      name: AppRoutes.wrongBook,
      page: () => WrongBookPage(),
      binding: WrongBookBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.practiceHistory,
      page: () => PracticeHistoryPage(),
      binding: PracticeHistoryBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.favorites,
      page: () => FavoritesPage(),
      binding: FavoritesBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.practiceNotes,
      page: () => PracticeNotesPage(),
      binding: PracticeNotesBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.practiceUnitList,
      page: () => PracticeUnitListPage(),
      binding: PracticeUnitListBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.practiceSession,
      page: () => PracticeSessionPage(),
      binding: PracticeSessionBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.practiceReport,
      page: () => PracticeReportPage(),
      binding: PracticeReportBinding(),
    ),
  ];
}
