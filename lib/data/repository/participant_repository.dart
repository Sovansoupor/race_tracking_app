import 'package:race_tracking_app/models/participant/participant.dart';

abstract class ParticipantRepository {
  Future<Participant> addParticipant({
    required String id,
    required String firstName,
    required String lastName,
    required int age,
    required String gender,
    required Map<String, Duration> segmentTimes,
    required int bibNumber,
  });
  Future<List<Participant>> removeParticipant({required String id});
  Future<Participant> editParticipant({
    required String id,
    required String firstName,
    required String lastName,
    required int age,
    required String gender,
  });
  Future<List<Participant>> getParticipant();
}