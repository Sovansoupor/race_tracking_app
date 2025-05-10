import 'package:race_tracking_app/models/race/race.dart';
import 'package:race_tracking_app/models/segment/segment.dart';

class RaceDto {
  static Race fromJson(String id, Map<String, dynamic> json) {
    return Race(
      id: id,
      name: json['name'] ?? 'Unknown',
      startTime: DateTime.parse(json['startTime'] ?? DateTime.now().toIso8601String()),
      participantIds: List<String>.from(json['participantIds'] ?? []),
      segments: List<String>.from(json['segments'] ?? []),
    );
  }

  static Map<String, dynamic> toJson(Race race) {
    return {
      'name': race.name,
      'startTime': race.startTime.toIso8601String(),
      'participant': race.participantIds,
      'segments': race.segments,
    };
  }
}
