import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:race_tracking_app/data/dto/race_dto.dart';
import 'package:race_tracking_app/data/repository/race_repository.dart';
import 'package:race_tracking_app/models/race/race.dart';
import 'package:race_tracking_app/models/segment/segment.dart';
import '../../dto/segment_dto.dart';

class FirebaseRaceRepository extends RaceRepository {
  static const String _baseUrl =
      'https://flutter2-race-tracking-app-default-rtdb.asia-southeast1.firebasedatabase.app/';
  static const String _raceCollection = "Race";

  @override
  Future<Race> addRace({
    required String id,
    required String name,
    required DateTime startTime,
    required List<Segment> segments,
  }) async {
    final Uri url = Uri.parse('$_baseUrl/$_raceCollection.json');
    
    final raceData = {
      'name': name,
      'startTime': startTime.toIso8601String(),
      'segments': segments.map((s) {
        final json = SegmentDto.toJson(s);
        json['id'] = s.id;
        return json;
      }).toList(),
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(raceData),
    );
    
    if (response.statusCode != HttpStatus.ok) {
      throw Exception('Failed to add race');
    }
    
    final newRaceId = json.decode(response.body)['name'];
    
    return Race(
      id: newRaceId,
      name: name,
      startTime: startTime,
      segments: segments,
    );
  }

  @override
  Future<List<Race>> getRace() async {
    final Uri url = Uri.parse('$_baseUrl/$_raceCollection.json');
    final response = await http.get(url);

    if (response.statusCode != HttpStatus.ok) {
      throw Exception('Failed to load races');
    }

    final data = json.decode(response.body) as Map<String, dynamic>?;
    if (data == null) return [];

    return data.entries
        .map((entry) => RaceDto.fromJson(entry.key, entry.value))
        .toList();
  }

  @override
  Future<List<Race>> removeRace({required String id}) async {
    final Uri url = Uri.parse('$_baseUrl/$_raceCollection/$id.json');
    final response = await http.delete(url);

    if (response.statusCode != HttpStatus.ok && 
        response.statusCode != HttpStatus.noContent) {
      throw Exception('Failed to delete race');
    }

    return await getRace();
  }
  
  Future<void> addParticipantToRace(String raceId, String participantId) async {
    final Uri url = Uri.parse('$_baseUrl/Participant/$participantId.json');
    
    // Update the participant with the race ID
    final updateData = {'raceId': raceId};
    final response = await http.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updateData),
    );
    
    if (response.statusCode != HttpStatus.ok) {
      throw Exception('Failed to associate participant with race');
    }
  }
  
  Future<List<String>> getParticipantsByRace(String raceId) async {
    final Uri url = Uri.parse('$_baseUrl/Participant.json?orderBy="raceId"&equalTo="$raceId"');
    
    final response = await http.get(url);
    if (response.statusCode != HttpStatus.ok) {
      throw Exception('Failed to get race participants');
    }
    
    final data = json.decode(response.body) as Map<String, dynamic>?;
    if (data == null) return [];
    
    return data.keys.toList();
  }
}