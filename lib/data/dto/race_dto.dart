// lib/data/dto/race_dto.dart

import 'package:race_tracking_app/models/race/race.dart';
import 'package:race_tracking_app/models/segment/segment.dart';
import 'package:race_tracking_app/data/dto/segment_dto.dart';

class RaceDto {
  /// Firestore/RTDB JSON → Race
  static Race fromJson(String id, Map<String, dynamic> json) {
    // 1) Parse startTime safely
    final startTimeStr = json['startTime'] as String?;
    final startTime =
        startTimeStr != null
            ? (DateTime.tryParse(startTimeStr) ?? DateTime.now())
            : DateTime.now();

    // 2) Parse participant IDs
    final participantIds =
        (json['participantIds'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [];

    // 3) Parse segments (either Map or String)
    final rawSegments = (json['segments'] as List<dynamic>?) ?? [];
    final segments =
        rawSegments.map<Segment>((entry) {
          if (entry is Map<String, dynamic>) {
            // Fully-fledged object
            final segId = entry['id'] as String? ?? '';
            return SegmentDto.fromJson(segId, entry);
          } else {
            // Fallback: it was just a String name
            final segName = entry.toString();
            final type = ActivityType.values.firstWhere(
              (t) => t.name == segName,
              orElse: () => ActivityType.swimming,
            );
            return Segment(
              id: segName,
              name: type.label,
              order: 0,
              distance: null,
              unit: null,
              activityType: type,
            );
          }
        }).toList();

    return Race(
      id: id,
      name: json['name'] as String? ?? 'Unknown',
      startTime: startTime,
      participantIds: participantIds,
      segments: segments,
    );
  }

  /// Race → Firestore/RTDB JSON
  static Map<String, dynamic> toJson(Race race) {
    return {
      'name': race.name,
      'startTime': race.startTime.toIso8601String(),
      'participantIds': race.participantIds,
      'segments':
          race.segments.map((seg) {
            final m = SegmentDto.toJson(seg);
            m['id'] = seg.id;
            return m;
          }).toList(),
    };
  }
}
