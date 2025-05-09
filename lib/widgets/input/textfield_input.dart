import 'package:flutter/material.dart';
import 'package:race_tracking_app/theme/theme.dart';

class TextfieldInput extends StatelessWidget {
   final String label;
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  
  const TextfieldInput({
    super.key, required this.label, required this.controller, this.maxLines = 1, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: RaceTextStyles.label.copyWith(color: Colors.white)),
        SizedBox(height: RaceSpacings.s),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: RaceTextStyles.label.copyWith(color: Colors.grey),
            filled: true,
            fillColor: RaceColors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(RaceSpacings.radius),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 0.75),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(RaceSpacings.radius),
              borderSide: BorderSide(color: Colors.grey, width: 1),
            ),
          ),
        ),
      ],
    );
  }
}