import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracking_app/screens/race/race_form.dart';
import 'package:race_tracking_app/theme/theme.dart';
import '../../provider/race/race_provider.dart';
import 'race_home_screen.dart';

class HomeScreen extends StatelessWidget {
  final String username;
  final List<String> competitions;

  const HomeScreen({
    required this.username,
    required this.competitions, 
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: RaceColors.backgroundAccent,
        appBar: AppBar(
          toolbarHeight: 70,
          title: Text(
            'Race Tracker',
            style: RaceTextStyles.subheadline.copyWith(color: Colors.white),
          ),
          // centerTitle: false,
          backgroundColor: RaceColors.backgroundAccentDark,
        ),
        body: RaceHomeScreen(),

        // floating button
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FloatingActionButton(
            backgroundColor: RaceColors.primary,
            shape: CircleBorder(),
            onPressed: () {
              // After the RaceForm is completed, fetch races again
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => RaceForm())).then((
                _,
              ) {
                // Fetch races after returning from RaceForm
                // for it to automatically rebuild the UI when new race to display
                Provider.of<RaceProvider>(context, listen: false).fetchRaces();
              });
            },
            child: const Icon(Icons.add, size: 30, color: Colors.white),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
