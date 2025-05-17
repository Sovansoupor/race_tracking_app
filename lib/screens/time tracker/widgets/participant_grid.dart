import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracking_app/provider/participant%20provider/participant_provider.dart';
import 'package:race_tracking_app/provider/segment/segment_provider.dart';
import 'package:race_tracking_app/theme/theme.dart';

class ParticipantGrid extends StatelessWidget {
  final bool showTrackedLabel;
  final Function(int)? onParticipantTap;

  const ParticipantGrid({
    super.key,
    required this.showTrackedLabel,
    this.onParticipantTap,
  });

  @override
  Widget build(BuildContext context) {
    final segmentProvider = context.watch<SegmentProvider>();
    final participantTimes = segmentProvider.currentSegmentParticipantTimes;
    final participantProvider = context.watch<ParticipantProvider>();

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
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: allParticipants.length,
      itemBuilder: (context, int index) {
        final participantId = index + 1;
        final recordedTime = participantTimes[participantId];

        return GestureDetector(
          onTap: () {
            if (onParticipantTap != null) {
              onParticipantTap!(participantId);
            }
          },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color:
                  recordedTime != null
                      ? RaceColors.functional
                      : RaceColors.neutralDark,
              borderRadius: BorderRadius.circular(RaceSpacings.radius),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "BIB $participantId",
                  style: RaceTextStyles.label.copyWith(color: RaceColors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  recordedTime != null
                      ? "${recordedTime.inMinutes}:${(recordedTime.inSeconds % 60).toString().padLeft(2, '0')}"
                      : "--:--",
                  style: RaceTextStyles.label.copyWith(
                    color: RaceColors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
