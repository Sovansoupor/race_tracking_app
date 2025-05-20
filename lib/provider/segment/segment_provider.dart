import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:race_tracking_app/models/segment/segment.dart';
import 'package:race_tracking_app/data/repository/firebase/firebase_race_repository.dart';

enum ViewMode { grid, massArrival }

class SegmentProvider extends ChangeNotifier {
  // The current activity segment (e.g., swimming, cycling, running)
  ActivityType _activityType = ActivityType.swimming;
  String? _currentRaceId;
  String? get currentRaceId => _currentRaceId;

  // Tracks which segments have been completed by race ID
  final Map<String, Map<int, bool>> _trackedSegmentsByRace = {};
  
  // Set to track which races have been completed
  final Set<String> _completedRaces = {};

  // Map of participant bib -> segment -> duration taken for that segment
  final Map<String, Map<ActivityType, Duration>> _participantTimings = {};

  // All segments from the enum
  final List<ActivityType> _segments = ActivityType.values;

  // Current segment index (0-based)
  int _currentSegmentIndex = 0;

  // Flag to indicate if the entire race is completed
  bool _isRaceCompleted = false;

  // Map to track elapsed time for each participant (by index)
  final Map<int, Duration> _participantTimers = {};

  // Map to manage active timers for each participant
  final Map<int, Timer> _activeTimers = {};

  // Global race state
  bool _isRaceStarted = false;
  Timer? _raceTimer;
  Duration _raceElapsed = Duration.zero;

  // Map to track participant times for each segment
  final Map<ActivityType, Map<int, Duration>> _segmentParticipantTimes = {};

  // Getters
  int get currentSegmentIndex => _currentSegmentIndex;
  ActivityType get activityType => _activityType;
  bool get isRaceCompleted => _isRaceCompleted;
  Map<int, Duration> get participantTimers => _participantTimers;
  bool get isRaceStarted => _isRaceStarted;
  Duration get raceElapsed => _raceElapsed;
  Map<int, Duration> get currentSegmentParticipantTimes =>
      _segmentParticipantTimes[_activityType] ?? {};
      
  // Get the set of completed races
  Set<String> getCompletedRaces() => _completedRaces;
  
  // Check if a specific race is completed
  bool isRaceCompletedById(String raceId) => _completedRaces.contains(raceId);
  
  // Mark a race as completed and save to Firebase
  Future<void> markRaceAsCompleted(String raceId) async {
    _completedRaces.add(raceId);
    notifyListeners();
    
    // Save to Firebase for persistence
    try {
      final raceRepo = FirebaseRaceRepository();
      await raceRepo.markRaceAsCompleted(raceId);
      print('Race $raceId marked as completed in Firebase');
    } catch (e) {
      print('Error marking race as completed in Firebase: $e');
    }
  }
  
  // Load race completion status from Firebase
  Future<void> loadRaceCompletionStatus(String raceId) async {
    try {
      final raceRepo = FirebaseRaceRepository();
      final isCompleted = await raceRepo.isRaceCompleted(raceId);
      
      if (isCompleted && !_completedRaces.contains(raceId)) {
        _completedRaces.add(raceId);
        notifyListeners();
        print('Loaded completion status for race $raceId: completed');
      }
    } catch (e) {
      print('Error loading race completion status: $e');
    }
  }

  // Dispose all timers when the provider is disposed
  @override
  void dispose() {
    for (var timer in _activeTimers.values) {
      timer.cancel();
    }
    _raceTimer?.cancel();
    super.dispose();
  }

  // Select segment manually
  void selectSegment(ActivityType segment) {
    if (_activityType != segment) {
      _activityType = segment;
      _currentSegmentIndex = _segments.indexOf(segment);

      // Only reset tracking if the segment has not been tracked yet
      if (!_segmentParticipantTimes.containsKey(segment)) {
        resetCurrentSegmentTracking();
      }

      notifyListeners();
    }
  }

  // Record time for a participant in the current segment
  void recordParticipantTime(String raceId, int participantId, Duration time) {
    if (!_segmentParticipantTimes.containsKey(_activityType)) {
      _segmentParticipantTimes[_activityType] = {};
    }
    _segmentParticipantTimes[_activityType]![participantId] = time;

    // Update participant timings for total time across all segments
    if (!_participantTimings.containsKey(participantId.toString())) {
      _participantTimings[participantId.toString()] = {};
    }
    _participantTimings[participantId.toString()]![_activityType] = time;

    // Ensure the tracked segments map exists for the race
    if (!_trackedSegmentsByRace.containsKey(raceId)) {
      _trackedSegmentsByRace[raceId] = {};
    }

    // Mark the current segment as completed if all participants are tracked
    if (_segmentParticipantTimes[_activityType]!.length ==
            _participantTimers.length &&
        _participantTimers.isNotEmpty) {
      _trackedSegmentsByRace[raceId]![currentSegmentIndex] = true;
    }

    notifyListeners();
  }

  // Reset tracking for the current segment
  void resetCurrentSegmentTracking() {
    _segmentParticipantTimes[_activityType] = {};
    for (var raceId in _trackedSegmentsByRace.keys) {
      _trackedSegmentsByRace[raceId]![currentSegmentIndex] = false;
    }
    notifyListeners();
  }

  // Start the global race timer
  void startRaceTimer() {
    _raceElapsed = Duration.zero;
    _raceTimer?.cancel(); // Cancel any existing timer
    _raceTimer = Timer.periodic(Duration(seconds: 1), (_) {
      _raceElapsed += Duration(seconds: 1);
      notifyListeners();
    });
  }

  // Stop the global race timer
  void stopRaceTimer() {
    _raceTimer?.cancel();
    
    // Mark the current race as completed if there is one
    if (_currentRaceId != null) {
      markRaceAsCompleted(_currentRaceId!);
    }
    
    _isRaceCompleted = true; // Mark race as completed when timer stops
    notifyListeners();
  }

  // Start the race
  void startRace(String raceId) {
    _currentRaceId = raceId;
    _isRaceStarted = true;
    _isRaceCompleted = false;
    
    // Don't clear participant timers if we're resuming a race
    if (!_participantTimings.keys.any((key) => key.isNotEmpty)) {
      _participantTimers.clear();
    }
    
    // Make sure we have a tracking entry for this race
    if (!_trackedSegmentsByRace.containsKey(raceId)) {
      _trackedSegmentsByRace[raceId] = {};
    }
    
    notifyListeners();
  }

  // End the race and save results
  Future<void> endRace() async {
    // Mark the current race as completed if there is one
    if (_currentRaceId != null) {
      await markRaceAsCompleted(_currentRaceId!);
    }
    
    _isRaceStarted = false;
    _isRaceCompleted = true;
    _currentRaceId = null;
    notifyListeners();
  }

  // Check if a segment is completed for a specific race
  bool isSegmentCompletedForRace(String raceId, int segmentIndex) {
    return _trackedSegmentsByRace[raceId]?[segmentIndex] ?? false;
  }

  // Check if all segments are completed for a specific race
  bool areAllSegmentsCompletedForRace(String raceId, int totalSegments) {
    if (_trackedSegmentsByRace[raceId]?.isEmpty ?? true) return false;

    for (int i = 0; i < totalSegments; i++) {
      if (!(_trackedSegmentsByRace[raceId]?[i] ?? false)) {
        return false;
      }
    }
    return true;
  }

  // Calculate total time for each participant across all segments
  Map<int, Duration> calculateTotalTimes() {
    final Map<int, Duration> totalTimes = {};

    _participantTimings.forEach((participantId, segmentTimes) {
      try {
        final int id = int.parse(participantId);
        final duration = segmentTimes.values.fold(
          Duration.zero,
          (total, segmentTime) => total + segmentTime,
        );
        
        // Only add if the duration is not zero
        if (duration.inMilliseconds > 0) {
          totalTimes[id] = duration;
        }
      } catch (e) {
        print('Error calculating total time for participant $participantId: $e');
      }
    });

    // Debug output
    print('Total times calculated: ${totalTimes.length}');
    totalTimes.forEach((bib, time) {
      print('BIB $bib: ${time.inMinutes}m ${time.inSeconds % 60}s');
    });

    return totalTimes;
  }

  // Get ranked results based on total times
  List<MapEntry<int, Duration>> getRankedResults() {
    final totalTimes = calculateTotalTimes();

    // Sort participants by total time (ascending)
    final sortedResults =
        totalTimes.entries.toList()..sort((a, b) => a.value.compareTo(b.value));

    return sortedResults;
  }
  
  // Get ranked results for a specific race
  List<MapEntry<int, Duration>> getRankedResultsForRace(String raceId, List<int> raceBibNumbers) {
    final totalTimes = calculateTotalTimes();
    
    // Filter results to only include participants from this race
    final raceResults = totalTimes.entries
        .where((entry) => raceBibNumbers.contains(entry.key))
        .toList();
    
    // Sort by time (ascending)
    raceResults.sort((a, b) => a.value.compareTo(b.value));
    
    return raceResults;
  }

  // Add a participant to be tracked
  void addParticipantToTrack(int bibNumber) {
    if (!_participantTimers.containsKey(bibNumber)) {
      _participantTimers[bibNumber] = Duration.zero;
      notifyListeners();
    }
  }

  // Add multiple participants to be tracked
  void addParticipantsToTrack(List<int> bibNumbers) {
    bool changed = false;
    for (final bib in bibNumbers) {
      if (!_participantTimers.containsKey(bib)) {
        _participantTimers[bib] = Duration.zero;
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
    }
  }

  // Clear all participant data (for testing)
  void clearAllData() {
    _trackedSegmentsByRace.clear();
    _participantTimings.clear();
    _participantTimers.clear();
    _segmentParticipantTimes.clear();
    _completedRaces.clear();
    _isRaceCompleted = false;
    _isRaceStarted = false;
    _raceElapsed = Duration.zero;
    _raceTimer?.cancel();
    notifyListeners();
  }
  
  // Add a participant time directly (for testing or manual entry)
  void addParticipantTimeDirectly(int bibNumber, ActivityType activity, Duration time) {
    if (!_participantTimings.containsKey(bibNumber.toString())) {
      _participantTimings[bibNumber.toString()] = {};
    }
    
    _participantTimings[bibNumber.toString()]![activity] = time;
    
    if (!_segmentParticipantTimes.containsKey(activity)) {
      _segmentParticipantTimes[activity] = {};
    }
    
    _segmentParticipantTimes[activity]![bibNumber] = time;
    
    notifyListeners();
    
    print('Added time directly for BIB $bibNumber: ${time.inMinutes}m ${time.inSeconds % 60}s');
  }
}
