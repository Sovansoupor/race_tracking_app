import 'dart:async';

import 'package:flutter/material.dart';
import 'package:race_tracking_app/models/segment/segment.dart';

enum ViewMode { grid, massArrival }

class SegmentProvider extends ChangeNotifier {
  // The current activity segment (e.g., swimming, cycling, running)
  ActivityType _activityType = ActivityType.swimming;

  // Tracks which segments have been completed (segment index -> completed)
  final Map<int, bool> _trackedSegments = {};

  // Map of participant bib -> segment -> duration taken for that segment
  final Map<String, Map<ActivityType, Duration>> _participantTimings = {};

  // All segments from the enum
  final List<ActivityType> _segments = ActivityType.values;

  // Current segment index (0-based)
  int _currentSegmentIndex = 0;

  // Flag to indicate if the entire race is completed
  final bool _isRaceCompleted = false;

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

  // Dispose all timers when the provider is disposed
  @override
  void dispose() {
    for (var timer in _activeTimers.values) {
      timer.cancel();
    }
    _raceTimer?.cancel();
    super.dispose();
  }

  // Select segment manually (e.g., by UI tap)
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
  void recordParticipantTime(int participantId, Duration time) {
    if (!_segmentParticipantTimes.containsKey(_activityType)) {
      _segmentParticipantTimes[_activityType] = {};
    }
    _segmentParticipantTimes[_activityType]![participantId] = time;

    // Update participant timings for total time across all segments
    if (!_participantTimings.containsKey(participantId.toString())) {
      _participantTimings[participantId.toString()] = {};
    }
    _participantTimings[participantId.toString()]![_activityType] = time;

    // Mark the current segment as completed if all participants are tracked
    if (_segmentParticipantTimes[_activityType]!.length ==
        _participantTimers.length) {
      _trackedSegments[_currentSegmentIndex] = true;
    }

    notifyListeners();
  }

  // Reset tracking for the current segment
  void resetCurrentSegmentTracking() {
    _segmentParticipantTimes[_activityType] = {};
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
    notifyListeners();
  }

  // Start the race
  void startRace() {
    _isRaceStarted = true;
    notifyListeners();
  }

  // End the race
  void endRace() {
    _isRaceStarted = false;
    notifyListeners();
  }

  // Check if a segment is completed
  bool isSegmentCompleted(int segmentIndex) {
    return _trackedSegments[segmentIndex] ?? false;
  }

  // Calculate total time for each participant across all segments
  Map<int, Duration> calculateTotalTimes() {
    final Map<int, Duration> totalTimes = {};

    _participantTimings.forEach((participantId, segmentTimes) {
      final int id = int.parse(participantId);
      totalTimes[id] = segmentTimes.values.fold(
        Duration.zero,
        (total, segmentTime) => total + segmentTime,
      );
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
}
