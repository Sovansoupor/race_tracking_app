import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracking_app/provider/segment/segment_provider.dart';
import 'package:race_tracking_app/screens/time%20tracker/widgets/participant_grid.dart';

class GridViewMode extends StatelessWidget {
  const GridViewMode({super.key});

  @override
  Widget build(BuildContext context) {
    final segmentProvider = context.watch<SegmentProvider>();
     final raceId = segmentProvider.currentRaceId;

    return Column(
      children: [
        Expanded(
          child: ParticipantGrid(
            showTrackedLabel: true,
            onParticipantTap: (bibNumber) {
              // Record the current elapsed time for this participant
              final elapsedTime = segmentProvider.raceElapsed;
              segmentProvider.recordParticipantTime(raceId!, bibNumber, elapsedTime);
            },
          ),
        ),
      ],
    );
  }
}
