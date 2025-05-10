import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracking_app/provider/segment/segment_provider.dart';
import 'package:race_tracking_app/screens/time%20tracker/widgets/participant_grid.dart';

class GridViewMode extends StatelessWidget {
  const GridViewMode({super.key});

  @override
  Widget build(BuildContext context) {
    final segmentProvider = context.watch<SegmentProvider>();
    
    return Column(
      children: [
        Expanded(
          child: ParticipantGrid(
            showTrackedLabel: false,
            onParticipantTap: (index) {
              segmentProvider.toggleSegmentTracking(index);
            },
          ),
        ),
      ],
    );
  }
}