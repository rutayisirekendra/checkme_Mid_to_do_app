import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? size;
  final EdgeInsetsGeometry? padding;

  const CustomIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.backgroundColor,
    this.iconColor,
    this.size,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: iconColor ?? (isDark ? AppColors.darkMainText : AppColors.lightMainText),
        size: size ?? 24,
      ),
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: backgroundColor ?? Colors.transparent,
        padding: padding ?? const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

