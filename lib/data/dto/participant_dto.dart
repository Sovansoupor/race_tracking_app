import 'package:race_tracking_app/models/participant/participant.dart';

class ParticipantDto {
  static Participant fromJson(String id, Map<String, dynamic> json) {
    return Participant(
      (json['segmentTimes'] as Map<String, dynamic>? ?? {}).map(
        (key, value) => MapEntry(
          key,
          Duration(milliseconds: value is int ? value : 0),
        ),
      ),
      firstName: json['firstName'] as String? ?? 'Unknown',
      lastName: json['lastName'] as String? ?? 'Unknown',
      gender: json['gender'] as String? ?? 'Unknown',
      id: id,
      age: json['age'] as int? ?? 0,
      bibNumber: json['bibNumber'] as int? ?? 0,
    );
  }

  static Map<String, dynamic> toJson(Participant participant) {
    return {
      'firstName': participant.firstName,
      'lastName': participant.lastName,
      'age': participant.age,
      'bibNumber': participant.bibNumber,
      'segmentTimes': participant.segmentTimes.map(
        (key, value) => MapEntry(key, value.inMilliseconds),
      ),
    };
  }
}