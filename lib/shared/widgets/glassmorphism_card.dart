import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../../core/theme/app_colors.dart';

class GlassmorphismCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double borderRadius;
  final double blur;
  final double opacity;

  const GlassmorphismCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 24.0,
    this.blur = 15.0,
    this.opacity = 0.3,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: GlassmorphicContainer(
        width: width ?? double.infinity,
        height: height ?? 200,
        borderRadius: borderRadius,
        blur: blur,
        alignment: Alignment.bottomCenter,
        border: 3,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.white.withValues(alpha: opacity + 0.1),
            AppColors.white.withValues(alpha: opacity * 0.7),
            AppColors.white.withValues(alpha: opacity * 0.3),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.white.withValues(alpha: 0.5),
            AppColors.white.withValues(alpha: 0.2),
            AppColors.white.withValues(alpha: 0.1),
          ],
        ),
        child: Container(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

class GlassmorphismButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final double borderRadius;
  final double blur;
  final double opacity;

  const GlassmorphismButton({
    super.key,
    required this.child,
    this.onPressed,
    this.width,
    this.height,
    this.padding,
    this.borderRadius = 12.0,
    this.blur = 5.0,
    this.opacity = 0.3,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: GlassmorphicContainer(
        width: width ?? double.infinity,
        height: height ?? 50,
        borderRadius: borderRadius,
        blur: blur,
        alignment: Alignment.center,
        border: 1,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.white.withValues(alpha: opacity),
            AppColors.white.withValues(alpha: opacity * 0.5),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.white.withValues(alpha: 0.5),
            AppColors.white.withValues(alpha: 0.2),
          ],
        ),
        child: Container(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Center(child: child),
        ),
      ),
    );
  }
}
