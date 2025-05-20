import 'package:race_tracking_app/models/participant/participant.dart';

class RaceResultDto {
  final String participantId;
  final String firstName;
  final String lastName;
  final String gender;
  final int age;
  final int bibNumber;
  final Map<String, int> segmentTimes; // Store milliseconds for each segment
  final int totalTimeMs; // Total time in milliseconds
  final int rank;
  final String raceId;

  RaceResultDto({
    required this.participantId,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.age,
    required this.bibNumber,
    required this.segmentTimes,
    required this.totalTimeMs,
    required this.rank,
    required this.raceId,
  });

  // Convert to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'participantId': participantId,
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'age': age,
      'bibNumber': bibNumber,
      'segmentTimes': segmentTimes,
      'totalTimeMs': totalTimeMs,
      'rank': rank,
      'raceId': raceId,
    };
  }

  // Create from JSON from Firebase
  factory RaceResultDto.fromJson(Map<String, dynamic> json) {
    // Parse segment times
    Map<String, int> segmentTimes = {};
    
    // Handle different possible formats of segmentTimes in the JSON
    if (json['segmentTimes'] is Map) {
      final rawSegmentTimes = json['segmentTimes'] as Map<String, dynamic>? ?? {};
      segmentTimes = rawSegmentTimes.map(
        (key, value) => MapEntry(key, value is int ? value : 0),
      );
    }

    return RaceResultDto(
      participantId: json['participantId'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      gender: json['gender'] ?? '',
      age: json['age'] ?? 0,
      bibNumber: json['bibNumber'] ?? 0,
      segmentTimes: segmentTimes,
      totalTimeMs: json['totalTimeMs'] ?? 0,
      rank: json['rank'] ?? 0,
      raceId: json['raceId'] ?? '',
    );
  }

  // Create from Participant model and additional data
  factory RaceResultDto.fromParticipant({
    required Participant participant,
    required int rank,
    required Duration totalTime,
  }) {
    // Convert segment times from Duration to milliseconds
    final Map<String, int> segmentTimesMs = {};
    
    // Only convert if segmentTimes is not null
    if (participant.segmentTimes != null) {
      participant.segmentTimes.forEach((key, value) {
        segmentTimesMs[key] = value.inMilliseconds;
      });
    }

    return RaceResultDto(
      participantId: participant.id,
      firstName: participant.firstName,
      lastName: participant.lastName,
      gender: participant.gender,
      age: participant.age,
      bibNumber: participant.bibNumber,
      segmentTimes: segmentTimesMs,
      totalTimeMs: totalTime.inMilliseconds,
      rank: rank,
      raceId: participant.raceId,
    );
  }

  // Convert to Participant model
  Participant toParticipant() {
    // Convert segment times from milliseconds to Duration
    final Map<String, Duration> segmentTimesDuration = {};
    
    // Only convert if segmentTimes is not null
    segmentTimes.forEach((key, value) {
      segmentTimesDuration[key] = Duration(milliseconds: value);
    });

    return Participant(
      segmentTimesDuration,
      firstName: firstName,
      lastName: lastName,
      gender: gender,
      id: participantId,
      age: age,
      bibNumber: bibNumber,
      raceId: raceId,
    );
  }
}
