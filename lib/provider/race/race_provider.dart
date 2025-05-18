import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:race_tracking_app/data/repository/firebase/firebase_race_repository.dart';
import '../../models/race/race.dart';
import '../../models/segment/segment.dart';

class SegmentInput {
  final TextEditingController nameController;
  final TextEditingController distanceController;
  final ActivityType activityType;

  SegmentInput({
    String? initialName,
    String? initialDistance,
    required this.activityType,
  }) : nameController = TextEditingController(text: initialName ?? ''),
       distanceController = TextEditingController(text: initialDistance ?? '');

  void dispose() {
    nameController.dispose();
    distanceController.dispose();
  }
}

class RaceProvider extends ChangeNotifier {
  final FirebaseRaceRepository _raceRepository = FirebaseRaceRepository();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();

  DateTime? startTime;
  List<Race> _races = [];
  List<SegmentInput> segmentInputs = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Track race states individually
  final Map<String, bool> _raceStarted = {};
  final Map<String, bool> _raceCompleted = {};

  List<Race> get races => _races;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Check if a race is started
  bool isRaceStarted(String raceId) {
    return _raceStarted[raceId] ?? false;
  }

  // Check if a race is completed
  bool isRaceCompleted(String raceId) {
    return _raceCompleted[raceId] ?? false;
  }

  // Start a race
  void startRace(String raceId) {
    _raceStarted[raceId] = true;
    _raceCompleted[raceId] = false;
    notifyListeners();
  }

  // End a race
  void endRace(String raceId) {
    _raceStarted[raceId] = false;
    _raceCompleted[raceId] = true;
    notifyListeners();
  }

  void updateStartTime(DateTime date) {
    startTime = date;
    startTimeController.text = DateFormat('dd/MM/yy').format(date);
    notifyListeners();
  }

  Future<void> fetchRaces() async {
    _isLoading = true;
    notifyListeners();

    try {
      _races = await _raceRepository.getRace();
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Error fetching races: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitRace() async {
    if (nameController.text.isEmpty ||
        startTime == null ||
        segmentInputs.isEmpty) {
      throw Exception('Please fill in all fields');
    }

    for (var input in segmentInputs) {
      if (input.nameController.text.isEmpty ||
          input.distanceController.text.isEmpty) {
        throw Exception('Please fill in all fields for segments');
      }
    }

    final segments =
        segmentInputs.map((input) {
          return Segment(
            id: '', // ID will be generated in Firebase
            name: input.nameController.text,
            distance:
                input.distanceController.text.trim(), // Save distance as-is
            order: segmentInputs.indexOf(input), // Set order based on index
            activityType: input.activityType,
          );
        }).toList();

    try {
      await _raceRepository.addRace(
        id: '',
        name: nameController.text,
        startTime: startTime!,
        segments: segments,
      );
    } catch (e) {
      throw Exception('Failed to save race');
    }

    await fetchRaces();
    _clearInputs();
    notifyListeners();
  }

  Future<void> deleteRace(String id) async {
    try {
      await _raceRepository.removeRace(id: id);
      _races.removeWhere((race) => race.id == id);
      _raceStarted.remove(id);
      _raceCompleted.remove(id);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to delete race');
    }
  }

  void _clearInputs() {
    nameController.clear();
    startTimeController.clear();
    startTime = null;
    for (var input in segmentInputs) {
      input.dispose();
    }
    segmentInputs.clear();
  }

  @override
  void dispose() {
    nameController.dispose();
    startTimeController.dispose();
    for (var input in segmentInputs) {
      input.dispose();
    }
    super.dispose();
  }
}
