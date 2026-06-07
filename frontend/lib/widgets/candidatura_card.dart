import 'package:flutter/material.dart';
import '../models/candidatura.dart';
import '../core/themes/app_colors.dart';
import '../core/themes/app_dimensions.dart';
import '../core/themes/app_text_styles.dart';
import '../utils/status_helper.dart';

class CandidaturaCard extends StatelessWidget {
  final Candidatura candidatura;
  final VoidCallback? onTap;
  
  const CandidaturaCard({
    super.key,
    required this.candidatura,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final statusColor = StatusHelper.getCandidaturaStatusColor(candidatura.status);
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingSM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingLG,
          vertical: AppDimensions.spacingMD,
        ),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.hearing,
            size: 28,
            color: AppColors.primary,
          ),
        ),
        title: Text(
          candidatura.aparelhoNome,
          style: AppTextStyle.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Container(
          margin: const EdgeInsets.only(top: AppDimensions.spacingXS),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingSM,
            vertical: AppDimensions.spacingXS,
          ),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            StatusHelper.getStatusDisplay(candidatura.status),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: statusColor,
            ),
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}