import 'package:flutter/material.dart';
import 'package:race_tracking_app/models/segment/segment.dart';

enum ViewMode { grid, massArrival }

class SegmentProvider extends ChangeNotifier {
  // The current activity segment (e.g., swimming, cycling, running)
  ActivityType _activityType = ActivityType.swimming;

  // The current view mode (grid or mass arrival)
  ViewMode _viewMode = ViewMode.grid;

  // Tracks which segments have been completed (segment index -> completed)
  final Map<int, bool> _trackedSegments = {};

  // Map of participant bib -> segment -> duration taken for that segment
  final Map<String, Map<ActivityType, Duration>> _participantTimings = {};

  // All segments from the enum
  final List<ActivityType> _segments = ActivityType.values;

  // Current segment index (0-based)
  int _currentSegmentIndex = 0;

  // Flag to indicate if the entire race is completed
  bool _isRaceCompleted = false;

  // Getters
  int get currentSegmentIndex => _currentSegmentIndex;
  ActivityType get activityType => _activityType;
  ViewMode get viewMode => _viewMode;
  bool get isRaceCompleted => _isRaceCompleted;
  Map<int, bool> get trackedSegments => _trackedSegments;
  Map<String, Map<ActivityType, Duration>> get participantTimings => _participantTimings;

  // Select segment manually (e.g., by UI tap)
  void selectSegment(ActivityType segment) {
    if (_activityType != segment) {
      _activityType = segment;
      _currentSegmentIndex = _segments.indexOf(segment);
      notifyListeners();
    }
  }

  // Select view mode
  void selectView(ViewMode view) {
    if (_viewMode != view) {
      _viewMode = view;
      notifyListeners();
    }
  }

  // Toggle whether a segment is tracked or not (optional usage)
  void toggleSegmentTracking(int segmentId) {
    _trackedSegments[segmentId] = !(_trackedSegments[segmentId] ?? false);
    notifyListeners();
  }

  // Record the time taken by a participant in a segment
  void recordSegmentTime(String bib, ActivityType segment, Duration time) {
    if (!_participantTimings.containsKey(bib)) {
      _participantTimings[bib] = {};
    }
    _participantTimings[bib]![segment] = time;
    notifyListeners();
  }

  // Check if all participants finished the current segment
  bool _isSegmentComplete() {
    if (_participantTimings.isEmpty) return false;

    final totalParticipants = _participantTimings.keys.length;
    final completedCount = _participantTimings.values.where((segmentTimes) {
      return segmentTimes.containsKey(_activityType);
    }).length;

    return completedCount == totalParticipants;
  }

  // Move to next segment if all participants have finished the current segment
  void nextSegmentIfReady() {
    if (_isSegmentComplete()) {
      _trackedSegments[_currentSegmentIndex] = true;

      if (_currentSegmentIndex < _segments.length - 1) {
        _currentSegmentIndex++;
        _activityType = _segments[_currentSegmentIndex];
      } else {
        // All segments completed, mark race as completed
        _isRaceCompleted = true;
      }
      notifyListeners();
    }
  }

  // Get rankings by summing durations of all segments per participant
  List<MapEntry<String, Duration>> getRankings() {
    final completedParticipants = _participantTimings.entries.where(
      (entry) => entry.value.length == _segments.length,
    );

    final rankings = completedParticipants
        .map((entry) => MapEntry(
              entry.key,
              entry.value.values.fold(Duration.zero, (a, b) => a + b),
            ))
        .toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    return rankings;
  }

  // Reset tracking status (segments completed)
  void resetTracking() {
    _trackedSegments.clear();
    notifyListeners();
  }

  // Reset entire race status, timing, and segment progress
  void resetRace() {
    _participantTimings.clear();
    _currentSegmentIndex = 0;
    _activityType = _segments[0];
    _trackedSegments.clear();
    _isRaceCompleted = false;
    notifyListeners();
  }
}
