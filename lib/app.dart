import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zhisuo_flutter/data/local/app_database.dart';
import 'package:zhisuo_flutter/data/local/subject_local_data_source.dart';
import 'package:zhisuo_flutter/data/repositories/subject/subject_repository.dart';
import 'package:zhisuo_flutter/data/remote/subject_remote_service.dart';
import 'package:zhisuo_flutter/i18n/app_translations.dart';
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
    Get.put<ServiceController>(ServiceController(), permanent: true);
    Get.put<ThemeController>(ThemeController(), permanent: true);
  }
}
