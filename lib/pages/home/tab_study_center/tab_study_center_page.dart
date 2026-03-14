import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import 'tab_study_center_controller.dart';

class TabStudyCenterPage extends GetView<TabStudyCenterController> {
  const TabStudyCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            /// =========================
            /// 📊 今日练习进度
            /// =========================
            _buildTodayProgress(theme),

            const SizedBox(height: 28),

            /// =========================
            /// 📚 模块分类
            /// =========================
            _buildSectionTitle("按模块练习"),
            const SizedBox(height: 16),
            _buildGridModules(),

            const SizedBox(height: 32),

            /// =========================
            /// 🎯 专项突破
            /// =========================
            _buildSectionTitle("专项突破"),
            const SizedBox(height: 16),
            ...List.generate(
              4,
              (index) => _buildSpecialItem(),
            ),
          ],
        ),
      ),
    );
  }

  /// =========================
  /// 今日进度
  /// =========================
  Widget _buildTodayProgress(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "今日练习",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildProgressBlock("已完成", "36题"),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildProgressBlock("正确率", "82%"),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressBlock(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  /// =========================
  /// 模块标题
  /// =========================
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// =========================
  /// 模块网格
  /// =========================
  Widget _buildGridModules() {
    final modules = [
      "行测",
      "申论",
      "资料分析",
      "数量关系",
      "判断推理",
      "常识判断",
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: modules.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.2,
      ),
      itemBuilder: (_, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            modules[index],
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      },
    );
  }

  /// =========================
  /// 专项突破
  /// =========================
  Widget _buildSpecialItem() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "高频错题专项突破训练",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.black38,
              )
            ],
          ),
        ),
      ),
    );
  }
}
