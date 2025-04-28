import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracking_app/firebase_options.dart';
import 'package:race_tracking_app/provider/participant%20provider/participant_provider.dart';
import 'package:race_tracking_app/screens/race/race_details.dart';
import 'package:race_tracking_app/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
 //final participantRepository = FirebaseParticipantRepository();

  runApp(
    ChangeNotifierProvider(
      create: (context) => ParticipantProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: raceTheme,
        home: Scaffold(
          body: Center(child: RaceDetails(participants: [],)),
        ),
      ),
    ),
  );
}
