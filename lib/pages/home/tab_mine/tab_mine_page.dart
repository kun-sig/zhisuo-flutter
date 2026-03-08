import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'tab_mine_controller.dart';

class TabMinePage extends GetView<TabMineController> {
  const TabMinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fa),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildHeader(),
            const SizedBox(height: 24),
            _buildMenuCard(),
          ],
        ),
      ),
    );
  }

  /// 顶部用户卡片
  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 32,
            backgroundColor: Color(0xff2563eb),
            child: Icon(Icons.person, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => Text(
                    controller.userName.value,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600),
                  )),
              const SizedBox(height: 6),
              Obx(() => Text(
                    controller.email.value,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  )),
            ],
          )
        ],
      ),
    );
  }

  /// 菜单卡片
  Widget _buildMenuCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        children: [
          _menuItem(Icons.person_outline, "个人信息"),
          _divider(),
          _menuItem(Icons.security_outlined, "账号安全"),
          _divider(),
          _menuItem(Icons.settings_outlined, "系统设置"),
          _divider(),
          _menuItem(Icons.info_outline, "关于我们"),
          _divider(),
          _menuItem(Icons.logout_outlined, "退出登录", onTap: controller.logout),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, {VoidCallback? onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xfff1f5f9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: const Color(0xff334155)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.only(left: 70),
      child: Divider(
        height: 1,
        color: Colors.grey.shade200,
      ),
    );
  }
}
