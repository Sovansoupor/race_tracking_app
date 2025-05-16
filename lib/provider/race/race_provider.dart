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
  final Map<String, TextEditingController> distanceControllers = {};

  DateTime? startTime;
  List<Race> _races = [];
  List<Segment> allSegments = [];

  List<Race> get races => _races;
  Map<String, Segment> selectedSegments = {};

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  List<Segment> getSegmentsForRace(Race race) {
    return race.segments.map((segmentId) {
      return allSegments.firstWhere((seg) => seg.id == segmentId);
    }).toList();
  }

  void updateStartTime(DateTime date) {
    startTime = date;
    startTimeController.text = DateFormat('dd/MM/yy').format(date);
    notifyListeners();
  }

  void toggleSegment(Segment segment) {
    if (selectedSegments.containsKey(segment.id)) {
      selectedSegments.remove(segment.id);
      distanceControllers.remove(segment.id);
    } else {
      selectedSegments[segment.id] = segment;
      distanceControllers[segment.id] = TextEditingController(
        text: segment.distance?.toString() ?? '',
      );
    }
    notifyListeners();
  }

  Future<void> fetchSegments() async {
    try {
      allSegments = await _segmentRepository.getSegment();
      print('Fetched segments: $allSegments');
      notifyListeners();
    } catch (e) {
      print('Error fetching segments: $e');
      throw Exception('Failed to fetch segments');
    }
  }

  Future<void> fetchRaces() async {
    _isLoading = true;
    notifyListeners();
    print("Fetching races...");

    try {
      _races = await _raceRepository.getRace();
      print('Fetched races: $_races');
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Error fetching races: $e';
      print(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addRace() async {
    if (nameController.text.isEmpty ||
        startTime == null ||
        selectedSegments.isEmpty) {
      throw Exception('Please fill in all fields');
    }

    try {
      // Build List<Segment> from selectedSegments map
      final segments =
          selectedSegments.entries.map((entry) {
            final segment = entry.value;
            final distanceText = distanceControllers[segment.id]?.text.trim();
            final distance = int.tryParse(distanceText ?? '') ?? 0;

            return segment.copyWith(distance: distance, unit: segment.unit);
          }).toList();

      final newRace = await _raceRepository.addRace(
        id: '',
        name: nameController.text,
        startTime: startTime!,
        participantIds: [],
        segments: segments,
      );

      _races.add(newRace);
      notifyListeners();

      nameController.clear();
      startTimeController.clear();
      startTime = null;
      selectedSegments.clear();
      distanceControllers.clear();
    } catch (e) {
      print('Error adding race: $e');
      throw Exception('Failed to add race');
    }
  }

  Future<void> submitRace() async {
    if (nameController.text.isEmpty ||
        startTime == null ||
        selectedSegments.isEmpty) {
      throw Exception('Please fill in all fields');
    }

    // Convert selectedSegments into a list of Segment objects with updated distance/unit
    final segments =
        selectedSegments.entries.map((entry) {
          final segment = entry.value;
          // Try to get user input distance
          final distanceText = distanceControllers[segment.id]?.text.trim();
          final distance = int.tryParse(distanceText ?? '');

          // Assign default distances based on ActivityType
          final defaultDistance = switch (segment.activityType) {
            ActivityType.swimming => 2,
            ActivityType.running => 10,
            ActivityType.cycling => 20,
            _ => 0,
          };

          return segment.copyWith(
            distance: distance ?? defaultDistance,
            unit: segment.unit ?? 'KM',
          );
        }).toList();

    await _raceRepository.addRace(
      id: '',
      name: nameController.text,
      startTime: startTime ?? DateTime.now(),
      participantIds: [],
      segments: segments,
    );

    await fetchRaces();

    nameController.clear();
    startTimeController.clear();
    startTime = null;
    selectedSegments.clear();
    distanceControllers.clear();

    notifyListeners();
  }

  Future<void> deleteRace(String id) async {
    try {
      // Call the removeRace method with named parameter
      await _raceRepository.removeRace(id: id);

      // Remove the race locally from the list
      _races.removeWhere((race) => race.id == id);

      // Notify listeners to update the UI
      notifyListeners();
    } catch (e) {
      print('Error deleting race: $e');
      throw Exception('Failed to delete race');
    }
  }

  Future<void> addSegment({
    required String name,
    required int order,
    required ActivityType activityType,
    required int? distance,
    required String? unit,
  }) async {
    final Segment newSegment = await _segmentRepository.addSegment(
      name: name,
      order: order,
      distance: distance,
      activityType: activityType,
      unit: unit,
    );
    selectedSegments[newSegment.id] = newSegment;
    notifyListeners();
  }

  // Method to save or update segment distance
  Future<void> saveSegmentDistance({
    required String raceId,
    required String segmentId,
    required String unit,
  }) async {
    print('Saving distance for segmentId: $segmentId');
    print('Current selectedSegments: ${selectedSegments.keys.toList()}');

    // Validate input
    final distanceText = distanceControllers[segmentId]?.text.trim();
    if (distanceText == null || distanceText.isEmpty) {
      throw Exception('Distance cannot be empty.');
    }

    final int? distance = int.tryParse(distanceText);
    if (distance == null) {
      throw Exception('Distance must be a valid number.');
    }

    // Convert distance to meters if necessary
    final int distanceInMeters =
        unit.toUpperCase() == "KM" ? distance * 1000 : distance;

    // Find the segment
    final segment = selectedSegments[segmentId];
    if (segment == null) {
      print('Segment with id $segmentId not found in selectedSegments.');
      throw Exception('Segment not found.');
    }

    // Update the segment's local state
    selectedSegments[segmentId] = Segment(
      id: segment.id,
      name: segment.name,
      order: segment.order,
      activityType: segment.activityType,
      distance: distanceInMeters,
      unit: unit,
    );

    // Also update in allSegments if it exists there
    final allSegmentIndex = allSegments.indexWhere((s) => s.id == segmentId);
    if (allSegmentIndex >= 0) {
      allSegments[allSegmentIndex] = allSegments[allSegmentIndex].copyWith(
        distance: distanceInMeters,
        unit: unit,
      );
    }
    notifyListeners();
    print('allSegments after save: $allSegments');

    // Save the changes to Firebase using the FirebaseSegmentRepository's update method
    try {
      await _segmentRepository.updateSegment(
        segmentId: segment.id,
        updatedData: {'distance': distanceInMeters, 'unit': unit},
      );
    } catch (e) {
      throw Exception('Failed to save to Firebase: $e');
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    startTimeController.dispose();
    for (var controller in distanceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
