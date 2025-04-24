import 'package:race_tracking_app/models/race/race.dart';

abstract class RaceRepository {
  Future<Race> addRace({
    required String id,
    required String name,
    required DateTime startTime,
    required List<String> participantIds,
    required List<String> segments,
  });
  Future<List<Race>> removeRace({required String id});
  Future<List<Race>> getRace();
}
