import 'package:flutter/material.dart';
import '../data/user_constants.dart';
import '../theme/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final bool showShadow;
  final Color? borderColor;

  const AppLogo({
    super.key,
    this.size = 44,
    this.borderRadius = 14,
    this.padding = const EdgeInsets.all(5),
    this.backgroundColor = Colors.white,
    this.showShadow = true,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? Colors.white.withValues(alpha: 0.85),
          width: 1.5,
        ),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: padding,
        child: Image.asset(
          appLogoUrl,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Icon(
            Icons.spa_rounded,
            color: AppColors.primary,
            size: size * 0.58,
          ),
        ),
      ),
    );
  }
}

