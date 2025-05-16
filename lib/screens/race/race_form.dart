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
  late RaceProvider raceProvider;

  @override
  void initState() {
    super.initState();
    raceProvider = RaceProvider();
    for (var type in ActivityType.values.take(3)) {
      raceProvider.toggleSegment(
        Segment(
          id: type.name,
          name: type.label,
          order: 0,
          distance: null,
          activityType: type,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: raceProvider,
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
        body: const _buildFormBody(),
      ),
    );
  }
}

// Build form body
class _buildFormBody extends StatelessWidget {
  const _buildFormBody();

  @override
  Widget build(BuildContext context) {
    final raceForm = Provider.of<RaceProvider>(context);

    return Padding(
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
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children:
                ActivityType.values.map((type) {
                  final isSelected = raceForm.selectedSegments.values.any(
                    (segment) => segment.activityType == type,
                  );
                  return GestureDetector(
                    onTap:
                        () => raceForm.toggleSegment(
                          Segment(
                            id: type.name,
                            name: type.label,
                            order: 0,
                            distance: null,
                            activityType: type,
                          ),
                        ),
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
                          if (isSelected)
                            const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            ),
                          if (isSelected) const SizedBox(width: 8),
                          Icon(
                            type.icon, // Add the icon here based on activity type
                            color:
                                isSelected
                                    ? Colors.white
                                    : RaceColors.textNormal,
                            size: 20, // Adjust size as needed
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

          // Add button
          const Spacer(),
          RaceButton(
            onPressed: () async {
              try {
                // Submit the race
                await raceForm.submitRace();

                // Notify listeners in RaceProvider
                Provider.of<RaceProvider>(context, listen: false).fetchRaces();

                // Go back to the previous screen
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
}
