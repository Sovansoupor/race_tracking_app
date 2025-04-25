import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/segment/segment.dart';
import '../../theme/theme.dart';
import '../../widgets/action/race_button.dart';
import '../../widgets/input/textfield_input.dart';

class RaceForm extends StatefulWidget {
  const RaceForm({super.key});

  @override
  State<RaceForm> createState() => _RaceFormState();
}

class _RaceFormState extends State<RaceForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  DateTime? _selectedDate;

  // Selected segments
  final Set<Segment> _selectedSegments = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  // Show date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFE25E3E), // Calendar header and selected day
              onPrimary: Colors.white, // Text on primary color
              surface: Color(0xFF172331), // Dialog background
              onSurface: Colors.white, // Regular text
            ),
            dialogBackgroundColor: const Color(0xFF172331),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yy').format(picked);
      });
    }
  }

  // // Toggle segment selection
  // void _toggleSegment(Segment segment) {
  //   setState(() {
  //     if (_selectedSegments.contains(segment)) {
  //       _selectedSegments.remove(segment);
  //     } else {
  //       _selectedSegments.add(segment);
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }

// Build form body
  Widget _buildFormBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: RaceSpacings.m),
          // Race Name
          TextfieldInput(
            controller: _nameController,
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
            controller: _dateController,
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
                onPressed: () => _selectDate(context),
              ),
            ),
            onTap: () => _selectDate(context),
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
                  final isSelected = _selectedSegments.any(
                    (segment) => segment.activityType == type,
                  );
                  return GestureDetector(
                    onTap: () {
                      final existing = _selectedSegments.firstWhere(
                        (segment) => segment.activityType == type,
                        orElse:
                            () => Segment(
                              id: '',
                              name: '',
                              order: 0,
                              distance: null,
                              activityType: type,
                            ),
                      );
                      setState(() {
                        if (_selectedSegments.contains(existing)) {
                          _selectedSegments.remove(existing);
                        } else {
                          _selectedSegments.add(existing);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? RaceColors.functional : Colors.white,
                        borderRadius: BorderRadius.circular(RaceSpacings.radius),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected)
                            const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 18,
                            ),
                          if (isSelected) const SizedBox(width: 8),
                          Text(
                            type.label, 
                            style: RaceTextStyles.label.copyWith(
                              color: isSelected ? Colors.white : RaceColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
          ),

          //Add button
          const Spacer(),
          RaceButton(onPressed: (){}, text: 'Add',)

        ],
      ),
    );
  }
}
