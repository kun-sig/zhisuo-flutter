import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zhisuo_flutter/theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'login_controller.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),

                  /// 🔹 Logo
                  Center(
                    child: Image.asset(
                      'assets/images/logo.webp',
                      width: 88,
                      height: 88,
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 32),

                  /// 🔹 标题
                  Text(
                    "欢迎回来",
                    style: theme.textTheme.titleLarge?.copyWith(
                        color: AppColors.textPrimary.withValues(alpha: 0.8)),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 56),

                  /// 手机号
                  TextField(
                    keyboardType: TextInputType.phone,
                    maxLength: 11,
                    decoration: InputDecoration(
                      labelText: "手机号",
                      counterText: "",
                      prefix: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            Text(
                              "🇨🇳",
                              style: AppTextStyles.bodyLarge,
                            ),
                            SizedBox(width: 4),
                            Text(
                              "+86",
                              style: AppTextStyles.bodyLarge,
                            ),
                            SizedBox(width: 8),
                            SizedBox(
                              height: 18,
                              child: VerticalDivider(
                                thickness: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    onChanged: controller.updatePhone,
                  ),

                  const SizedBox(height: 28),

                  /// 密码 / 验证码
                  Obx(() {
                    if (controller.isCodeMode.value) {
                      return Row(
                        children: [
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.number,
                              decoration:
                                  const InputDecoration(labelText: "验证码"),
                              onChanged: controller.updateCode,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Obx(() {
                            final ready = controller.canSendCode;
                            final sec = controller.remainingSeconds.value;

                            return TextButton(
                              onPressed: ready ? controller.sendCode : null,
                              child: Text(
                                ready ? "发送验证码" : "$sec s",
                              ),
                            );
                          }),
                        ],
                      );
                    } else {
                      return TextField(
                        obscureText: true,
                        decoration: const InputDecoration(labelText: "密码"),
                        onChanged: controller.updatePassword,
                      );
                    }
                  }),

                  const SizedBox(height: 48),

                  /// 登录按钮
                  Obx(() {
                    return ElevatedButton(
                      onPressed:
                          controller.isLoading.value ? null : controller.submit,
                      child: controller.isLoading.value
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text("登录"),
                    );
                  }),

                  const SizedBox(height: 16),

                  /// 🔹 模式切换（保留）
                  Obx(() {
                    return TextButton(
                      onPressed: controller.switchMode,
                      child: Text(
                        controller.isCodeMode.value ? "使用密码登录" : "使用验证码登录",
                        style: AppTextStyles.caption,
                      ),
                    );
                  }),

                  const Spacer(),

                  /// 🔹 企业信息（固定底部）
                  Text(
                    "© ${DateTime.now().year} 深圳知索人工智能技术有限公司",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.black.withValues(alpha: 0.3),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
