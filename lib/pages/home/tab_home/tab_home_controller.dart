import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TabHomeController extends GetxController {
  final count = 10.obs;

  final pageController = PageController();
  final currentIndex = 0.obs;
  Timer? _timer;

  final banners = [
    BannerItem(
      image: "assets/images/banner1.jpg",
      title: "今日推荐课程",
      subtitle: "系统掌握 Flutter 企业级架构",
    ),
    BannerItem(
      image: "assets/images/banner2.jpg",
      title: "AI 编程实战",
      subtitle: "提升你的工程生产力",
    ),
    BannerItem(
      image: "assets/images/banner3.jpg",
      title: "算法强化训练",
      subtitle: "面试高频题专项突破",
    ),
  ];

  void onPageChanged(int index) {
    currentIndex.value = index;
  }

  @override
  void onInit() {
    super.onInit();
    _startAutoScroll();
  }

  @override
  void onClose() {
    _timer?.cancel();
    pageController.dispose();
    super.onClose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (banners.isEmpty) return;

      int nextPage = (currentIndex.value + 1) % banners.length;
      pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }
}

class BannerItem {
  final String image;
  final String title;
  final String subtitle;

  BannerItem({
    required this.image,
    required this.title,
    required this.subtitle,
  });
}
