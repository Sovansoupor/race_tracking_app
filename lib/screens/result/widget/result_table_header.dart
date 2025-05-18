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
        SizedBox(
          width: 80,
          child: Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text('Rank', style: headerStyle),
          ),
        ),
        Expanded(
          flex: 5,
          child: Text('Participant', style: headerStyle),
        ),
        Expanded(
          flex: 2,
          child: Text('Result', style: headerStyle, textAlign: TextAlign.center),
        ),
      ],
    );
  }
}