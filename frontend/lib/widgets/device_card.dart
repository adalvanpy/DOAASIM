import 'package:flutter/material.dart';
import '../models/aparelhos.dart';
import '../core/themes/app_colors.dart';
import '../core/themes/app_dimensions.dart';
import '../core/themes/app_text_styles.dart';
import '../utils/status_helper.dart';

class DeviceCard extends StatelessWidget {
  final Device aparelho;
  final bool isAdmin;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onTap;
  final bool showActions;
  
  const DeviceCard({
    super.key,
    required this.aparelho,
    this.isAdmin = false,
    this.onApprove,
    this.onReject,
    this.onTap,
    this.showActions = true,
  });
  
  bool get isPending => aparelho.status.toUpperCase() == 'AGUARDANDO';
  bool get isApproved => aparelho.status.toUpperCase() == 'DISPONIVEL';
  bool get isDonated => aparelho.status.toUpperCase() == 'DOADO';
  
  @override
  Widget build(BuildContext context) {
    final statusColor = StatusHelper.getAparelhoStatusColor(aparelho.status);
    
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
          aparelho.nome,
          style: AppTextStyle.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppDimensions.spacingXS),
            Text(
              '${aparelho.modeloDisplay} • ${aparelho.perdaDisplay}',
              style: AppTextStyle.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXS),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingSM,
                vertical: AppDimensions.spacingXS,
              ),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                StatusHelper.getStatusDisplay(aparelho.status),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
        trailing: showActions && isAdmin && isPending
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green, size: 24),
                    onPressed: onApprove,
                    tooltip: 'Aprovar aparelho',
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red, size: 24),
                    onPressed: onReject,
                    tooltip: 'Reprovar aparelho',
                  ),
                ],
              )
            : const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}