import 'package:get/get.dart';

class TabQuestionBankController extends GetxController {
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
}
