import 'package:flutter/material.dart';
import 'package:race_tracking_app/data/repository/firebase/firebase_participant_repository.dart';
import 'package:race_tracking_app/data/repository/firebase/firebase_race_repository.dart';
import 'package:race_tracking_app/models/race/race.dart';
import 'package:race_tracking_app/screens/result/result_details_screen.dart';
import 'package:race_tracking_app/theme/theme.dart';

class RaceListScreen extends StatefulWidget {
  const RaceListScreen({super.key});

  @override
  State<RaceListScreen> createState() => _RaceListScreenState();
}

class _RaceListScreenState extends State<RaceListScreen> {
  final _raceRepository = FirebaseRaceRepository();
  final _participantRepository = FirebaseParticipantRepository();
  
  bool _isLoading = true;
  List<Race> _races = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadRaces();
  }

  Future<void> _loadRaces() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final races = await _raceRepository.getRace();
      setState(() {
        _races = races;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RaceColors.backgroundAccent,
      appBar: AppBar(
        backgroundColor: RaceColors.backgroundAccentDark,
        toolbarHeight: 95,
        title: Row(
          children: [
            Icon(Icons.bar_chart, color: RaceColors.white, size: 35),
            const SizedBox(width: RaceSpacings.s),
            Text(
              'Races Result',
              style: RaceTextStyles.body.copyWith(color: RaceColors.white),
            ),
          ],
        ),
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: RaceColors.primary),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Error loading races',
                style: RaceTextStyles.label.copyWith(color: RaceColors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage,
                style: RaceTextStyles.label.copyWith(color: RaceColors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadRaces,
                child: const Text('Retry', style: TextStyle(color: Colors.black),),
              ),
            ],
          ),
        ),
      );
    }

    if (_races.isEmpty) {
      return Center(
        child: Text(
          'No races available',
          style: RaceTextStyles.label.copyWith(color: RaceColors.white),
        ),
      );
    }

    return ListView.builder(
      itemCount: _races.length,
      itemBuilder: (context, index) {
        final race = _races[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: RaceColors.neutralLight,
          child: ListTile(
            title: Text(
              race.name,
              style: RaceTextStyles.body.copyWith(color: RaceColors.backgroundAccentDark),
            ),
            subtitle: Text(
              'Participants: ${race.participantIds.length}',
              style: RaceTextStyles.label.copyWith(
                color: RaceColors.backgroundAccentDark,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: RaceColors.backgroundAccent,
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ResultDetailsScreen(
                    raceId: race.id,
                    raceRepository: _raceRepository,
                    participantRepository: _participantRepository,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}