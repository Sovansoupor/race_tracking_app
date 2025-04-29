import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracking_app/provider/participant%20provider/participant_provider.dart';
import 'package:race_tracking_app/provider/segment/segment_provider.dart';
import 'package:race_tracking_app/theme/theme.dart';

class GridViewMode extends StatelessWidget {
  const GridViewMode({super.key});

  @override
  Widget build(BuildContext context) {
    final participantProvider = context.watch<ParticipantProvider>();
    final segmentProvider = context.watch<SegmentProvider>();
    final currentSegment = segmentProvider.activityType;

    if (participantProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final allParticipants = participantProvider.participantState!.data!;
    if (allParticipants.isEmpty) {
      return Center(
        child: Text(
          'No participants available.',
          style: RaceTextStyles.label.copyWith(color: RaceColors.white),
        ),
      );
    }


    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: allParticipants.length,
      itemBuilder: (context, int index) {
        final participant = allParticipants[index];

        final Duration? time = participant.segmentTimes[currentSegment];
        final bool isTracked = time != null;
        return GestureDetector(
          onTap: () {
            // Handle individual tracking logic here
            // if (!isTracked) {
            //   participantProvider.trackTime(
            //     participantId: allParticipants.elementAt(index).id,
            //     segmentKey: currentSegment,
            //   );
            // }
          },

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "BIB${participant.bibNumber}",
                style: RaceTextStyles.button.copyWith(color: RaceColors.white),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  // Handle individual tracking logic here
                  print("Tracking participant: ${participant.firstName}");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: RaceColors.neutralDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(RaceSpacings.radius),
                  ),
                ),
                child: Text(
                  "Track",
                  style: RaceTextStyles.label.copyWith(color: RaceColors.white),
                ),
              ),
            ],
            ),
        );
      },
    );
  }
}
