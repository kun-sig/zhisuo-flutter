import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zhisuo_flutter/pages/splash/splash_controller.dart';
import 'package:zhisuo_flutter/theme/app_colors.dart';

class SplashPage extends GetView<SplashController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 1200),
        tween: Tween(begin: 0, end: 1),
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: child,
          );
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                // 淡蓝色背景
                Colors.white,
                Colors.white,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(),

                // 中间品牌区
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.menu_book_rounded,
                      size: 100,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "智慧题库",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "智能做题 · 高效提升",
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Obx(
                      () {
                        if (controller.initErrorText.value.isNotEmpty) {
                          return Column(
                            children: [
                              Text(
                                controller.initErrorText.value,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.redAccent,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: controller.retryInitialize,
                                child: const Text('重试初始化'),
                              ),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              controller.isInitializing.value
                                  ? '正在初始化科目数据...'
                                  : '准备完成',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),

                // 底部公司信息
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Text(
                    "© ${DateTime.now().year} 深圳知索人工智能技术有限公司",
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
