import 'package:race_tracking_app/models/participant/participant.dart';

class ParticipantDto {
  static Participant fromJson(String id, Map<String, dynamic> json) {
    return Participant(
      json['segmentTimes'] != null
          ? Map<String, Duration>.from(json['segmentTimes'])
          : {},
      firstName: json['firstName'] ?? 'Unknown',
      lastName: json['lastName'] ?? 'Unknown', gender: 'Unknown',
      id: id,
      age: json['age'] ?? 0,
      bibNumber: json['bibNumber'] ?? 0,
    );
  }
  static Map<String, dynamic> toJson(Participant participant) {
    return {
      'firstName': participant.firstName,
      'lastName': participant.lastName,
      'age': participant.age,
      'bibNumber': participant.bibNumber,
    };
  }
}