import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracking_app/models/segment/segment.dart';
import 'package:race_tracking_app/provider/segment/segment_provider.dart';
import 'package:race_tracking_app/screens/time%20tracker/widgets/participant_grid.dart';
import 'package:race_tracking_app/theme/theme.dart';

class GridViewMode extends StatelessWidget {
  const GridViewMode({super.key});

  @override
  Widget build(BuildContext context) {
    final segmentProvider = context.watch<SegmentProvider>();
    final currentActivityType = segmentProvider.activityType;

    return Column(
      children: [
        // Activity type indicator
        // Padding(
        //   padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        //   child: Row(
        //     children: [
        //       Container(
        //         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        //         decoration: BoxDecoration(
        //           color: RaceColors.functional,
        //           borderRadius: BorderRadius.circular(16),
        //         ),
        //         child: Row(
        //           mainAxisSize: MainAxisSize.min,
        //           children: [
        //             Icon(
        //               currentActivityType.icon,
        //               color: RaceColors.white,
        //               size: 16,
        //             ),
        //             const SizedBox(width: 6),
        //             // Text(
        //             //   'Tracking ${currentActivityType.label}',
        //             //   style: RaceTextStyles.label.copyWith(
        //             //     color: RaceColors.white,
        //             //     fontWeight: FontWeight.bold,
        //             //   ),
        //             // ),
        //           ],
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        
        Expanded(
          child: ParticipantGrid(
            showTrackedLabel: true,
            onParticipantTap: (bibNumber) {
              // Record the current elapsed time for this participant
              final elapsedTime = segmentProvider.raceElapsed;
              segmentProvider.recordParticipantTime(bibNumber, elapsedTime);
              
            },
          ),
        ),
        
        // Segment completion indicator
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Builder(
            builder: (context) {
              final participantTimes = segmentProvider.currentSegmentParticipantTimes;
              final totalParticipants = segmentProvider.participantTimers.length;
              final trackedParticipants = participantTimes.length;
              final isSegmentComplete = totalParticipants > 0 && trackedParticipants == totalParticipants;
              
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: isSegmentComplete ? RaceColors.functional : RaceColors.neutralDark,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSegmentComplete ? Icons.check_circle : Icons.pending,
                      color: RaceColors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    // Text(
                    //   isSegmentComplete 
                    //       ? 'Segment Complete!' 
                    //       : 'Tracking: $trackedParticipants of $totalParticipants participants',
                    //   style: RaceTextStyles.label.copyWith(
                    //     color: RaceColors.white,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
