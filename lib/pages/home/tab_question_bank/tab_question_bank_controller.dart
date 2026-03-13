import 'package:get/get.dart';

import '../../../data/models/subject/subject_models.dart';
import '../../../services/service_controller.dart';

class TabQuestionBankController extends GetxController {
  TabQuestionBankController(this._serviceController);

  final ServiceController _serviceController;

  final currentTab = 0.obs;
  final searchText = "".obs;

  // 日历示例
  final selectedDate = DateTime.now().obs;

  // 模拟每日练习数据
  final dailyPracticeDays = <int>[23, 24, 25, 26, 27, 28, 29].obs;
  // 模拟专项练习
  final practiceItems = [
    {"title": "绪论（信息与信息系统）", "total": 3, "done": 0},
    {"title": "数学与工程基础", "total": 75, "done": 0},
    {"title": "计算机系统", "total": 138, "done": 0},
    {"title": "计算机网络", "total": 98, "done": 0},
    {"title": "数据库系统", "total": 66, "done": 0},
  ].obs;

  Rxn<SubjectItem> get currentSubject => _serviceController.currentSubject;
  RxBool get isCurrentSubjectLoading =>
      _serviceController.isCurrentSubjectLoading;

  String get examCountdownText {
    final days = _examCountdownDays;
    if (days == null) {
      return '--';
    }
    return days <= 0 ? '0' : '$days';
  }

  int? get _examCountdownDays {
    final subject = currentSubject.value;
    if (subject == null || subject.name.trim().isEmpty) {
      return null;
    }
    final examDate = _resolveEstimatedExamDate(subject.name);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(examDate.year, examDate.month, examDate.day);
    return target.difference(today).inDays;
  }

  DateTime _resolveEstimatedExamDate(String subjectName) {
    final normalizedName = subjectName.trim();

    if (normalizedName.contains('教师资格')) {
      return _resolveNextAnnualDate(const [
        [3, 15],
        [11, 1],
      ]);
    }
    if (normalizedName.contains('软考') ||
        normalizedName.contains('软件设计师') ||
        normalizedName.contains('系统架构')) {
      return _resolveNextAnnualDate(const [
        [5, 23],
        [11, 7],
      ]);
    }
    if (normalizedName.contains('公务员') || normalizedName.contains('国考')) {
      return _resolveNextAnnualDate(const [
        [11, 29],
      ]);
    }
    return _resolveNextAnnualDate(const [
      [11, 8],
    ]);
  }

  DateTime _resolveNextAnnualDate(List<List<int>> monthDays) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    for (final item in monthDays) {
      final candidate = DateTime(now.year, item[0], item[1]);
      if (!candidate.isBefore(today)) {
        return candidate;
      }
    }
    final first = monthDays.first;
    return DateTime(now.year + 1, first[0], first[1]);
  }
}
