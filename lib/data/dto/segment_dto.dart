import 'package:race_tracking_app/models/segment/segment.dart';

class SegmentDto {
  static Segment fromJson(String id, Map<String, dynamic> json) {
    final activityTypeStr = json['activityType'] as String?;
    final activityType =
        activityTypeStr != null
            ? ActivityType.values.firstWhere(
              (e) => e.toString() == 'ActivityType.$activityTypeStr',
              orElse: () => ActivityType.running,
            )
            : ActivityType.running;

    final name =
        (json['name'] as String?)?.isNotEmpty == true
            ? json['name'] as String
            : id;
    return Segment(
      id: id,
      name: name,
      order: json['order'] as int? ?? 0,
      distance: json['distance'] as int? ?? null,
      unit: json['unit'] as String?,
      activityType: activityType,
    );
  }

  static Map<String, dynamic> toJson(Segment segment) {
    return {
      'name': segment.name,
      'order': segment.order,
      'distance': segment.distance,
      'activityType': segment.activityType.toString().split('.').last,
      'unit': segment.unit,
    };
  }
}
