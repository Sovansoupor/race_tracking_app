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

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

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

    // Register participants with the segment provider if not already done
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bibNumbers = allParticipants.map((p) => p.bibNumber).toList();
      segmentProvider.addParticipantsToTrack(bibNumbers);
    });

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
        final participant = allParticipants[index];
        final bibNumber = participant.bibNumber;
        final recordedTime = participantTimes[bibNumber];

        return GestureDetector(
          onTap: () {
            // Always record the new time when the grid is tapped
            if (onParticipantTap != null) {
              onParticipantTap!(bibNumber);
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "BIB $bibNumber",
                  style: RaceTextStyles.label.copyWith(
                    color: RaceColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  recordedTime != null
                      ? _formatDuration(recordedTime)
                      : "--:--",
                  style: RaceTextStyles.label.copyWith(
                    color: RaceColors.white,
                    fontSize: 12,
                  ),
                ),
                if (showTrackedLabel)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      recordedTime != null ? "Tracked" : "Tap to Track",
                      style: RaceTextStyles.label.copyWith(
                        color: RaceColors.white.withOpacity(0.8),
                        fontSize: 10,
                      ),
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
