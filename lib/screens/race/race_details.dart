import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracking_app/models/participant/participant.dart';
import 'package:race_tracking_app/provider/participant%20provider/participant_provider.dart';
import 'package:race_tracking_app/screens/participant/participant_form.dart';
import 'package:race_tracking_app/theme/theme.dart';
import 'package:race_tracking_app/widgets/action/race_button.dart';

import '../../models/race/race.dart';
import '../time tracker/time_tracking_screen.dart';

class RaceDetails extends StatefulWidget {
  final Race race;
  final VoidCallback? onStartRace;
  final void Function(Participant)? onEditParticipant;

  const RaceDetails({
    super.key,
    required this.race,
    this.onStartRace,
    this.onEditParticipant,
    required List participants,
  });

  @override
  State<RaceDetails> createState() => _RaceDetailsState();
}

class _RaceDetailsState extends State<RaceDetails> {
  bool _hasLoadedParticipants = false;

  @override
  void initState() {
    super.initState();
    // Schedule the fetch to happen once after the first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasLoadedParticipants) {
        final participantProvider = context.read<ParticipantProvider>();
        participantProvider.fetchParticipantsByRace(widget.race.id);
        _hasLoadedParticipants = true;
      }
    });
  }

  void _onAddParticipantPressed(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ParticipantForm(
          mode: formMode.add,
          raceId: widget.race.id, // Pass the race ID
        ),
      ),
    ).then((_) {
      // Refresh participants when returning from add screen
      final participantProvider = context.read<ParticipantProvider>();
      participantProvider.fetchParticipantsByRace(widget.race.id);
    });
  }

  void _onEditParticipantPressed(
    BuildContext context,
    Participant participant,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ParticipantForm(
          mode: formMode.edit, 
          participant: participant,
          raceId: widget.race.id, // Pass the race ID
        ),
      ),
    ).then((_) {
      // Refresh participants when returning from edit screen
      final participantProvider = context.read<ParticipantProvider>();
      participantProvider.fetchParticipantsByRace(widget.race.id);
    });
  }

  void _onDeleteParticipantPressed(
    BuildContext context,
    Participant participant,
  ) async {
    final participantProvider = context.read<ParticipantProvider>();

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: RaceColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RaceSpacings.radius),
        ),
        title: Column(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: RaceColors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              "Delete Participant",
              style: RaceTextStyles.body.copyWith(
                color: RaceColors.backgroundAccent,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to delete ${participant.firstName} ${participant.lastName}?",
          style: RaceTextStyles.label.copyWith(
            color: RaceColors.backgroundAccent,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: RaceColors.greyLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(RaceSpacings.radius),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              "Cancel",
              style: RaceTextStyles.button.copyWith(
                color: RaceColors.backgroundAccent,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: RaceColors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(RaceSpacings.radius),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              "Delete",
              style: RaceTextStyles.button.copyWith(
                color: RaceColors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await participantProvider.removeParticipant(id: participant.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "${participant.firstName} ${participant.lastName} deleted successfully",
            ),
          ),
        );
        // Refresh participants after deletion
        participantProvider.fetchParticipantsByRace(widget.race.id);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete participant: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final participantProvider = context.watch<ParticipantProvider>();
    // final selectedSegment = context.watch<SegmentProvider>();

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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: RaceColors.backgroundAccent,
                        ),
                        onPressed: () => _onEditParticipantPressed(context, participant),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: RaceColors.red),
                        onPressed: () => _onDeleteParticipantPressed(
                          context,
                          participant,
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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100.0),
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 16.0),
            height: 70,
            decoration: BoxDecoration(
              color: RaceColors.neutralLight,
              borderRadius: BorderRadius.circular(RaceSpacings.radius),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.chevron_left,
                      color: RaceColors.neutralDark,
                      size: 35,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Text(
                      widget.race.name,
                      style: RaceTextStyles.body.copyWith(
                        color: RaceColors.neutralDark,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
              text: "Start Race",
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TimeTrackingScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
