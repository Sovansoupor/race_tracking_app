import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracking_app/provider/segment/segment_provider.dart';
import 'package:race_tracking_app/screens/time%20tracker/widgets/participant_grid.dart';
import 'package:race_tracking_app/theme/theme.dart';
import 'package:race_tracking_app/widgets/action/race_button.dart';

class MassArrivalView extends StatelessWidget {
  const MassArrivalView({super.key});

  @override
  Widget build(BuildContext context) {
    final segmentProvider = context.watch<SegmentProvider>();
    final trackedSegments = segmentProvider.trackedSegments;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Arrival Time: 00:33:45s",
                style: RaceTextStyles.label.copyWith(color: RaceColors.white),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: RaceColors.green,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  "Active",
                  style: RaceTextStyles.label.copyWith(color: RaceColors.white),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ParticipantGrid(
            showTrackedLabel: true,
            onParticipantTap: (index) {
              segmentProvider.toggleSegmentTracking(index);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: RaceButton(
                  text: "Reset",
                  onPressed:
                      trackedSegments.containsValue(true)
                          ? () {
                            segmentProvider.resetTracking();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Selection has been reset."),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                          : null,
                  type: RaceButtonType.primary,
                  icon: Icons.refresh,
                  color: RaceColors.red,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: RaceButton(
                  text: "Confirm Arrival",
                  onPressed:
                      trackedSegments.containsValue(true)
                          ? () {
                            final trackedParticipants =
                                trackedSegments.entries
                                    .where((entry) => entry.value)
                                    .map((entry) => entry.key)
                                    .toList();

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Confirmed arrival for ${trackedParticipants.length} participant(s).",
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );

                            segmentProvider.resetTracking();
                          }
                          : null,
                  type: RaceButtonType.secondary,
                  icon: Icons.check,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
