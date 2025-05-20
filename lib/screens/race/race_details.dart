import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracking_app/models/participant/participant.dart';
import 'package:race_tracking_app/models/segment/segment.dart';
import 'package:race_tracking_app/provider/participant%20provider/participant_provider.dart';
import 'package:race_tracking_app/provider/segment/segment_provider.dart';
import 'package:race_tracking_app/screens/participant/participant_form.dart';
import 'package:race_tracking_app/screens/result/result_details_screen.dart';
import 'package:race_tracking_app/screens/time%20tracker/time_tracking_screen.dart';
import 'package:race_tracking_app/theme/theme.dart';
import 'package:race_tracking_app/widgets/action/race_button.dart';
import 'package:race_tracking_app/data/repository/firebase/firebase_participant_repository.dart';
import 'package:race_tracking_app/data/repository/firebase/firebase_race_repository.dart';

import '../../models/race/race.dart';

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
  bool _isLoading = true;

  // Track if this specific race is completed or in progress
  bool _isRaceCompleted = false;
  bool _isRaceInProgress = false;

  @override
  void initState() {
    super.initState();
    // Schedule the fetch to happen once after the first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load participants
      if (!_hasLoadedParticipants) {
        final participantProvider = context.read<ParticipantProvider>();
        participantProvider.fetchParticipantsByRace(widget.race.id);
        _hasLoadedParticipants = true;
      }

      // Check race status from Firebase
      final firebaseRaceRepo = FirebaseRaceRepository();
      _isRaceCompleted = await firebaseRaceRepo.isRaceCompleted(widget.race.id);

      // Update segment provider with race completion status
      final segmentProvider = context.read<SegmentProvider>();

      // Load race completion status from Firebase
      await segmentProvider.loadRaceCompletionStatus(widget.race.id);

      // If race is completed, make sure it's marked in the segment provider
      if (_isRaceCompleted) {
        segmentProvider.markRaceAsCompleted(widget.race.id);
      }

      // Check if race is in progress but not completed
      _isRaceInProgress =
          segmentProvider.isRaceStarted &&
          segmentProvider.currentRaceId == widget.race.id &&
          !_isRaceCompleted;
    } catch (e) {
      print('Error loading race data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onAddParticipantPressed(BuildContext context) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder:
                (context) => ParticipantForm(
                  mode: formMode.add,
                  raceId: widget.race.id, // Pass the race ID
                ),
          ),
        )
        .then((_) {
          // Refresh participants when returning from add screen
          final participantProvider = context.read<ParticipantProvider>();
          participantProvider.fetchParticipantsByRace(widget.race.id);
        });
  }

  void _onEditParticipantPressed(
    BuildContext context,
    Participant participant,
  ) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder:
                (context) => ParticipantForm(
                  mode: formMode.edit,
                  participant: participant,
                  raceId: widget.race.id, // Pass the race ID
                ),
          ),
        )
        .then((_) {
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
      builder:
          (context) => AlertDialog(
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

  void _viewRaceResults() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => ResultDetailsScreen(
              raceId: widget.race.id,
              raceRepository: FirebaseRaceRepository(),
              participantRepository: FirebaseParticipantRepository(),
            ),
      ),
    );
  }

  // Only update the _saveRaceResultsToFirebase method
  Future<void> _saveRaceResultsToFirebase() async {
    try {
      final segmentProvider = context.read<SegmentProvider>();
      final participantProvider = context.read<ParticipantProvider>();
      final raceRepository = FirebaseRaceRepository();

      // Get participants for this race
      final participants = participantProvider.participantState?.data ?? [];

      if (participants.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No participants to save results for')),
        );
        return;
      }

      // Get total times from segment provider
      final totalTimes = segmentProvider.calculateTotalTimes();

      // If no times are available, create them from segment provider data
      if (totalTimes.isEmpty) {
        for (final participant in participants) {
          // Get times from segment provider for each activity type
          for (final activityType in ActivityType.values) {
            final time =
                segmentProvider.currentSegmentParticipantTimes[participant
                    .bibNumber] ??
                Duration.zero;
            if (time.inMilliseconds > 0) {
              segmentProvider.addParticipantTimeDirectly(
                participant.bibNumber,
                activityType,
                time,
              );
            }
          }
        }

        // Recalculate total times
        final updatedTotalTimes = segmentProvider.calculateTotalTimes();
        if (updatedTotalTimes.isNotEmpty) {
          totalTimes.addAll(updatedTotalTimes);
        }
      }

      // Save results to Firebase BEFORE marking race as completed
      await raceRepository.saveRaceResults(
        widget.race.id,
        participants,
        totalTimes,
      );

      // Mark race as completed in Firebase and segment provider
      await raceRepository.markRaceAsCompleted(widget.race.id);
      await segmentProvider.markRaceAsCompleted(widget.race.id);

      // Update local state
      setState(() {
        _isRaceCompleted = true;
        _isRaceInProgress = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Race results saved to database')));

      // Refresh the screen to show the "View Results" button
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save race results')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final participantProvider = context.watch<ParticipantProvider>();
    final segmentProvider = context.watch<SegmentProvider>();

    // Check if this specific race is in progress
    final bool isThisRaceActive =
        segmentProvider.isRaceStarted &&
        segmentProvider.currentRaceId == widget.race.id;

    // Update local state based on segment provider
    if (isThisRaceActive != _isRaceInProgress) {
      setState(() {
        _isRaceInProgress = isThisRaceActive;
      });
    }

    // Check if race is completed from segment provider
    final bool isCompletedInProvider = segmentProvider.isRaceCompletedById(
      widget.race.id,
    );
    if (isCompletedInProvider != _isRaceCompleted) {
      setState(() {
        _isRaceCompleted = isCompletedInProvider;
      });
    }

    Widget content = const Center(child: CircularProgressIndicator());

    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (participantProvider.isLoading) {
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
        // Register participants with the segment provider for tracking
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final bibNumbers = participants.map((p) => p.bibNumber).toList();
          segmentProvider.addParticipantsToTrack(bibNumbers);
        });

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
                          color:
                              _isRaceCompleted || _isRaceInProgress
                                  ? RaceColors
                                      .grey // Disabled color
                                  : RaceColors.backgroundAccent,
                        ),
                        onPressed:
                            _isRaceCompleted || _isRaceInProgress
                                ? null // Disable editing if race is completed or in progress
                                : () => _onEditParticipantPressed(
                                  context,
                                  participant,
                                ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          color:
                              _isRaceCompleted || _isRaceInProgress
                                  ? RaceColors
                                      .grey // Disabled color
                                  : RaceColors.red,
                        ),
                        onPressed:
                            _isRaceCompleted || _isRaceInProgress
                                ? null // Disable deletion if race is completed or in progress
                                : () => _onDeleteParticipantPressed(
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

    // Show race status indicator
    Widget raceStatusIndicator = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color:
            _isRaceCompleted
                ? RaceColors.green
                : _isRaceInProgress
                ? RaceColors.primary
                : RaceColors.neutralDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isRaceCompleted
                ? Icons.check_circle
                : _isRaceInProgress
                ? Icons.timer
                : Icons.sports_score,
            color: RaceColors.white,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            _isRaceCompleted
                ? 'Race Completed'
                : _isRaceInProgress
                ? 'Race In Progress'
                : 'Race Not Started',
            style: RaceTextStyles.label.copyWith(color: RaceColors.white),
          ),
        ],
      ),
    );

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
            // Race status indicator
            raceStatusIndicator,
            const SizedBox(height: 16),

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
                  backgroundColor:
                      _isRaceCompleted || _isRaceInProgress
                          ? RaceColors
                              .grey // Disabled color
                          : RaceColors.primary,
                  radius: 20,
                  child: IconButton(
                    onPressed:
                        _isRaceCompleted || _isRaceInProgress
                            ? null // Disable adding participants if race is completed or in progress
                            : () => _onAddParticipantPressed(context),
                    icon: Icon(
                      Icons.add,
                      color:
                          _isRaceCompleted || _isRaceInProgress
                              ? RaceColors
                                  .greyLight // Disabled icon color
                              : RaceColors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(child: content),
            const SizedBox(height: RaceSpacings.s),

            // Show results button only if THIS race is completed
            if (_isRaceCompleted)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: RaceButton(
                  text: "View Results",
                  icon: Icons.bar_chart,
                  onPressed: _viewRaceResults,
                  color: RaceColors.primary,
                ),
              ),

            // Disable start button if race is completed
            RaceButton(
              text: _isRaceInProgress ? "End Race" : "Start Race",
              icon: _isRaceInProgress ? Icons.flag : Icons.play_arrow,
              onPressed:
                  _isRaceCompleted
                      ? null // Disable button if race is completed
                      : () {
                        if (_isRaceInProgress) {
                          // End this race
                          segmentProvider.endRace();
                          segmentProvider.stopRaceTimer();

                          // Save results to Firebase
                          _saveRaceResultsToFirebase();

                          setState(() {
                            _isRaceCompleted = true;
                            _isRaceInProgress = false;
                          });

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) => ResultDetailsScreen(
                                    raceId: widget.race.id,
                                    raceRepository: FirebaseRaceRepository(),
                                    participantRepository:
                                        FirebaseParticipantRepository(),
                                  ),
                            ),
                          );
                        } else {
                          // Start this race
                          String raceId = widget.race.id;
                          segmentProvider.startRace(raceId);
                          segmentProvider.startRaceTimer();

                          setState(() {
                            _isRaceInProgress = true;
                          });

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (_) => TimeTrackingScreen(
                                    startImmediately: true,
                                    raceId: raceId,
                                  ),
                            ),
                          );
                        }
                      },
              color: _isRaceInProgress ? Colors.red : Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}
