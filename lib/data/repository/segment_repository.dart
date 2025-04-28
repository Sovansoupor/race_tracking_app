import 'package:race_tracking_app/models/segment/segment.dart';

abstract class SegmentRepository {
  Future<Segment> addSegment({
    required String name,
    required int order,
    required int? distance,
    required ActivityType activityType,
  });
  Future<List<Segment>> removeSegment({required String id});
  Future<List<Segment>> getSegment();
}