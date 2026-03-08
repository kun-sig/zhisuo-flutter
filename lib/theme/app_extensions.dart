import 'package:flutter/material.dart';

@immutable
class AppExtraColors extends ThemeExtension<AppExtraColors> {
  final Color vipColor;
  final Color cardShadow;

  const AppExtraColors({
    required this.vipColor,
    required this.cardShadow,
  });

  @override
  AppExtraColors copyWith({
    Color? vipColor,
    Color? cardShadow,
  }) {
    return AppExtraColors(
      vipColor: vipColor ?? this.vipColor,
      cardShadow: cardShadow ?? this.cardShadow,
    );
  }

  @override
  AppExtraColors lerp(ThemeExtension<AppExtraColors>? other, double t) {
    if (other is! AppExtraColors) return this;
    return AppExtraColors(
      vipColor: Color.lerp(vipColor, other.vipColor, t)!,
      cardShadow: Color.lerp(cardShadow, other.cardShadow, t)!,
    );
  }
}
