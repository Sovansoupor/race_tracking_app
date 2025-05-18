import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:race_tracking_app/provider/segment/segment_provider.dart';
import 'package:race_tracking_app/screens/time%20tracker/widgets/grid_view_mode.dart';
import 'package:race_tracking_app/theme/theme.dart';
import 'package:race_tracking_app/widgets/display/race_divider.dart';
import 'package:race_tracking_app/models/segment/segment.dart';
import 'package:race_tracking_app/data/repository/firebase/firebase_participant_repository.dart';
import 'package:race_tracking_app/data/repository/firebase/firebase_race_repository.dart';
import 'package:race_tracking_app/screens/result/result_details_screen.dart';

class TimeTrackingScreen extends StatefulWidget {
  final bool startImmediately;
  final bool stopTimer;
  final String? raceId;
  final VoidCallback? onEndRace;

  const TimeTrackingScreen({
    super.key,
    this.startImmediately = false,
    this.stopTimer = false,
    this.raceId,
    this.onEndRace,
  });

  @override
  State<TimeTrackingScreen> createState() => _TimeTrackingScreenState();
}

class _TimeTrackingScreenState extends State<TimeTrackingScreen> {
  late Timer _timer;
  Duration _elapsed = Duration.zero;
  bool _isTimerRunning = false;

  @override
  void initState() {
    super.initState();
    if (widget.startImmediately) {
      _startTimer();
    }
    if (widget.stopTimer) {
      _stopTimer(); // Stop the timer if the flag is set
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        _elapsed += Duration(seconds: 1);
      });
    });
    _isTimerRunning = true;
  }

  void _stopTimer() {
    if (_timer.isActive) {
      _timer.cancel();
      _isTimerRunning = false;
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  void _endRace() {
    final segmentProvider = Provider.of<SegmentProvider>(context, listen: false);
    segmentProvider.endRace();
    segmentProvider.stopRaceTimer();
    
    if (widget.raceId != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ResultDetailsScreen(
            raceId: widget.raceId!,
            raceRepository: FirebaseRaceRepository(),
            participantRepository: FirebaseParticipantRepository(),
          ),
        ),
      );
    } else {
      Navigator.of(context).pop();
    }
    
    if (widget.onEndRace != null) {
      widget.onEndRace!();
    }
  }

  @override
  void dispose() {
    if (_isTimerRunning) {
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final segmentProvider = context.watch<SegmentProvider>();
    final currentActivityType = segmentProvider.activityType;
    final allSegmentsCompleted = segmentProvider.areAllSegmentsCompleted(ActivityType.values.length);

    return Scaffold(
      backgroundColor: RaceColors.backgroundAccent,
      appBar: AppBar(
        backgroundColor: RaceColors.backgroundAccentDark,
        toolbarHeight: 95,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: RaceColors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.timer_outlined, color: RaceColors.white, size: 35),
            const SizedBox(width: RaceSpacings.s),
            Text(
              'Timer',
              style: RaceTextStyles.body.copyWith(color: RaceColors.white),
            ),
          ],
        ),
        actions: [
          if (allSegmentsCompleted)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: ElevatedButton.icon(
                onPressed: _endRace,
                icon: Icon(Icons.flag, color: RaceColors.white),
                label: Text(
                  'End Race',
                  style: RaceTextStyles.label.copyWith(color: RaceColors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: RaceColors.functional,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: RaceSpacings.m),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Select segments",
              style: RaceTextStyles.button.copyWith(color: RaceColors.white),
            ),
          ),
          const SizedBox(height: RaceSpacings.m),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              children: ActivityType.values.map((type) {
                final isSelected = currentActivityType == type;
                final isCompleted = segmentProvider.isSegmentCompleted(
                  ActivityType.values.indexOf(type),
                );
                
                return GestureDetector(
                  onTap: () {
                    if (!isSelected) {
                      segmentProvider.selectSegment(type);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? RaceColors.functional
                          : (isCompleted ? RaceColors.primary : RaceColors.neutralDark),
                      borderRadius: BorderRadius.circular(
                        RaceSpacings.radius,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isCompleted ? Icons.check_circle : type.icon,
                          color: RaceColors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          type.label,
                          style: RaceTextStyles.label.copyWith(
                            color: RaceColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: RaceSpacings.m),
            Center(

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatDuration(_elapsed),
                      style: RaceTextStyles.heading.copyWith(
                        color: RaceColors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          const SizedBox(height: RaceSpacings.m),
          const RaceDivider(),
          Expanded(
            child: const GridViewMode(), 
          ),
        ],
      ),
    );
  }
}
