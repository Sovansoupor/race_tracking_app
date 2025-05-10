import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:race_tracking_app/data/dto/race_dto.dart';
import 'package:race_tracking_app/data/repository/race_repository.dart';
import 'package:race_tracking_app/models/race/race.dart';

class FirebaseRaceRepository extends RaceRepository {
  static const String baseUrl =
      'https://flutter2-race-tracking-app-default-rtdb.asia-southeast1.firebasedatabase.app/';
  static const String raceCollection = "Race";
  static const String allRaceUrl = '$baseUrl/$raceCollection.json';

  @override
  Future<Race> addRace({
    required String id,
    required String name,
    required DateTime startTime,
    required List<String> participantIds,
    required List<String> segments,
  }) async {
    Uri uri = Uri.parse(allRaceUrl);

    //Create a new data
    final newRaceData = {
      'name': name,
      'startTime': startTime.toIso8601String(),
      'participant': participantIds,
      'segments': segments,
    };

    final http.Response response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(newRaceData),
    );
    if (response.statusCode != HttpStatus.ok) {
      throw Exception('Failed to add race');
    }
    final newRaceId = json.decode(response.body)['name'];
    return Race(
      id: newRaceId,
      name: name,
      participantIds: participantIds,
      startTime: startTime,
      segments: segments,
    );
  }

  @override
  Future<List<Race>> getRace() async {
    Uri uri = Uri.parse(allRaceUrl);
    final http.Response response = await http.get(uri);

    // Handle errors
    if (response.statusCode != HttpStatus.ok &&
        response.statusCode != HttpStatus.created) {
      throw Exception('Failed to load races');
    }

    // Return all races
    final data = json.decode(response.body) as Map<String, dynamic>?;
    if (data == null) return [];

    return data.entries
        .map((entry) => RaceDto.fromJson(entry.key, entry.value))
        .toList();
  }

  @override
  Future<List<Race>> removeRace({required String id}) async {
    Uri uri = Uri.parse('$baseUrl/$raceCollection/$id.json');
    final http.Response response = await http.delete(uri);

    if (response.statusCode != HttpStatus.ok &&
        response.statusCode != HttpStatus.noContent) {
      throw Exception('Failed to delete race');
    }

    // After deletion, return the updated race list
    return await getRace();
  }

  Future<void> updateRaceSegmentDetail({
    required String raceId,
    required String segmentId,
    required int distance,
    required String unit,
  }) async {
    final Uri uri = Uri.parse(
      '$baseUrl/$raceCollection/$raceId/segmentDetails/$segmentId.json',
    );
    final body = {
      'distance': distance,
      'unit': unit,
    };
    final response = await http.patch(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    if (response.statusCode != HttpStatus.ok) {
      throw Exception('Failed to update per‑race segment detail');
    }
  }
}
