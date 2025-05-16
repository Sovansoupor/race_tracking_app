import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracking_app/theme/theme.dart';
import 'package:race_tracking_app/widgets/action/race_button.dart';
import '../../models/segment/segment.dart';
import '../../provider/race/race_provider.dart';
import '../../widgets/input/textfield_input.dart';

class SegmentForm extends StatefulWidget {
  final String segmentTitle;
  final String segmentId;
  final String raceId;
  const SegmentForm({
    required this.segmentId,
    required this.segmentTitle,
    required this.raceId,
    super.key,
  });

  @override
  State<SegmentForm> createState() => _SegmentFormState();
}

class _SegmentFormState extends State<SegmentForm> {
  String selectedUnit = "M";

  @override
  void initState() {
    super.initState();
    final controller = context
        .read<RaceProvider>()
        .distanceControllers
        .putIfAbsent(widget.segmentId, () => TextEditingController());

    final existingSegment = context.read<RaceProvider>().allSegments.firstWhere(
      (s) => s.id == widget.segmentId,
      orElse:
          () => Segment(
            id: widget.segmentId,
            name: widget.segmentId,
            order: 0,
            activityType: ActivityType.running,
          ),
    );
    print('Existing segment: $existingSegment');
    if (existingSegment.distance != null) {
      controller.text = existingSegment.distance.toString();
      selectedUnit = existingSegment.unit ?? "M";
    }
  }

  @override
  Widget build(BuildContext context) {
    final raceProvider = Provider.of<RaceProvider>(context);

    final existingSegment = raceProvider.allSegments.firstWhere(
      (s) => s.id == widget.segmentId,
      orElse:
          () => Segment(
            id: widget.segmentId,
            name: widget.segmentId,
            order: 0,
            activityType: ActivityType.running,
          ),
    );

    final isUpdating = existingSegment.distance != null;

    return Scaffold(
      backgroundColor: RaceColors.backgroundAccent,
      appBar: AppBar(
        iconTheme: IconThemeData(color: RaceColors.white),
        backgroundColor: Colors.transparent,
        centerTitle: false,
        title: Text(
          widget.segmentTitle,
          style: RaceTextStyles.subheadline.copyWith(color: RaceColors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(RaceSpacings.l),
        child: Column(
          children: [
            TextfieldInput(
              label: 'Distance',
              controller: raceProvider.distanceControllers.putIfAbsent(
                widget.segmentId,
                () => TextEditingController(),
              ),
              hint: 'add distance in M/KM',
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Unit: ",
                  style: RaceTextStyles.label.copyWith(color: RaceColors.white),
                ),
                const SizedBox(width: RaceSpacings.s),
                DropdownButton<String>(
                  value: selectedUnit,
                  dropdownColor: RaceColors.backgroundAccent,
                  items:
                      ["M", "KM"].map((String unit) {
                        return DropdownMenuItem<String>(
                          value: unit,
                          child: Text(
                            unit == "M" ? "Meters" : "Kilometers",
                            style: RaceTextStyles.label.copyWith(
                              color: RaceColors.white,
                            ),
                          ),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedUnit = newValue;
                      });
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: RaceSpacings.xxl),

            RaceButton(
              text: isUpdating ? "Update" : "Add",
              onPressed: () async {
                try {
                  print(
                    'On pressed - segmentId: ${widget.segmentId}, selectedUnit: $selectedUnit',
                  );
                  await raceProvider.saveSegmentDistance(
                    raceId: widget.raceId,
                    segmentId: widget.segmentId,
                    unit: selectedUnit,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Distance saved successfully!')),
                  );
                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                  print('Error in saving segment distance: ${e.toString()}');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
