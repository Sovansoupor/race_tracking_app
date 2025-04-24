import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:race_tracking_app/data/dto/participant_dto.dart';
import 'package:race_tracking_app/data/repository/participant_repository.dart';
import 'package:race_tracking_app/models/participant/participant.dart';

class FirebaseParticipantRepository extends ParticipantRepository{
  static const String baseUrl = 'https://flutter2-race-tracking-app-default-rtdb.asia-southeast1.firebasedatabase.app/';
  static const String participantCollection = "Participant";
  static const String allParticipantUrl = '$baseUrl/$participantCollection.json';
  static const String bibCounterUrl = '$baseUrl/bibCounter.json';

  /// 1) HEAD → GET-current → PUT-increment with If-Match
  Future<int> _getNextBibWithETag() async {
    final uri = Uri.parse(bibCounterUrl);

    // a) HEAD to fetch the current ETag
    final headResp = await http.head(uri);
    if (headResp.statusCode != HttpStatus.ok) {
      throw Exception('Could not fetch ETag for bibCounter');
    }
    final etag = headResp.headers['etag'];
    if (etag == null) {
      throw Exception('No ETag header returned for bibCounter');
    }

    // b) GET current value
    final getResp = await http.get(uri);
    if (getResp.statusCode != HttpStatus.ok) {
      throw Exception('Could not read bibCounter');
    }
    final current = (json.decode(getResp.body) as int?) ?? 0;
    final next    = current + 1;

    // c) PUT back incremented value, guarded by ETag
    final putResp = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'If-Match':     etag,
      },
      body: json.encode(next),
    );

    if (putResp.statusCode == HttpStatus.preconditionFailed) {
      throw Exception('bibCounter was modified by another client; retry');
    }
    if (putResp.statusCode != HttpStatus.ok) {
      throw Exception('Failed to update bibCounter');
    }

    return next;
  }

  @override
  Future<Participant> addParticipant({required String id, required String firstName, required String lastName, required int age, required int bibNumber, required String gender, required Map<String, Duration> segmentTimes}) async {
    Uri uri = Uri.parse(allParticipantUrl);

    final bibNumber = await _getNextBibWithETag();

    // Create a new data
    final newParticipantData = {
      'firstName': firstName,
      'lastName': lastName,
      'age': age,
      'gender': gender,
      'bibNumber': bibNumber,
      'segmentTimes':segmentTimes.map((key, value) => MapEntry(key, value.inMilliseconds)),
    };
    final http.Response response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(newParticipantData),
    );

    // Handle errors
    if (response.statusCode != HttpStatus.ok) {
      throw Exception('Failed to add participant');
    }
    // Firebase returns the new ID in 'name'
    final newId = json.decode(response.body)['name'];

    // Return created participant
    return Participant(segmentTimes, firstName: firstName, lastName: lastName, gender: gender, id: newId, age: age, bibNumber: bibNumber);
  }

  @override
  Future<List<Participant>> getParticipant() async {
    Uri uri = Uri.parse(allParticipantUrl);
    final http.Response response = await http.get(uri);

    // Handle errors
    if (response.statusCode != HttpStatus.ok && response.statusCode != HttpStatus.created) {
      throw Exception('Failed to load');
    }

    // Return all participants
    final data = json.decode(response.body) as Map<String, dynamic>?;

    if (data == null) return [];
    return data.entries.map((entry) => ParticipantDto.fromJson(entry.key, entry.value)).toList();
  }

  @override
  Future<List<Participant>> removeParticipant({required String id}) async {
    Uri uri = Uri.parse('$baseUrl/$participantCollection/$id.json');
    final http.Response response = await http.delete(uri);

    // Handle errors
    if (response.statusCode != HttpStatus.ok) {
      throw Exception('Failed to delete course');
    }

    // Fetch the updated list of participants after deletion
    return await getParticipant();

  }
}