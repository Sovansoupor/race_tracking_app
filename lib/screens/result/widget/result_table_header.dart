import 'package:flutter/material.dart';
import 'package:race_tracking_app/theme/theme.dart';

class ResultTableHeader extends StatelessWidget {
  const ResultTableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final headerStyle = RaceTextStyles.label.copyWith(
      color: RaceColors.white,
      fontWeight: FontWeight.bold,
    );
    
    return Row(
      children: [
        SizedBox(width: 76),
        Expanded(
          flex: 3,
          child: Text('Name', style: headerStyle),
        ),
        Expanded(
          flex: 2,
          child: Text('Start', style: headerStyle, textAlign: TextAlign.center),
        ),
        Expanded(
          flex: 2,
          child: Text('Finish', style: headerStyle, textAlign: TextAlign.center),
        ),
        Expanded(
          flex: 2,
          child: Text('Result', style: headerStyle, textAlign: TextAlign.center),
        ),
      ],
    );
  }
}