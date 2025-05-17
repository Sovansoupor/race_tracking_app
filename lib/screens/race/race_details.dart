import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracking_app/models/participant/participant.dart';
import 'package:race_tracking_app/provider/participant%20provider/participant_provider.dart';
import 'package:race_tracking_app/provider/segment/segment_provider.dart';
import 'package:race_tracking_app/screens/participant/participant_form.dart';
import 'package:race_tracking_app/screens/time%20tracker/time_tracking_screen.dart';
import 'package:race_tracking_app/theme/theme.dart';
import 'package:race_tracking_app/widgets/action/race_button.dart';
import 'package:race_tracking_app/widgets/navigation/bottom_nav_bar.dart';

import '../../models/race/race.dart';

class RaceDetails extends StatelessWidget {
  final Race race;

  const RaceDetails({super.key, required this.race});

  void _onAddParticipantPressed(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ParticipantForm(mode: formMode.add),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final participantProvider = context.watch<ParticipantProvider>();
    final segmentProvider = context.watch<SegmentProvider>();

    Widget content = const Center(child: Text(''));

    if (participantProvider.isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (participantProvider.hasData) {
      final participants = participantProvider.participantState!.data!;

      if (participants.isEmpty) {
        content = Center(
          child: Text(
            'No participants yet.',
            style: RaceTextStyles.label.copyWith(color: RaceColors.white),
          ),
        );
      } else {
        content = ListView.builder(
          itemCount: participants.length,
          itemBuilder: (context, index) {
            final participant = participants[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: RaceSpacings.s),
              child: Container(
                decoration: BoxDecoration(
                  color: RaceColors.white,
                  borderRadius: BorderRadius.circular(RaceSpacings.radius),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: RaceSpacings.s,
                    vertical: RaceSpacings.s / 2,
                  ),
                  title: Row(
                    children: [
                      Text(
                        "BIB${participant.bibNumber}",
                        style: RaceTextStyles.label.copyWith(
                          color: RaceColors.backgroundAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        "${participant.firstName} ${participant.lastName}",
                        style: RaceTextStyles.label.copyWith(
                          color: RaceColors.backgroundAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }
    }

    return Scaffold(
      backgroundColor: RaceColors.backgroundAccent,
      appBar: AppBar(
        backgroundColor: RaceColors.neutralLight,
        title: Text(
          race.name,
          style: RaceTextStyles.body.copyWith(color: RaceColors.neutralDark),
        ),
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: RaceColors.neutralDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Participants",
                  style: RaceTextStyles.button.copyWith(
                    color: RaceColors.white,
                  ),
                ),
                const Spacer(),
                CircleAvatar(
                  backgroundColor: RaceColors.primary,
                  radius: 20,
                  child: IconButton(
                    onPressed: () => _onAddParticipantPressed(context),
                    icon: Icon(Icons.add, color: RaceColors.white, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(child: content),
            const SizedBox(height: RaceSpacings.s),
            RaceButton(
              text: segmentProvider.isRaceStarted ? "End Race" : "Start Race",
              onPressed: () {
                if (segmentProvider.isRaceStarted) {
                  // End Race
                  segmentProvider.endRace(); // Stop the race state
                  segmentProvider.stopRaceTimer(); // Stop the timer
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder:
                          (_) => const BottomNavBar(
                            initialIndex: 1, // Navigate to the Result Screen
                          ),
                    ),
                    (route) => false, // Remove all previous routes
                  );
                } else {
                  // Start Race
                  segmentProvider.startRace(); // Start the race state
                  segmentProvider.startRaceTimer(); // Start the timer
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (_) => TimeTrackingScreen(startImmediately: true),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
