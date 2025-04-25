import 'package:race_tracking_app/models/segment/segment.dart';

class SegmentDto {
  static Segment fromJson(String id, Map<String, dynamic> json) {
    return Segment(
      id: id,
      name: json['name'] ?? 'Unknown',
      order: json['order'] ?? 0,
      distance: json['distance'] ?? null,
      activityType: json['activityType'] != null
          ? ActivityType.values.firstWhere((e) => e.toString() == 'ActivityType.${json['activityType']}')
          : ActivityType.running,
    );
  }
  static Map<String, dynamic> toJson(Segment segment) {
    return {
      'name': segment.name,
      'order': segment.order,
      'distance': segment.distance,
      'activityType': segment.activityType.toString().split('.').last,
    };
  }
}