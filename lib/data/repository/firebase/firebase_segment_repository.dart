// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:race_tracking_app/data/dto/segment_dto.dart';
// import 'package:race_tracking_app/data/repository/segment_repository.dart';
// import 'package:race_tracking_app/models/segment/segment.dart';

// class FirebaseSegmentRepository extends SegmentRepository {
//   static const String baseUrl =
//       'https://flutter2-race-tracking-app-default-rtdb.asia-southeast1.firebasedatabase.app/';
//   static const String segmentCollection = "Segment";
//   static const String allSegmentUrl = '$baseUrl/$segmentCollection.json';
//   @override
//   Future<Segment> addSegment({
//     required String name,
//     required int order,
//     required ActivityType activityType,
//     required int? distance,
//     required String? unit,
//   }) async {
//     Uri uri = Uri.parse(allSegmentUrl);

//     // Create a new data
//     final newSegmentData = {
//       'name': name,
//       'order': order,
//       'activityType': activityType.name,
//       'distance': distance,
//       'unit': unit,
//     };
//     final http.Response response = await http.post(
//       uri,
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode(newSegmentData),
//     );

//     // Handle errors
//     if (response.statusCode != HttpStatus.ok) {
//       throw Exception('Failed to add segment');
//     }
//     // Parse the response to get the Firebase-generated ID
//     final responseData = json.decode(response.body) as Map<String, dynamic>;
//     final String id =
//         responseData['name']; // Firebase returns the generated ID in the 'name' field

//     // Return the created segment
//     return Segment(
//       name: name,
//       order: order,
//       id: id,
//       activityType: activityType,
//       distance: distance,
//       unit: unit,
//     );
//   }

//   @override
//   Future<List<Segment>> getSegment() async {
//     Uri uri = Uri.parse(allSegmentUrl);
//     final http.Response response = await http.get(uri);

//     // Handle errors
//     if (response.statusCode != HttpStatus.ok &&
//         response.statusCode != HttpStatus.created) {
//       throw Exception('Failed to load');
//     }

//     // Return all segments
//     final data = json.decode(response.body) as Map<String, dynamic>?;

//     if (data == null) return [];
//     return data.entries
//         .map((entry) => SegmentDto.fromJson(entry.key, entry.value))
//         .toList();
//   }

//   @override
//   Future<List<Segment>> removeSegment({required String id}) async {
//     Uri uri = Uri.parse('$baseUrl/$segmentCollection/$id.json');
//     final http.Response response = await http.delete(uri);

//     // Handle errors
//     if (response.statusCode != HttpStatus.ok) {
//       throw Exception('Failed to delete course');
//     }

//     return await getSegment();
//   }

//   // ✅ New method to update the segment's distance
//   Future<void> updateSegment({
//     required String segmentId,
//     required Map<String, dynamic> updatedData,
//   }) async {
//     Uri uri = Uri.parse('$baseUrl/$segmentCollection/$segmentId.json');
//     final http.Response response = await http.patch(
//       uri,
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode(updatedData),
//     );

//     // Handle errors
//     if (response.statusCode != HttpStatus.ok) {
//       throw Exception('Failed to update segment');
//     }
//   }
// }
