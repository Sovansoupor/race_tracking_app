import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracking_app/data/repository/participant_repository.dart';
import 'package:race_tracking_app/data/repository/race_repository.dart';
import 'package:race_tracking_app/models/race/race.dart';
import 'package:race_tracking_app/provider/segment/segment_provider.dart';
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
  bool _raceCompleted = false;
  bool _allSegmentsCompleted = false;

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
      final allParticipants =
          await widget.participantRepository.getParticipant();

      // Step 3: Filter participants for this race using raceId
      final raceParticipants =
          allParticipants
              .where((participant) => participant.raceId == widget.raceId)
              .toList();

      // Get the segment provider to check race status
      final segmentProvider = Provider.of<SegmentProvider>(
        context,
        listen: false,
      );
      _raceCompleted =
          !segmentProvider.isRaceStarted &&
          segmentProvider.raceElapsed > Duration.zero;

      // Check if all segments are completed
      _allSegmentsCompleted = true;
      for (int i = 0; i < _race!.segments.length; i++) {
        if (!segmentProvider.isSegmentCompleted(i)) {
          _allSegmentsCompleted = false;
          break;
        }
      }

      // Only process results if race is completed or all segments are done
      if (_raceCompleted || _allSegmentsCompleted) {
        // Step 4: Get ranked results from segment provider
        final rankedResults = segmentProvider.getRankedResults();

        // Step 5: Create race results in ranked order
        _results = [];
        for (int i = 0; i < rankedResults.length; i++) {
          final entry = rankedResults[i];
          // Find the participant with this bib number
          final participant = raceParticipants.firstWhere(
            (p) => p.bibNumber == entry.key,
            orElse:
                () =>
                    throw Exception(
                      'Participant not found for BIB ${entry.key}',
                    ),
          );

          _results.add(
            RaceResult.fromParticipant(
              participant: participant,
              position: i + 1,
              totalTime: entry.value,
            ),
          );
        }
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
        toolbarHeight: 70,
        elevation: 0,
        title: Text(
          _isLoading ? 'Loading...' : _race?.name ?? 'Race Results',
          style: RaceTextStyles.body.copyWith(color: RaceColors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: RaceColors.white),
          onPressed: () => Navigator.of(context).pop(),
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
                onPressed: _loadRaceResults,
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
              // Race status indicator
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _raceCompleted ? RaceColors.green : RaceColors.red,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _raceCompleted ? Icons.check_circle : Icons.timer,
                          color: RaceColors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _raceCompleted
                              ? 'Race Completed'
                              : 'All Segments Completed',
                          style: RaceTextStyles.label.copyWith(
                            color: RaceColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
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
                separatorBuilder:
                    (context, index) => Divider(
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
