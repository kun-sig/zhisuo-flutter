import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zhisuo_flutter/data/local/app_database.dart';
import 'package:zhisuo_flutter/data/local/subject_local_data_source.dart';
import 'package:zhisuo_flutter/data/remote/asset_remote_service.dart';
import 'package:zhisuo_flutter/data/remote/catalog_remote_service.dart';
import 'package:zhisuo_flutter/data/remote/practice_remote_service.dart';
import 'package:zhisuo_flutter/data/remote/qa_thread_remote_service.dart';
import 'package:zhisuo_flutter/data/remote/question_bank_remote_service.dart';
import 'package:zhisuo_flutter/data/repositories/home/home_repository.dart';
import 'package:zhisuo_flutter/data/repositories/question_bank/practice_asset_repository.dart';
import 'package:zhisuo_flutter/data/repositories/question_bank/practice_session_repository.dart';
import 'package:zhisuo_flutter/data/repositories/question_bank/qa_thread_repository.dart';
import 'package:zhisuo_flutter/data/repositories/question_bank/question_bank_dashboard_repository.dart';
import 'package:zhisuo_flutter/data/repositories/subject/subject_repository.dart';
import 'package:zhisuo_flutter/data/remote/subject_remote_service.dart';
import 'package:zhisuo_flutter/i18n/app_translations.dart';
import 'package:zhisuo_flutter/services/app_session_service.dart';
import 'package:zhisuo_flutter/services/current_subject_service.dart';
import 'package:zhisuo_flutter/theme/theme_controller.dart';

import 'routes/app_pages.dart';
import 'services/http_service.dart';
import 'services/service_controller.dart';
import 'theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Application",
      debugShowCheckedModeBanner: false,
      initialBinding: InitBinding(),
      getPages: AppPages.routes,
      initialRoute: AppPages.initial,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      useInheritedMediaQuery: true,
      translations: AppTranslations(),
      locale: Get.deviceLocale,
      fallbackLocale: const Locale('zh', 'CN'),
    );
  }
}

class InitBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(HttpService(), permanent: true);
    Get.put(AppDatabase(), permanent: true);
    Get.put(SubjectLocalDataSource(Get.find<AppDatabase>()), permanent: true);
    Get.put(SubjectRemoteService(HttpService.to), permanent: true);
    Get.put(
      SubjectRepository(
        Get.find<SubjectLocalDataSource>(),
        Get.find<SubjectRemoteService>(),
      ),
      permanent: true,
    );
    Get.put(HomeRepository(HttpService.to), permanent: true);
    Get.put(CatalogRemoteService(HttpService.to), permanent: true);
    Get.put(AssetRemoteService(HttpService.to), permanent: true);
    Get.put(QaThreadRemoteService(HttpService.to), permanent: true);
    Get.put(PracticeRemoteService(HttpService.to), permanent: true);
    Get.put(QuestionBankRemoteService(HttpService.to), permanent: true);
    Get.put(
      PracticeAssetRepository(Get.find<AssetRemoteService>()),
      permanent: true,
    );
    Get.put(
      QaThreadRepository(Get.find<QaThreadRemoteService>()),
      permanent: true,
    );
    Get.put(
      QuestionBankDashboardRepository(Get.find<QuestionBankRemoteService>()),
      permanent: true,
    );
    Get.put(
      PracticeSessionRepository(Get.find<PracticeRemoteService>()),
      permanent: true,
    );
    Get.put<AppSessionService>(AppSessionService(), permanent: true);
    Get.put<CurrentSubjectService>(
      CurrentSubjectService(Get.find<SubjectRepository>()),
      permanent: true,
    );
    Get.put<ServiceController>(
      ServiceController(Get.find<CurrentSubjectService>()),
      permanent: true,
    );
    Get.put<ThemeController>(ThemeController(), permanent: true);
  }
}
