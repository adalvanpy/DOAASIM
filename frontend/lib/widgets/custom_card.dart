import 'package:flutter/material.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/app_dimensions.dart';
import '../../core/themes/app_text_styles.dart';

class CustomDashboardCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final Color iconColor;
  final Gradient gradient;

  const CustomDashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppDimensions.cardPadding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
        gradient: gradient,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTextStyle.cardTitle), // Usando seu estilo
              Icon(icon, color: iconColor, size: AppDimensions.iconSizeExtraLarge),
            ],
          ),
          Text(
            value.toString(), 
            style: AppTextStyle.cardValue, 
          ),
        ],
      ),
    );
  }
}