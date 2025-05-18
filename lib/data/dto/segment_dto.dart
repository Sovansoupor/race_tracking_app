// lib/data/dto/segment_dto.dart

import 'package:race_tracking_app/models/segment/segment.dart';

class SegmentDto {
  /// Firestore/RealtimeDB JSON → Segment
  static Segment fromJson(String id, Map<String, dynamic> json) {
    // Parse activityType by matching the enum .name
    final typeName = json['activityType'] as String? ?? '';
    final activityType = ActivityType.values.firstWhere(
      (e) => e.name == typeName,
      orElse: () => ActivityType.running,
    );

    return Segment(
      id: id,
      name: json['name'] as String? ?? '',
      order: json['order'] as int? ?? 0,
      distance: json['distance'] as String,
      // unit: json['unit'] as String?,
      activityType: activityType,
    );
  }

  /// Segment → JSON for Firestore/RealtimeDB
  static Map<String, dynamic> toJson(Segment segment) {
    return {
      'name': segment.name,
      'order': segment.order,
      'distance': segment.distance,
      // 'unit'        : segment.unit,
      'activityType': segment.activityType.name,
    };
  }
}
