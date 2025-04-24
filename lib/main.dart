import 'package:flutter/material.dart';
import 'package:race_tracking_app/theme/theme.dart';
import 'package:race_tracking_app/widgets/action/race_button.dart';

void main() {
  // final ParticipantRepository participantRepository = FirebaseParticipantRepository();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: raceTheme,
      home: Scaffold(
        body: Center(child: RaceButton(text: 'Start Race', onPressed: () {})),
      ),
    ),
  );
}
