import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zhisuo_flutter/pages/home/tab_home/tab_home_page.dart';
import 'package:zhisuo_flutter/pages/home/tab_mine/tab_mine_page.dart';
import 'package:zhisuo_flutter/pages/home/tab_question_bank/tab_question_bank_page.dart';
import '../../i18n/locale_keys.dart';
import 'home_controller.dart';
import 'tab_study_center/tab_study_center_page.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = [
      const TabHomePage(),
      const TabQuestionBankPage(),
      const TabStudyCenterPage(),
      const TabMinePage(),
    ];

    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: pages,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: controller.currentIndex.value,
          onDestinationSelected: controller.changeTab,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: LocaleKeys.homeTab.tr,
            ),
            NavigationDestination(
              icon: Icon(Icons.library_books_outlined),
              selectedIcon: Icon(Icons.library_books),
              label: LocaleKeys.questionBankTab.tr,
            ),
            NavigationDestination(
              icon: Icon(Icons.school_outlined),
              selectedIcon: Icon(Icons.school),
              label: LocaleKeys.studyCenterTab.tr,
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: LocaleKeys.mineTab.tr,
            ),
          ],
        ),
      ),
    );
  }
}
