import 'package:flutter/material.dart';
import 'package:race_tracking_app/theme/theme.dart';
import 'package:race_tracking_app/widgets/display/race_divider.dart';

class TimeTrackingScreen extends StatefulWidget {
  const TimeTrackingScreen({super.key});

  @override
  State<TimeTrackingScreen> createState() => _TimeTrackingScreenState();
}

class _TimeTrackingScreenState extends State<TimeTrackingScreen> {
  String? selectedSegment;
  String? selectedView;

  @override
  void initState() {
    super.initState();
    // Set initial selections
    selectedSegment = 'Running';
    selectedView = 'Grid';
  }

  @override
  Widget build(BuildContext context) {
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
              children: [
                _buildSegmentButton(
                  icon: Icons.pool,
                  label: "Swimming",
                  segmentId: 'Swimming',
                ),
                _buildSegmentButton(
                  icon: Icons.directions_bike,
                  label: "Cycling",
                  segmentId: 'Cycling',
                  
                ),
                _buildSegmentButton(
                  icon: Icons.directions_run,
                  label: "Running",
                  segmentId: 'Running',
                ),
                const SizedBox(height: 60),
                Row(
                  children: [
                    _buildViewButton(
                      icon: Icons.grid_view,
                      label: "Grid",
                      viewId: 'Grid',
                      color: RaceColors.primary,
                    ),
                    const SizedBox(width: RaceSpacings.s),
                    _buildViewButton(
                      icon: Icons.groups,
                      label: "Mass Arrival",
                      viewId: 'Mass Arrival',
                      color: RaceColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: RaceSpacings.m),
          RaceDivider(),
        ],
      ),
    );
  }
  // Function to build the segment button
  Widget _buildSegmentButton({
    required IconData icon,
    required String label,
    required String segmentId,
  }) {
    final bool isSelected = segmentId == selectedSegment;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSegment = segmentId;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? RaceColors.functional
              : RaceColors.neutralDark,
          borderRadius: BorderRadius.circular(RaceSpacings.radius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: RaceColors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: RaceTextStyles.label.copyWith(color: RaceColors.white),
            ),
          ],
        ),
      ),
    );
  }
  
  // Function to build the view button
  Widget _buildViewButton({
    required IconData icon,
    required String label,
    required String viewId,
    Color? color,
  }) {
    final bool isSelected = viewId == selectedView;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedView = viewId;
        });
      },

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical:6),
        decoration: BoxDecoration(
          color: isSelected
              ? RaceColors.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: RaceColors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: RaceTextStyles.label.copyWith(color: RaceColors.white),
            ),
          ],
        ),
      ),
    );
  }
}
