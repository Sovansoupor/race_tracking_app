import 'package:race_tracking_app/models/race/race.dart';
import 'package:race_tracking_app/models/segment/segment.dart';

abstract class RaceRepository {
  Future<Race> addRace({
    required String id,
    required String name,
    required DateTime startTime,
    required List<String> participantIds,
    required List<Segment> segments,
  });
  Future<List<Race>> removeRace({required String id});
  Future<List<Race>> getRace();
}
