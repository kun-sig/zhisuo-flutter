import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_extensions.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          surface: AppColors.surface,
          error: AppColors.error,
          onSurface: AppColors.textPrimary),
      scaffoldBackgroundColor: AppColors.background,
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),

      dividerColor: AppColors.divider,

      /// 统一圆角（全局）
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
      ),

      /// 输入框统一风格
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        floatingLabelStyle: TextStyle(
          color: AppColors.textPrimary, // 聚焦后颜色
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.divider),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 1),
        ),
      ),

      /// 按钮统一
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          elevation: const WidgetStatePropertyAll(0),
          minimumSize: const WidgetStatePropertyAll(
            Size.fromHeight(48),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
          ),
          foregroundColor: const WidgetStatePropertyAll(Colors.white),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.buttonDisabled;
            }
            if (states.contains(WidgetState.pressed)) {
              return AppColors.buttonPressed;
            }
            if (states.contains(WidgetState.hovered)) {
              return AppColors.buttonLight;
            }
            return AppColors.primary;
          }),
        ),
      ),

      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 64,
        backgroundColor: Colors.white,
        indicatorColor: AppColors.primary.withValues(alpha: 0.0),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.primary,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.black45,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              size: 24,
              color: AppColors.primary,
            );
          }
          return const IconThemeData(
            size: 24,
            color: Colors.black45,
          );
        }),
      ),
      extensions: const [
        AppExtraColors(
          vipColor: Color(0xFFFFC107),
          cardShadow: Color(0x1A000000),
        ),
      ],
    );
  }

  static ThemeData dark() {
    return light().copyWith(brightness: Brightness.dark);
  }
}
