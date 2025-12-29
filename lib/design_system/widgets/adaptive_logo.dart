import 'package:flutter/material.dart';

class AdaptiveLogo extends StatelessWidget {

  const AdaptiveLogo({
    required this.lightAsset, required this.darkAsset, super.key,
    this.width,
    this.height,
    this.fit,
  });
  final String lightAsset;
  final String darkAsset;
  final double? width;
  final double? height;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final assetPath = isDark ? darkAsset : lightAsset;
    
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
    );
  }
}

class Logo1 extends StatelessWidget {

  const Logo1({
    super.key,
    this.width,
    this.height,
    this.fit,
  });
  final double? width;
  final double? height;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    return AdaptiveLogo(
      lightAsset: 'assets/ui/logo1_withoutbg.png',
      darkAsset: 'assets/ui/logo1_withoutbg.png',
      width: width,
      height: height,
      fit: fit,
    );
  }
}

class Logo2 extends StatelessWidget {

  const Logo2({
    super.key,
    this.width,
    this.height,
    this.fit,
  });
  final double? width;
  final double? height;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    return AdaptiveLogo(
      lightAsset: 'assets/ui/logo2_withoutbg.png',
      darkAsset: 'assets/ui/logo2_dark.png',
      width: width,
      height: height,
      fit: fit,
    );
  }
}
