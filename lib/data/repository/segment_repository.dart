import 'package:race_tracking_app/models/segment/segment.dart';

abstract class SegmentRepository {
  Future<Segment> addSegment({
    required String name,
    required int order,
    required int? distance,
    required ActivityType activityType,
    required String? unit,
  });
  Future<List<Segment>> removeSegment({required String id});
  Future<List<Segment>> getSegment();

  Future<void> updateSegment({
    required String segmentId,
    required Map<String, dynamic> updatedData,
  });
}
