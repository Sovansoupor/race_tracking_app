import 'package:flutter/material.dart';
import 'package:race_tracking_app/theme/theme.dart';

class ParticipantGrid extends StatelessWidget {
  final List<String> participants;

  const ParticipantGrid({super.key, required this.participants});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // 4 columns
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        childAspectRatio: 2, // Adjust the aspect ratio for the button size
      ),
      itemCount: participants.length,
      itemBuilder: (context, index) {
        return Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: RaceColors.neutralDark,
            borderRadius: BorderRadius.circular(RaceSpacings.radius),
          ),
          child: Text(
            participants[index],
            style: RaceTextStyles.label.copyWith(color: RaceColors.white),
          ),
        );
      },
    );
  }
}
