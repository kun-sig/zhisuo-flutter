import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import 'tab_question_bank_controller.dart';

class TabQuestionBankPage extends GetView<TabQuestionBankController> {
  const TabQuestionBankPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          // 增加 physics 确保滚动顺畅
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            /// 🔹 1. 每日一练卡片
            _buildDailyPracticeCard(),

            const SizedBox(height: 16),

            /// 🔹 2. 测试练习大板块
            _buildTestExerciseSection(),

            const SizedBox(height: 20),

            /// 🔹 3. 专项练习标题
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                "专项练习",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            /// 🔹 4. 专项练习列表
            Obx(() => ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.practiceItems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, index) {
                    final item = controller.practiceItems[index];
                    return _buildPracticeCard(item);
                  },
                )),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyPracticeCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // 添加错误处理，防止图片加载失败导致红屏
                    Icon(Icons.edit_note, color: Color(0xFF1E56F0)),
                    const SizedBox(width: 8),
                    const Text(
                      "每日一练",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E56F0),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // 使用 Obx 包装日历行，使其响应 Controller 数据
                Obx(() => _buildCalendarRow()),
              ],
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFF2B67F6),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(24),
                ),
              ),
              child: const Text(
                "立即打卡",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestExerciseSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("测试练习",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            // 使用 GridView.builder 或固定 count 并关闭滚动
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.3, // 稍微调大比例防止溢出
              ),
              children: [
                _buildGridItem("知识点练习", Colors.purple, Icons.lightbulb_outline),
                _buildGridItem("模拟试卷", Colors.blue, Icons.description_outlined),
                _buildGridItem("章节练习", Colors.green, Icons.menu_book_outlined),
                _buildGridItem("历年真题", Colors.pink, Icons.history_edu_outlined),
                _buildGridItem("高频考点", Colors.indigo, Icons.trending_up),
                _buildGridItem("高频错题", Colors.orange, Icons.cancel_outlined),
              ],
            ),
            const SizedBox(height: 20),
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.5,
              ),
              children: [
                _buildSmallItem("错题本", Icons.close, Colors.orange),
                _buildSmallItem("做题记录", Icons.bookmark_outline, Colors.orange),
                _buildSmallItem("批改记录", Icons.edit_outlined, Colors.orange),
                _buildSmallItem("试题收藏", Icons.star_border, Colors.orange),
                _buildSmallItem(
                    "做题笔记", Icons.assignment_outlined, Colors.orange),
                _buildSmallItem(
                    "做题问答", Icons.question_answer_outlined, Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPracticeCard(Map<String, dynamic> item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item["title"] ?? "",
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Text(
                    "总数 ${item["total"] ?? 0}  已做 ${item["done"] ?? 0}  正确率 0%",
                    style:
                        const TextStyle(fontSize: 11, color: Colors.black54)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E56F0),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              minimumSize: const Size(70, 32),
            ),
            child: const Text("去练习", style: TextStyle(fontSize: 12)),
          )
        ],
      ),
    );
  }

  Widget _buildGridItem(String title, Color themeColor, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(title,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: themeColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: themeColor, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallItem(String title, IconData icon, Color iconColor) {
    return Container(
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 12, color: iconColor),
          const SizedBox(width: 2),
          Text(title,
              style: const TextStyle(fontSize: 11, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildCalendarRow() {
    final List<String> weekDays = ["一", "二", "三", "四", "五", "六", "日"];
    // 真正使用 controller 中的数据
    final days = controller.dailyPracticeDays;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(weekDays.length, (index) {
        final day = days[index];
        // 假设今天是 1 号（或者根据实际 DateTime.now().day 判断）
        final isToday = day == DateTime.now().day;

        return Column(
          children: [
            Text(weekDays[index],
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
            const SizedBox(height: 8),
            Container(
              width: 30,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isToday ? const Color(0xFF1E56F0) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    day.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isToday ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    width: 3,
                    height: 3,
                    decoration: BoxDecoration(
                      color: isToday ? Colors.white : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
