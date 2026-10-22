import 'package:flutter/material.dart';
import '../models/job_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class StatusBadge extends StatelessWidget {
  final JobStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;

    switch (status) {
      case JobStatus.pendingOffers:
        bg = AppColors.orangeLight;
        fg = AppColors.orange;
        icon = Icons.hourglass_top_rounded;
        break;
      case JobStatus.scheduled:
        bg = AppColors.emeraldLight;
        fg = AppColors.emerald;
        icon = Icons.event_available_rounded;
        break;
      case JobStatus.proEnRoute:
        bg = const Color(0xFFEFF6FF);
        fg = const Color(0xFF2563EB);
        icon = Icons.directions_car_rounded;
        break;
      case JobStatus.inProgress:
        bg = const Color(0xFFF3E8FF);
        fg = const Color(0xFF7C3AED);
        icon = Icons.build_circle_rounded;
        break;
      case JobStatus.completed:
        bg = AppColors.emeraldLight;
        fg = AppColors.emerald;
        icon = Icons.verified_rounded;
        break;
      case JobStatus.released:
        bg = AppColors.emeraldLight;
        fg = AppColors.emerald;
        icon = Icons.task_alt_rounded;
        break;
      case JobStatus.cancelled:
        bg = const Color(0xFFFEE2E2);
        fg = AppColors.error;
        icon = Icons.cancel_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 5),
          Text(
            status.labelTr,
            style: AppTypography.label.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
