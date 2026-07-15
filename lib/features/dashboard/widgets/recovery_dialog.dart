import 'package:flutter/material.dart';

import '../../../core/utils/activity_type.dart';
import '../../../core/utils/formatters.dart';

/// User choice when an interrupted recording is detected (spec §14).
enum RecoveryChoice { resume, saveAndEnd, discard }

/// Shows the recovery prompt for an unfinished activity.
Future<RecoveryChoice?> showRecoveryDialog(
  BuildContext context, {
  required ActivityType activityType,
  required double distanceMeters,
}) {
  return showDialog<RecoveryChoice>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: const Text('진행 중이던 운동이 있어요'),
      content: Text(
        '${activityType.label} · ${Formatters.distanceKm(distanceMeters)} km 까지 '
        '기록되어 있습니다. 어떻게 할까요?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, RecoveryChoice.discard),
          child: const Text('삭제'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, RecoveryChoice.saveAndEnd),
          child: const Text('저장하고 종료'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, RecoveryChoice.resume),
          child: const Text('계속하기'),
        ),
      ],
    ),
  );
}
