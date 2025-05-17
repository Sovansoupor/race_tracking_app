import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:race_tracking_app/provider/segment/segment_provider.dart';
import 'package:race_tracking_app/screens/time%20tracker/widgets/grid_view_mode.dart';
import 'package:race_tracking_app/screens/time%20tracker/widgets/mass_arrival_view.dart';
import 'package:race_tracking_app/theme/theme.dart';
import 'package:race_tracking_app/widgets/display/race_divider.dart';
import 'package:race_tracking_app/models/segment/segment.dart';

class TimeTrackingScreen extends StatefulWidget {
  final bool startImmediately;
  
  const TimeTrackingScreen({super.key, this.startImmediately = false});

  @override
  State<TimeTrackingScreen> createState() => _TimeTrackingScreenState();
}

class _TimeTrackingScreenState extends State<TimeTrackingScreen> {
  late Timer _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    if (widget.startImmediately) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        _elapsed += Duration(seconds: 1);
      });
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final segmentProvider = context.watch<SegmentProvider>();
    final currentActivityType = segmentProvider.activityType;
    final currentViewMode = segmentProvider.viewMode;

    return Scaffold(
      backgroundColor: RaceColors.backgroundAccent,
      appBar: AppBar(
        backgroundColor: RaceColors.backgroundAccentDark,
        toolbarHeight: 95,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.timer_outlined, color: RaceColors.white, size: 35),
            const SizedBox(width: RaceSpacings.s),
            Text(
              'Timer',
              style: RaceTextStyles.body.copyWith(color: RaceColors.white),
            ),
            Spacer(),
            SizedBox(
              width: 100,
              child: Text(
                _formatDuration(_elapsed),
                style: RaceTextStyles.label.copyWith(
                  color: RaceColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
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
              children:
                  ActivityType.values.map((type) {
                    final isSelected = currentActivityType == type;
                    return GestureDetector(
                      onTap: () => segmentProvider.selectSegment(type),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? RaceColors.functional
                                  : RaceColors.neutralDark,
                          borderRadius: BorderRadius.circular(
                            RaceSpacings.radius,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(type.icon, color: RaceColors.white, size: 20),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children:
                  ViewMode.values.map((vm) {
                    final isSelected = currentViewMode == vm;
                    return Padding(
                      padding: const EdgeInsets.only(right: RaceSpacings.s),
                      child: GestureDetector(
                        onTap: () => segmentProvider.selectView(vm),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? RaceColors.primary
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                vm == ViewMode.grid
                                    ? Icons.grid_view
                                    : Icons.groups,
                                color: RaceColors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                vm == ViewMode.grid ? "Grid" : "Mass Arrival",
                                style: RaceTextStyles.label.copyWith(
                                  color: RaceColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
          const SizedBox(height: RaceSpacings.m),
          const RaceDivider(),
          Expanded(
            child:
                currentViewMode == ViewMode.grid
                    ? const GridViewMode()
                    : const MassArrivalView(),
          ),
        ],
      ),
    );
  }
}
