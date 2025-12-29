import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

@immutable
class AppDimens extends ThemeExtension<AppDimens> {
  const AppDimens({
    required this.space4,
    required this.space8,
    required this.space12,
    required this.space16,
    required this.space20,
    required this.space24,
    required this.space32,
    required this.radius8,
    required this.radius12,
    required this.radius16,
    required this.radius24,
  });

  final double space4;
  final double space8;
  final double space12;
  final double space16;
  final double space20;
  final double space24;
  final double space32;
  final double radius8;
  final double radius12;
  final double radius16;
  final double radius24;

  static const AppDimens defaults = AppDimens(
    space4: 4,
    space8: 8,
    space12: 12,
    space16: 16,
    space20: 20,
    space24: 24,
    space32: 32,
    radius8: 8,
    radius12: 12,
    radius16: 16,
    radius24: 24,
  );

  @override
  AppDimens copyWith({
    double? space4,
    double? space8,
    double? space12,
    double? space16,
    double? space20,
    double? space24,
    double? space32,
    double? radius8,
    double? radius12,
    double? radius16,
    double? radius24,
  }) {
    return AppDimens(
      space4: space4 ?? this.space4,
      space8: space8 ?? this.space8,
      space12: space12 ?? this.space12,
      space16: space16 ?? this.space16,
      space20: space20 ?? this.space20,
      space24: space24 ?? this.space24,
      space32: space32 ?? this.space32,
      radius8: radius8 ?? this.radius8,
      radius12: radius12 ?? this.radius12,
      radius16: radius16 ?? this.radius16,
      radius24: radius24 ?? this.radius24,
    );
  }

  @override
  AppDimens lerp(ThemeExtension<AppDimens>? other, double t) {
    if (other is! AppDimens) return this;
    return AppDimens(
      space4: lerpDouble(space4, other.space4, t)!,
      space8: lerpDouble(space8, other.space8, t)!,
      space12: lerpDouble(space12, other.space12, t)!,
      space16: lerpDouble(space16, other.space16, t)!,
      space20: lerpDouble(space20, other.space20, t)!,
      space24: lerpDouble(space24, other.space24, t)!,
      space32: lerpDouble(space32, other.space32, t)!,
      radius8: lerpDouble(radius8, other.radius8, t)!,
      radius12: lerpDouble(radius12, other.radius12, t)!,
      radius16: lerpDouble(radius16, other.radius16, t)!,
      radius24: lerpDouble(radius24, other.radius24, t)!,
    );
  }
}
