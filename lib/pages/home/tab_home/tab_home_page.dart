import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import 'tab_home_controller.dart';

class TabHomePage extends GetView<TabHomeController> {
  const TabHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          /// =========================
          /// 🔥 顶部轮播
          /// =========================
          SizedBox(
            height: 220,
            child: PageView.builder(
              controller: controller.pageController,
              onPageChanged: controller.onPageChanged,
              itemCount: controller.banners.length,
              itemBuilder: (context, index) {
                final item = controller.banners[index];

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      item.image,
                      fit: BoxFit.cover,
                      errorBuilder: (BuildContext context, Object error,
                          StackTrace? stackTrace) {
                        return SizedBox.shrink();
                      },
                    ),

                    /// 渐变遮罩
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.8),
                            AppColors.secondary.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                    ),

                    /// 文本
                    Positioned(
                      left: 20,
                      bottom: 30,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.subtitle,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          /// =========================
          /// 🔵 指示器
          /// =========================
          Obx(() {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                controller.banners.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: controller.currentIndex.value == index ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: controller.currentIndex.value == index
                        ? AppColors.secondary
                        : AppColors.secondary.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 24),

          /// =========================
          /// 📰 下半部分滚动区域
          /// =========================
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                /// 标题
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "最新资讯",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                /// 新闻列表
                ...List.generate(
                  8,
                  (index) => _buildNewsItem(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// =========================
  /// 📰 纯文字新闻 Item
  /// =========================
  Widget _buildNewsItem() {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 标题
            const Text(
              "行测高频考点分析：资料分析必考题型总结与核心技巧解析",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 10),

            /// 标签 + 时间 + 阅读量
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  "高频考点",
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 14),
                const Text(
                  "2小时前",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "阅读 2.3k",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black38,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            /// 分割线
            Container(
              height: 0.5,
              color: Colors.black.withValues(alpha: 0.06),
            ),
          ],
        ),
      ),
    );
  }
}
