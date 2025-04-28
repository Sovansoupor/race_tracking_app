import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:race_tracking_app/data/repository/firebase/firebase_race_repository.dart';
import 'package:race_tracking_app/data/repository/firebase/firebase_segment_repository.dart';

import '../../models/race/race.dart';
import '../../models/segment/segment.dart';

class RaceProvider extends ChangeNotifier {
  final FirebaseRaceRepository _raceRepository = FirebaseRaceRepository();
  final FirebaseSegmentRepository _segmentRepository =
      FirebaseSegmentRepository();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();

  DateTime? startTime;
  final Set<Segment> selectedSegments = {};

  // Update start date and text
  void updateStartTime(DateTime date) {
    startTime = date;
    startTimeController.text = DateFormat('dd/MM/yy').format(date);
    notifyListeners();
  }

  // Toggle segment selection
  void toggleSegment(Segment segment) {
    if (selectedSegments.contains(segment)) {
      selectedSegments.remove(segment);
    } else {
      selectedSegments.add(segment);
    }
    notifyListeners();
  }

  List<Race> _races = [];
  List<Race> get races => _races;

  // Loading and error handling
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  Future<void> fetchRaces() async {
    _isLoading = true;
    notifyListeners();
    print("Fetching races..."); 

    try {
      _races = await _raceRepository.getRace();
      notifyListeners();
      _errorMessage = ''; // Reset error message if successful
    } catch (e) {
      _errorMessage = 'Error fetching races: $e';
      print(_errorMessage); // Print error to the console for debugging
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new race
  Future<void> addRace() async {
    if (nameController.text.isEmpty ||
        startTime == null ||
        selectedSegments.isEmpty) {
      throw Exception('Please fill in all fields');
    }

    try {
      // Add new race to the repository
      final newRace = await _raceRepository.addRace(
        id: '',
        name: nameController.text,
        startTime: startTime!,
        participantIds: [],
        segments: selectedSegments.map((segment) => segment.id).toList(),
      );

      // Add the new race to the local _races list
      _races.add(newRace); // This line adds the race directly to the list
      notifyListeners(); // Notify listeners to update the UI

      // Clear fields after adding the race
      nameController.clear();
      startTimeController.clear();
      startTime = null;
      selectedSegments.clear();
    } catch (e) {
      print('Error adding race: $e');
      throw Exception('Failed to add race');
    }
  }

  // Add segment
  Future<void> addSegment({
    required String name,
    required int order,
    required ActivityType activityType,
    required int? distance,
  }) async {
    final Segment newSegment = await _segmentRepository.addSegment(
      name: name,
      order: order,
      distance: distance,
      activityType: activityType,
    );
    selectedSegments.add(newSegment);
    notifyListeners();
  }

  // Submit race
  Future<void> submitRace() async {
    if (nameController.text.isEmpty ||
        startTime == null ||
        selectedSegments.isEmpty) {
      throw Exception('Please fill in all fields');
    }

    // Submit new race
    await _raceRepository.addRace(
      id: '',
      name: nameController.text,
      startTime: startTime!,
      participantIds: [],
      segments: selectedSegments.map((segment) => segment.id).toList(),
    );

    // Fetch the updated races after submission
    await fetchRaces();

    // Clear fields after submission
    nameController.clear();
    startTimeController.clear();
    startTime = null;
    selectedSegments.clear();

    // Notify listeners to update the UI
    notifyListeners();
  }

  // Dispose controllers when provider is destroyed
  @override
  void dispose() {
    nameController.dispose();
    startTimeController.dispose();
    super.dispose();
  }
}
