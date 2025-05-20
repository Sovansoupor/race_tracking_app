import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracking_app/data/dto/race_result_dto.dart';
import 'package:race_tracking_app/data/repository/firebase/firebase_race_repository.dart';
import 'package:race_tracking_app/data/repository/participant_repository.dart';
import 'package:race_tracking_app/data/repository/race_repository.dart';
import 'package:race_tracking_app/models/participant/participant.dart';
import 'package:race_tracking_app/models/race/race.dart';
import 'package:race_tracking_app/provider/segment/segment_provider.dart';
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
  List<Participant> _participants = [];
  Map<int, Duration> _totalTimes = {};
  List<int> _rankings = []; // Store the order of bibNumbers by rank
  bool _raceCompleted = false;

  @override
  void initState() {
    super.initState();
    _loadRaceResults();
  }

  // Format duration to string (HH:MM:SS)
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
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

      // Check if this race has saved results in Firebase
      final firebaseRaceRepo = widget.raceRepository as FirebaseRaceRepository;
      final hasStoredResults = await firebaseRaceRepo.raceResultsExist(
        widget.raceId,
      );

      // Check if race is marked as completed in Firebase
      _raceCompleted = await firebaseRaceRepo.isRaceCompleted(widget.raceId);

      if (hasStoredResults) {
        // Load results from Firebase
        final resultData = await firebaseRaceRepo.getRaceResults(widget.raceId);

        // Convert to Participants and total times
        _participants = [];
        _totalTimes = {};
        _rankings = [];

        for (final data in resultData) {
          final dto = RaceResultDto.fromJson(data);
          final participant = dto.toParticipant();

          _participants.add(participant);
          _totalTimes[participant.bibNumber] = Duration(
            milliseconds: dto.totalTimeMs,
          );
          _rankings.add(participant.bibNumber);
        }
      } else if (_raceCompleted) {
        // If race is completed but no results in Firebase, try to get from segment provider

        // Step 2: Get all participants
        final allParticipants =
            await widget.participantRepository.getParticipant();

        // Step 3: Filter participants for this race using raceId
        _participants =
            allParticipants
                .where((participant) => participant.raceId == widget.raceId)
                .toList();

        // Get the BIB numbers for participants in this race
        final raceBibNumbers = _participants.map((p) => p.bibNumber).toList();

        // Get the segment provider to check race status
        final segmentProvider = Provider.of<SegmentProvider>(
          context,
          listen: false,
        );

        // Get total times for all participants
        _totalTimes = segmentProvider.calculateTotalTimes();

        // Create rankings by sorting participants by total time
        _rankings = raceBibNumbers.toList();
        _rankings.sort((a, b) {
          final timeA = _totalTimes[a] ?? Duration.zero;
          final timeB = _totalTimes[b] ?? Duration.zero;
          return timeA.compareTo(timeB);
        });
      } else {
        // Race is not completed, just get participants
        final allParticipants =
            await widget.participantRepository.getParticipant();
        _participants =
            allParticipants
                .where((participant) => participant.raceId == widget.raceId)
                .toList();
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
    final segmentProvider = Provider.of<SegmentProvider>(context);

    // Update race completion status whenever the segment provider changes
    final isCompletedInProvider = segmentProvider.isRaceCompletedById(
      widget.raceId,
    );
    if (isCompletedInProvider != _raceCompleted) {
      setState(() {
        _raceCompleted = isCompletedInProvider;
      });
    }

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
                              : 'Race In Progress',
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
              if (_raceCompleted)
                const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: ResultTableHeader(),
                ),
            ],
          ),
        ),
        if (_raceCompleted) const RaceDivider(),

        // Results List - Only show if race is completed
        if (!_raceCompleted)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    color: RaceColors.white.withOpacity(0.7),
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Race has not been completed yet',
                    style: RaceTextStyles.body.copyWith(
                      color: RaceColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Results will be available once the race is finished',
                    style: RaceTextStyles.label.copyWith(
                      color: RaceColors.white.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else if (_rankings.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    color: RaceColors.white.withOpacity(0.7),
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No results available for this race',
                    style: RaceTextStyles.body.copyWith(
                      color: RaceColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The race is completed but no results were recorded',
                    style: RaceTextStyles.label.copyWith(
                      color: RaceColors.white.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: _rankings.length,
              separatorBuilder:
                  (context, index) => Divider(
                    height: 1,
                    color: RaceColors.white.withOpacity(0.1),
                    indent: 16,
                    endIndent: 16,
                  ),
              itemBuilder: (context, index) {
                final bibNumber = _rankings[index];
                final participant = _participants.firstWhere(
                  (p) => p.bibNumber == bibNumber,
                  orElse:
                      () => Participant(
                        {},
                        firstName: 'Unknown',
                        lastName: '',
                        gender: '',
                        age: 0,
                        bibNumber: bibNumber,
                      ),
                );
                final time = _totalTimes[bibNumber] ?? Duration.zero;

                // Debug output for this row
                print(
                  'Row $index: BIB $bibNumber, Time: ${_formatDuration(time)}',
                );

                // Convert values to strings for ResultRow
                return ResultRow(
                  rank: '${index + 1}', // Convert rank to string
                  name: '${participant.firstName} ${participant.lastName}',
                  bib: 'BIB${participant.bibNumber}', // Format bib number
                  result: _formatDuration(time), // Format duration as string
                );
              },
            ),
          ),
      ],
    );
  }
}
