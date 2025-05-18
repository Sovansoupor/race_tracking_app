import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  Map<String, int> _participantCounts = {};
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
      // Get all races
      final races = await _raceRepository.getRace();
      
      // Initialize participant counts map
      Map<String, int> participantCounts = {};
      
      // Get all participants
      final allParticipants = await _participantRepository.getParticipant();
      
      // Debug: Print participant count
      print('Total participants: ${allParticipants.length}');
      
      // For each race, count participants with matching raceId
      for (final race in races) {
        // Count participants that belong to this race
        final count = allParticipants
            .where((p) => p.raceId == race.id)
            .length;
        
        // Store the count
        participantCounts[race.id] = count;
        
        // Debug: Print the count
        print('Race ${race.name} has ${count} participants');
      }
      
      setState(() {
        _races = races;
        _participantCounts = participantCounts;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading races: $e');
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
        toolbarHeight: 70,
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
                style: RaceTextStyles.label.copyWith(
                  color: RaceColors.white,
                  fontWeight: FontWeight.bold,
                ),
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
                child: const Text(
                  'Retry',
                  style: TextStyle(color: Colors.black),
                ),
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
        // Get the participant count for this race
        final participantCount = _participantCounts[race.id] ?? 0;
        
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: RaceColors.neutralLight,
          child: ListTile(
            title: Text(
              race.name,
              style: RaceTextStyles.body.copyWith(
                color: RaceColors.backgroundAccentDark,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildInfoItem(
                      Icons.calendar_month,
                      DateFormat('dd MMM, yyyy').format(race.startTime),
                    ),
                    const SizedBox(width: 24),
                    _buildInfoItem(
                      Icons.people_alt_outlined,
                      '$participantCount participants',
                    ),
                  ],
                ),
              ],
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: RaceColors.backgroundAccent,
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (context) => ResultDetailsScreen(
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

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: RaceColors.backgroundAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: RaceColors.backgroundAccentDark, size: 16),
        ),
        SizedBox(width: 8),
        Text(
          text,
          style: RaceTextStyles.label.copyWith(
            color: RaceColors.backgroundAccentDark.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}
