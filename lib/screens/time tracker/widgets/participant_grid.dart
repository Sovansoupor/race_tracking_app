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
    final trackedSegments = segmentProvider.trackedSegments;
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
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: allParticipants.length,
      itemBuilder: (context, int index) {
        final isTracked = trackedSegments[index] ?? false;
        return GestureDetector(
          onTap: () {
            if (onParticipantTap != null) {
              onParticipantTap!(index);
            } else {
              segmentProvider.toggleSegmentTracking(index);
            }
          },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isTracked ? RaceColors.primary : RaceColors.neutralDark,
              borderRadius: BorderRadius.circular(RaceSpacings.radius),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isTracked)
                      Icon(
                        Icons.check_circle,
                        color: RaceColors.white,
                        size: 16,
                      ),
                    if (isTracked) const SizedBox(width: 4),
                    Text(
                      "BIB${index + 001}",
                      style: RaceTextStyles.label.copyWith(
                        color: RaceColors.white,
                      ),
                    ),
                  ],
                ),
                if (isTracked && showTrackedLabel) ...[
                  const SizedBox(height: 4),
                  Text(
                    "Tracked",
                    style: RaceTextStyles.label.copyWith(
                      color: RaceColors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
