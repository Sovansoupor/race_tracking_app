// import 'package:flutter/material.dart';

// import '../data/repository/firebase/firebase_segment_repository.dart';
// import '../models/segment/segment.dart';

// // class SegmentProvider extends ChangeNotifier {
// //   final FirebaseSegmentRepository _segmentRepository;

// //   List<Segment> allSegments = [];
// //   Map<String, Segment> selectedSegments = {};
// //   Map<String, TextEditingController> distanceControllers = {};

// //   bool _isLoading = false;
// //   String? _error;

// //   bool get isLoading => _isLoading;
// //   String? get error => _error;

// //   SegmentProvider({required FirebaseSegmentRepository segmentRepository})
// //       : _segmentRepository = segmentRepository;

// //   Future<void> fetchSegments() async {
// //     try {
// //       _isLoading = true;
// //       notifyListeners();

// //       // Use your existing repository method to get segments
// //       final fetchedSegments = await _segmentRepository.getSegment();

// //       // Clear existing segments
// //       allSegments.clear();
// //       selectedSegments.clear();

// //       // Update allSegments with fetched data
// //       allSegments = fetchedSegments;

// //       // Initialize controllers for each segment
// //       for (var segment in allSegments) {
// //         // Create a text controller for each segment with its current distance
// //         distanceControllers[segment.id] = TextEditingController(
// //           text: segment.distance?.toString() ?? '',
// //         );

// //         // You might want to add logic here to determine which segments are "selected"
// //         // For now, I'll assume all segments are selected
// //         selectedSegments[segment.id] = segment;
// //       }

// //       // Sort segments by order
// //       allSegments.sort((a, b) => a.order.compareTo(b.order));

// //       _isLoading = false;
// //       notifyListeners();
// //     } catch (e) {
// //       _isLoading = false;
// //       _error = 'Failed to fetch segments: ${e.toString()}';
// //       notifyListeners();
// //       print('Error fetching segments: $e');
// //     }
// //   }

// //   Future<void> saveSegmentDistance({
// //     required String segmentId,
// //     required String unit,
// //   }) async {
// //     print('Saving distance for segmentId: $segmentId');

// //     // Validate input
// //     final distanceText = distanceControllers[segmentId]?.text.trim();
// //     if (distanceText == null || distanceText.isEmpty) {
// //       throw Exception('Distance cannot be empty.');
// //     }

// //     final int? distance = int.tryParse(distanceText);
// //     if (distance == null) {
// //       throw Exception('Distance must be a valid number.');
// //     }

// //     // Convert to meters for consistent storage
// //     final int distanceInMeters = unit.toUpperCase() == "KM" ? distance * 1000 : distance;

// //     // Find the segment
// //     final segment = selectedSegments[segmentId];
// //     if (segment == null) {
// //       print('Segment with id $segmentId not found in selectedSegments.');
// //       throw Exception('Segment not found.');
// //     }

// //     // Update local state using copyWith
// //     selectedSegments[segmentId] = segment.copyWith(
// //       distance: distanceInMeters,
// //       unit: unit,
// //     );

// //     // Also update in allSegments if it exists there
// //     final allSegmentIndex = allSegments.indexWhere((s) => s.id == segmentId);
// //     if (allSegmentIndex >= 0) {
// //       allSegments[allSegmentIndex] = allSegments[allSegmentIndex].copyWith(
// //         distance: distanceInMeters,
// //         unit: unit,
// //       );
// //     }

// //     notifyListeners();

// //     // Save to Firebase using your repository
// //     try {
// //       await _segmentRepository.updateSegment(
// //         segmentId: segment.id,
// //         updatedData: {'distance': distanceInMeters, 'unit': unit},
// //       );
// //       print('Successfully saved segment distance to Firebase');
// //     } catch (e) {
// //       print('Error saving to Firebase: $e');
// //       throw Exception('Failed to save to Firebase: $e');
// //     }
// //   }

// //   // Add a method to toggle segment selection
// //   void toggleSegmentSelection(String segmentId) {
// //     final segment = allSegments.firstWhere(
// //       (s) => s.id == segmentId,
// //       orElse: () => throw Exception('Segment not found'),
// //     );

// //     if (selectedSegments.containsKey(segmentId)) {
// //       selectedSegments.remove(segmentId);
// //     } else {
// //       selectedSegments[segmentId] = segment;
// //     }

// //     notifyListeners();
// //   }

// //   // Clean up controllers when provider is disposed
// //   @override
// //   void dispose() {
// //     for (var controller in distanceControllers.values) {
// //       controller.dispose();
// //     }
// //     super.dispose();
// //   }
// // }

// class SegmentProvider extends ChangeNotifier {
//   final FirebaseSegmentRepository _segmentRepository =
//       FirebaseSegmentRepository();

//   List<Segment> allSegments = [];
//   final Map<String, Segment> selectedSegments = {};
//   final Map<String, TextEditingController> distanceControllers = {};

//   Future<void> fetchSegments() async {
//     try {
//       allSegments = await _segmentRepository.getSegment();
//       notifyListeners();
//     } catch (e) {
//       throw Exception('Failed to fetch segments');
//     }
//   }

//   void toggleSegment(Segment segment) {
//     if (selectedSegments.containsKey(segment.id)) {
//       selectedSegments.remove(segment.id);
//       distanceControllers.remove(segment.id);
//     } else {
//       selectedSegments[segment.id] = segment;
//       distanceControllers[segment.id] = TextEditingController(
//         text: segment.distance?.toString() ?? '',
//       );
//     }
//     notifyListeners();
//   }

//   Future<void> addSegment({
//     required String name,
//     required int order,
//     required ActivityType activityType,
//     required int? distance,
//     required String? unit,
//   }) async {
//     final Segment newSegment = await _segmentRepository.addSegment(
//       name: name,
//       order: order,
//       distance: distance,
//       activityType: activityType,
//       unit: unit,
//     );
//     selectedSegments[newSegment.id] = newSegment;
//     notifyListeners();
//   }

//   Future<void> saveSegmentDistance({
//     required String segmentId,
//     required String unit,
//   }) async {
//     final distanceText = distanceControllers[segmentId]?.text.trim();
//     if (distanceText == null || distanceText.isEmpty) {
//       throw Exception('Distance cannot be empty.');
//     }

//     final int? distance = int.tryParse(distanceText);
//     if (distance == null) {
//       throw Exception('Distance must be a valid number.');
//     }

//     final int distanceInMeters =
//         unit.toUpperCase() == "KM" ? distance * 1000 : distance;

//     final segment = selectedSegments[segmentId];
//     if (segment == null) {
//       throw Exception('Segment not found.');
//     }

//     // Update local state immediately for snappier UI
//     final updatedSegment = segment.copyWith(
//       distance: distanceInMeters,
//       unit: unit,
//     );
//     selectedSegments[segmentId] = updatedSegment;

//     final allIndex = allSegments.indexWhere((s) => s.id == segmentId);
//     if (allIndex >= 0) {
//       allSegments[allIndex] = updatedSegment;
//     }

//     notifyListeners();

//     // Persist to Firebase
//     await _segmentRepository.updateSegment(
//       segmentId: segmentId,
//       updatedData: {'distance': distanceInMeters, 'unit': unit},
//     );

//     // **Re-fetch** from Firebase to sync any other changes
//     await fetchSegments();
//   }

//   @override
//   void dispose() {
//     for (var controller in distanceControllers.values) {
//       controller.dispose();
//     }
//     super.dispose();
//   }
// }
