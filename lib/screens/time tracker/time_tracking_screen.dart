import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracking_app/models/segment/segment.dart';
import 'package:race_tracking_app/provider/segment/segment_provider.dart';
import 'package:race_tracking_app/screens/time%20tracker/widgets/grid_view_mode.dart';
import 'package:race_tracking_app/theme/theme.dart';
import 'package:race_tracking_app/widgets/display/race_divider.dart';

class TimeTrackingScreen extends StatefulWidget {
  const TimeTrackingScreen({super.key});

  @override
  State<TimeTrackingScreen> createState() => _TimeTrackingScreenState();
}

class _TimeTrackingScreenState extends State<TimeTrackingScreen> {
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
          children: [
            Icon(Icons.timer_outlined, color: RaceColors.white, size: 40),
            const SizedBox(width: RaceSpacings.s),
            Text(
              'Timer',
              style: RaceTextStyles.heading.copyWith(color: RaceColors.white),
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
                  ActivityType.values.where((a) => a != ActivityType.flying).map((type) {
                final isSelected = currentActivityType == type;
                return GestureDetector(
                  onTap: () => segmentProvider.selectSegment(type),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? RaceColors.functional : RaceColors.neutralDark,
                      borderRadius: BorderRadius.circular(RaceSpacings.radius),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(type.icon, color: RaceColors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(type.label, style: RaceTextStyles.label.copyWith(color: RaceColors.white)),
                    ]),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: RaceSpacings.m),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: ViewMode.values.map((vm) {
              final isSel = currentViewMode == vm;
              return Padding(
                padding: const EdgeInsets.only(right: RaceSpacings.s),
                child: GestureDetector(
                  onTap: () => segmentProvider.selectView(vm),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSel ? RaceColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(
                        vm == ViewMode.grid ? Icons.grid_view : Icons.groups,
                        color: RaceColors.white, size: 20
                      ),
                      const SizedBox(width: 8),
                      Text(
                        vm == ViewMode.grid ? "Grid" : "Mass Arrival",
                        style: RaceTextStyles.label.copyWith(color: RaceColors.white),
                      ),
                    ]),
                  ),
                ),
              );
            }).toList()),
          ),
          const SizedBox(height: RaceSpacings.m),
          const RaceDivider(),
          Expanded(child: currentViewMode == ViewMode.grid
              ? GridViewMode()
              : const Center(child: Text("Mass Arrival View"))),
        ],
      ),
    );
  }
}
