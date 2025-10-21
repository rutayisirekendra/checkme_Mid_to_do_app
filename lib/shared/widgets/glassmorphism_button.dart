import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class GlassmorphismButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const GlassmorphismButton({
    super.key,
    required this.child,
    this.onPressed,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        height: height ?? 56,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: borderRadius ?? BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              (isDark ? AppColors.darkCard : AppColors.white).withValues(alpha: 0.2),
              (isDark ? AppColors.darkCard : AppColors.white).withValues(alpha: 0.1),
            ],
          ),
          border: Border.all(
            color: (isDark ? AppColors.darkMainText : AppColors.lightMainText).withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? AppColors.darkMainText : AppColors.lightMainText).withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}

