import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/activity_type.dart';
import '../../../core/utils/formatters.dart';

/// A single recent-activity row on the dashboard (mockup _3): type icon,
/// title/date, distance and duration.
class RecentActivityTile extends StatelessWidget {
  const RecentActivityTile({
    super.key,
    required this.activity,
    required this.onTap,
  });

  final ActivityRow activity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final type = ActivityType.fromId(activity.activityType);
    final started = DateTime.fromMillisecondsSinceEpoch(activity.startedAt);
    final title = activity.title.isNotEmpty
        ? activity.title
        : '${type.label} 운동';

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.surfaceContainerHigh,
                child: Icon(type.icon, color: AppColors.secondary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.bodyLg.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('M월 d일 HH:mm').format(started),
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${Formatters.distanceKm(activity.totalDistanceMeters)} km',
                    style: AppTypography.bodyLg.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    Formatters.duration(
                      Duration(seconds: activity.activeSeconds),
                    ),
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
