import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracking_app/provider/segment/segment_provider.dart';
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
                  color: RaceColors.functional,
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
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, // Number of columns
              crossAxisSpacing: 12, // Horizontal spacing between boxes
              mainAxisSpacing: 12, // Vertical spacing between boxes
              childAspectRatio: 1.5, // Adjust this to make boxes smaller
            ),
            itemCount: 12, // Example segment count for now
            itemBuilder: (context, index) {
              final isTracked = trackedSegments[index] ?? false;
              return GestureDetector(
                onTap: () {
                  // Toggle the tracking state for this segment
                  segmentProvider.toggleSegmentTracking(index);
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color:
                        isTracked ? RaceColors.primary : RaceColors.neutralDark,
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
                            "${index + 101}",
                            style: RaceTextStyles.label.copyWith(
                              color: RaceColors.white,
                            ),
                          ),
                        ],
                      ),
                      if (isTracked) ...[
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
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: RaceButton(
                  text: "Reset",
                  onPressed: () {
                    segmentProvider.resetTracking();
                  },
                  type: RaceButtonType.primary,
                  icon: Icons.refresh,
                  color: RaceColors.red,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: RaceButton(
                  text: "Confirm Arrival",
                  onPressed: () {
                    // Handle confirm arrival logic
                    final trackedParticipants =
                        trackedSegments.entries
                            .where((entry) => entry.value)
                            .map((entry) => entry.key)
                            .toList();
                    print("Confirming arrival for: $trackedParticipants");
                  },
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
