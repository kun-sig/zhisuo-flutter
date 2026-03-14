import 'package:get/get.dart';

import 'app_pages.dart';

class AppNavigator {
  AppNavigator._();

  static startHomePage({String? subjectId}) => Get.offAllNamed(
        AppRoutes.home,
        arguments: {
          if (subjectId != null && subjectId.trim().isNotEmpty)
            'subjectId': subjectId.trim(),
        },
      );

  static startSubjectPage() => Get.toNamed(AppRoutes.subject, arguments: {});
  static startWrongBookPage() => Get.toNamed(AppRoutes.wrongBook);
  static startPracticeHistoryPage() => Get.toNamed(AppRoutes.practiceHistory);
  static startFavoritesPage() => Get.toNamed(AppRoutes.favorites);
  static startPracticeNotesPage() => Get.toNamed(AppRoutes.practiceNotes);
  static startPracticeUnitListPage({
    required String categoryCode,
    String? categoryName,
  }) =>
      Get.toNamed(
        AppRoutes.practiceUnitList,
        arguments: {
          'categoryCode': categoryCode.trim(),
          if (categoryName != null && categoryName.trim().isNotEmpty)
            'categoryName': categoryName.trim(),
        },
      );
  static startPracticeSessionPage({
    String? sessionId,
    String? categoryCode,
    String? unitId,
    String? unitTitle,
    bool continueIfExists = true,
    int? questionCount,
  }) =>
      Get.toNamed(
        AppRoutes.practiceSession,
        arguments: {
          if (sessionId != null && sessionId.trim().isNotEmpty)
            'sessionId': sessionId.trim(),
          if (categoryCode != null && categoryCode.trim().isNotEmpty)
            'categoryCode': categoryCode.trim(),
          if (unitId != null && unitId.trim().isNotEmpty)
            'unitId': unitId.trim(),
          if (unitTitle != null && unitTitle.trim().isNotEmpty)
            'unitTitle': unitTitle.trim(),
          'continueIfExists': continueIfExists,
          if (questionCount != null && questionCount > 0)
            'questionCount': questionCount,
        },
      );
  static startPracticeReportPage({
    required String sessionId,
    String? categoryCode,
    String? unitId,
    String? unitTitle,
    bool replace = true,
  }) =>
      replace
          ? Get.offNamed(
              AppRoutes.practiceReport,
              arguments: {
                'sessionId': sessionId.trim(),
                if (categoryCode != null && categoryCode.trim().isNotEmpty)
                  'categoryCode': categoryCode.trim(),
                if (unitId != null && unitId.trim().isNotEmpty)
                  'unitId': unitId.trim(),
                if (unitTitle != null && unitTitle.trim().isNotEmpty)
                  'unitTitle': unitTitle.trim(),
              },
            )
          : Get.toNamed(
              AppRoutes.practiceReport,
              arguments: {
                'sessionId': sessionId.trim(),
                if (categoryCode != null && categoryCode.trim().isNotEmpty)
                  'categoryCode': categoryCode.trim(),
                if (unitId != null && unitId.trim().isNotEmpty)
                  'unitId': unitId.trim(),
                if (unitTitle != null && unitTitle.trim().isNotEmpty)
                  'unitTitle': unitTitle.trim(),
              },
            );
}
