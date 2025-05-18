import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/segment/segment.dart';
import '../../provider/race/race_provider.dart';
import '../../theme/theme.dart';
import '../../widgets/action/race_button.dart';
import '../../widgets/input/textfield_input.dart';

class RaceForm extends StatefulWidget {
  const RaceForm({super.key});

  @override
  State<RaceForm> createState() => _RaceFormState();
}

class _RaceFormState extends State<RaceForm> {
  final List<List<TextEditingController>> _segmentControllers = [
    [
      TextEditingController(text: 'Swimming'),
      TextEditingController(text: '1.5 km'),
    ],
    [
      TextEditingController(text: 'Cycling'),
      TextEditingController(text: '40 km'),
    ],
    [
      TextEditingController(text: 'Running'),
      TextEditingController(text: '10 km'),
    ],
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    for (var pair in _segmentControllers) {
      pair[0].dispose();
      pair[1].dispose();
    }
    super.dispose();
  }

  void _removeSegment(int index) {
    setState(() {
      _segmentControllers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RaceProvider(),
      child: Scaffold(
        backgroundColor: RaceColors.backgroundAccent,
        appBar: AppBar(
          centerTitle: false,
          title: Text(
            "Add Race",
            style: RaceTextStyles.subheadline.copyWith(color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left, size: 35, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: _buildFormBody(),
      ),
    );
  }

  Widget _buildFormBody() {
    final raceForm = Provider.of<RaceProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: RaceSpacings.m),
          // Race Name
          TextfieldInput(
            controller: raceForm.nameController,
            label: ("Race Name"),
            hint: ("Type here..."),
          ),
          const SizedBox(height: 20),

          // Start date picker
          Text(
            'Start date',
            style: RaceTextStyles.label.copyWith(color: Colors.white),
          ),
          SizedBox(height: RaceSpacings.s),
          TextField(
            controller: raceForm.startTimeController,
            readOnly: true,
            style: RaceTextStyles.label.copyWith(color: Colors.black),
            decoration: InputDecoration(
              hintText: 'DD/MM/YY',
              hintStyle: TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(RaceSpacings.radius),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.calendar_month_rounded,
                  color: RaceColors.primary,
                ),
                onPressed: () => _selectDate(context, raceForm),
              ),
            ),
            onTap: () => _selectDate(context, raceForm),
          ),

          // Segments Selection
          const SizedBox(height: 20),
          Text(
            'Segments',
            style: RaceTextStyles.label.copyWith(color: Colors.white),
          ),
          SizedBox(height: RaceSpacings.s),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ..._segmentControllers.asMap().entries.map((entry) {
                int index = entry.key;
                var pair = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      // Segment Name Input
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: pair[0],
                          style: RaceTextStyles.label.copyWith(
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Segment Name',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                RaceSpacings.radius,
                              ),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Distance Input
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: pair[1],
                          style: RaceTextStyles.label.copyWith(
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Distance',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                RaceSpacings.radius,
                              ),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Delete Button
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeSegment(index),
                      ),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 10),
              // Add Segment Button
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _segmentControllers.add([
                      TextEditingController(),
                      TextEditingController(),
                    ]);
                  });
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(
                  "Add Segment",
                  style: RaceTextStyles.label.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),

          // Add button
          RaceButton(
            onPressed: () async {
              try {
                raceForm.segmentInputs.clear();
                for (var pair in _segmentControllers) {
                  raceForm.segmentInputs.add(
                    SegmentInput(
                      initialName: pair[0].text,
                      initialDistance: pair[1].text,
                      activityType: ActivityType.values[0],
                    ),
                  );
                }
                // Submit the race
                await raceForm.submitRace();
                await raceForm.fetchRaces();
                Navigator.of(context).pop();
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
            text: 'Add',
          ),
        ],
      ),
    );
  }
}

// Build form body

Future<void> _selectDate(BuildContext context, RaceProvider raceForm) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: raceForm.startTime ?? DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2101),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: RaceColors.primary,
            onPrimary: Colors.white,
            surface: const Color(0xFF172331),
            onSurface: Colors.white,
          ),
          dialogBackgroundColor: const Color(0xFF172331),
        ),
        child: child!,
      );
    },
  );
  if (picked != null) {
    raceForm.updateStartTime(picked);
  }
}
