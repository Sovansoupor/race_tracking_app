import 'package:flutter/material.dart';
import 'package:race_tracking_app/screens/race/race_form.dart';
import 'package:race_tracking_app/theme/theme.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Scaffold(
        backgroundColor: RaceColors.backgroundAccent,
        appBar: AppBar(
          title: Text(
            'Hello, Rivita',
            style: RaceTextStyles.subheadline.copyWith(color: Colors.white),
          ),
          centerTitle: false,
          backgroundColor: RaceColors.backgroundAccent,
        ),
        body:
            competitions.isEmpty
                ? _buildNoCompetition()
                : _buildCompetitionList(),

        // floating button
        floatingActionButton: FloatingActionButton(
          backgroundColor: RaceColors.primary,
          shape: CircleBorder(),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => RaceForm()));
          },
          child: const Icon(Icons.add, size: 30, color: Colors.white),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        
      ),
    );
  }

  Widget _buildNoCompetition() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'No competition',
            style: RaceTextStyles.body.copyWith(color: RaceColors.textNormal),
          ),
          Text(
            'Create a new competition',
            style: RaceTextStyles.label.copyWith(color: RaceColors.textNormal),
          ),
          Text(
            'Tap + to create',
            style: RaceTextStyles.label.copyWith(color: RaceColors.textNormal),
          ),
        ],
      ),
    );
  }

  Widget _buildCompetitionList() {
    return ListView.builder(
      itemCount: competitions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(competitions[index]),
          onTap: () {
            // Handle competition selection
          },
        );
      },
    );
  }
}
