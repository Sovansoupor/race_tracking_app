import 'package:flutter/material.dart';
import 'package:race_tracking_app/data/repository/participant_repository.dart';
import 'package:race_tracking_app/data/repository/race_repository.dart';
import 'package:race_tracking_app/models/race/race.dart';
import 'package:race_tracking_app/screens/result/race_result.dart';
import 'package:race_tracking_app/screens/result/widget/result_row.dart';
import 'package:race_tracking_app/screens/result/widget/result_table_header.dart';
import 'package:race_tracking_app/theme/theme.dart';
import 'package:race_tracking_app/widgets/display/race_divider.dart';

class ResultDetailsScreen extends StatefulWidget {
  final String raceId;
  final RaceRepository raceRepository;
  final ParticipantRepository participantRepository;

  const ResultDetailsScreen({
    super.key,
    required this.raceId,
    required this.raceRepository,
    required this.participantRepository,
  });

  @override
  State<ResultDetailsScreen> createState() => _ResultDetailsScreenState();
}

class _ResultDetailsScreenState extends State<ResultDetailsScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  Race? _race;
  List<RaceResult> _results = [];

  @override
  void initState() {
    super.initState();
    _loadRaceResults();
  }

  Future<void> _loadRaceResults() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Step 1: Get the race
      final races = await widget.raceRepository.getRace();
      _race = races.firstWhere(
        (race) => race.id == widget.raceId,
        orElse: () => throw Exception('Race not found'),
      );

      // Step 2: Get all participants
      final allParticipants = await widget.participantRepository.getParticipant();
      
      // Step 3: Filter participants for this race
      final raceParticipants = allParticipants
          .where((participant) => _race!.participantIds.contains(participant.id))
          .toList();
      
      // Step 4: Calculate times and sort participants
      final List<Map<String, dynamic>> participantsWithTime = [];
      
      for (final participant in raceParticipants) {
        // Calculate total time by summing segment times
        Duration totalTime = Duration.zero;
        for (final segmentId in _race!.segments) {
          final segmentTime = participant.segmentTimes[segmentId];
          if (segmentTime != null) {
            totalTime += segmentTime;
          }
        }
        
        participantsWithTime.add({
          'participant': participant,
          'totalTime': totalTime,
        });
      }
      
      // Sort by total time (fastest first)
      participantsWithTime.sort((a, b) => 
          (a['totalTime'] as Duration).compareTo(b['totalTime'] as Duration));
      
      // Step 5: Create race results in ranked order
      _results = [];
      for (int i = 0; i < participantsWithTime.length; i++) {
        final entry = participantsWithTime[i];
        _results.add(RaceResult.fromParticipant(
          participant: entry['participant'],
          position: i + 1,
          totalTime: entry['totalTime'],
        ));
      }
      
      setState(() {
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
        elevation: 0,
        title: Row(
          children: [
            Text(
              'Result',
              style: RaceTextStyles.heading.copyWith(color: RaceColors.white),
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
                'Error loading results',
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
                onPressed: _loadRaceResults,
                child: const Text('Retry', style: TextStyle(color: Colors.black),),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          color: RaceColors.backgroundAccent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Race Name
              Text(
                _race?.name ?? 'Race Details',
                style: RaceTextStyles.body.copyWith(color: RaceColors.white),
              ),
              const SizedBox(height: 20),

              // Table header
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: ResultTableHeader(),
              ),
            ],
          ),
        ),
        const RaceDivider(),
        
        // Results List
        _results.isEmpty 
            ? Expanded(
                child: Center(
                  child: Text(
                    'No results available for this race',
                    style: RaceTextStyles.label.copyWith(color: RaceColors.white),
                  ),
                ),
              )
            : Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: _results.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: RaceColors.white.withOpacity(0.1),
                    indent: 16,
                    endIndent: 16,
                  ),
                  itemBuilder: (context, index) {
                    final result = _results[index];
                    return ResultRow(
                      rank: result.rank,
                      name: result.name,
                      bib: result.bib,
                      result: result.result,
                    );
                  },
                ),
              ),
      ],
    );
  }
}