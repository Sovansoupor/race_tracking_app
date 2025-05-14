import 'dart:convert';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart' hide Transaction;
import 'package:http/http.dart' as http;
import 'package:race_tracking_app/data/dto/participant_dto.dart';
import 'package:race_tracking_app/data/repository/participant_repository.dart';
import 'package:race_tracking_app/models/participant/participant.dart';

class FirebaseParticipantRepository extends ParticipantRepository {
  static const String baseUrl =
      'https://flutter2-race-tracking-app-default-rtdb.asia-southeast1.firebasedatabase.app/';
  static const String participantCollection = "Participant";
  static const String allParticipantUrl =
      '$baseUrl/$participantCollection.json';

  Future<int> _getNextBib() async {
    final bibCounterRef = FirebaseDatabase.instance.ref('bibCounter');

    // Fetch the current bibCounter
    final bibCounterSnapshot = await bibCounterRef.get();
    int currentVal = (bibCounterSnapshot.value as int?) ?? 0;

    // Increment the bibCounter
    final nextBib = currentVal + 1;
    await bibCounterRef.set(nextBib);

    return nextBib;
  }

  @override
  Future<Participant> addParticipant({
    required String id,
    required String firstName,
    required String lastName,
    required int age,
    required int bibNumber,
    required String gender,
    required Map<String, Duration> segmentTimes,
  }) async {
    Uri uri = Uri.parse(allParticipantUrl);

    // Assign a new BIB number
    final assignedBib = await _getNextBib();

    // Create a new participant
    final newParticipantData = {
      'firstName': firstName,
      'lastName': lastName,
      'age': age,
      'gender': gender,
      'bibNumber': assignedBib,
      'segmentTimes': segmentTimes.map(
        (key, value) => MapEntry(key, value.inMilliseconds),
      ),
    };
    final http.Response response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(newParticipantData),
    );

    // Handle errors
    if (response.statusCode != HttpStatus.ok) {
      print("HTTP POST failed: ${response.statusCode}, ${response.body}");
      throw Exception('Failed to add participant');
    }
    // Firebase returns the new ID in 'name'
    final newId = json.decode(response.body)['name'];

    // Return created participant
    return Participant(
      segmentTimes,
      firstName: firstName,
      lastName: lastName,
      gender: gender,
      id: newId,
      age: age,
      bibNumber: bibNumber,
    );
  }

  @override
  Future<List<Participant>> getParticipant() async {
    Uri uri = Uri.parse(allParticipantUrl);
    final http.Response response = await http.get(uri);

    // Handle errors
    if (response.statusCode != HttpStatus.ok &&
        response.statusCode != HttpStatus.created) {
      throw Exception('Failed to load');
    }

    // Return all participants
    final data = json.decode(response.body) as Map<String, dynamic>?;

    if (data == null) return [];
    return data.entries
        .map((entry) => ParticipantDto.fromJson(entry.key, entry.value))
        .toList();
  }

  @override
  Future<List<Participant>> removeParticipant({required String id}) async {
    Uri uri = Uri.parse('$baseUrl/$participantCollection/$id.json');

    // Delete the participant
    final http.Response deleteResponse = await http.delete(uri);
    if (deleteResponse.statusCode != HttpStatus.ok) {
      throw Exception('Failed to delete participant');
    }

    // Fetch all remaining participants
    final participantsUri = Uri.parse(allParticipantUrl);
    final http.Response getResponse = await http.get(participantsUri);

    if (getResponse.statusCode != HttpStatus.ok) {
      throw Exception('Failed to fetch participants after deletion');
    }

    final data = json.decode(getResponse.body) as Map<String, dynamic>?;

    /// If the list is empty, reset the bibCounter
    final bibCounterRef = FirebaseDatabase.instance.ref('bibCounter');
    if (data == null || data.isEmpty) {
      await bibCounterRef.set(0); // Reset the bibCounter to 0
      return [];
    }

    // Convert to a list of participants
    final participants =
        data.entries
            .map((entry) => ParticipantDto.fromJson(entry.key, entry.value))
            .toList();

    // Sort participants by their current BIB number (or any other criteria)
    participants.sort((a, b) => a.bibNumber.compareTo(b.bibNumber));

    // Reassign BIB numbers sequentially starting from 1
    for (int i = 0; i < participants.length; i++) {
      final participant = participants[i];
      final updatedBibNumber = i + 1;

      // Update the participant's BIB number in Firebase
      final participantUri = Uri.parse(
        '$baseUrl/$participantCollection/${participant.id}.json',
      );
      final updatedData = {
        'firstName': participant.firstName,
        'lastName': participant.lastName,
        'age': participant.age,
        'gender': participant.gender,
        'bibNumber': updatedBibNumber,
        'segmentTimes': participant.segmentTimes.map(
          (key, value) => MapEntry(key, value.inMilliseconds),
        ),
      };

      final http.Response updateResponse = await http.put(
        participantUri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedData),
      );

      if (updateResponse.statusCode != HttpStatus.ok) {
        throw Exception('Failed to update participant BIB number');
      }
    }

    // Update the bibCounter to match the number of remaining participants
    await bibCounterRef.set(participants.length);

    // Fetch the updated list of participants
    return participants;
  }

  @override
  Future<Participant> editParticipant({
    required String id,
    required String firstName,
    required String lastName,
    required int age,
    required String gender,
    Map<String, Duration>? segmentTimes,
  }) async {
    Uri uri = Uri.parse('$baseUrl/$participantCollection/$id.json');

    // Fetch existing data
    final http.Response getResponse = await http.get(uri);
    if (getResponse.statusCode != HttpStatus.ok) {
      throw Exception('Failed to load participant');
    }

    final existingData = json.decode(getResponse.body) as Map<String, dynamic>?;
    if (existingData == null) {
      throw Exception('Participant not found');
    }

    // Extract segmentTimes and bibNumber from existing data
    final segmentTimes =
        (existingData['segmentTimes'] as Map<String, dynamic>? ?? {}).map(
          (key, value) => MapEntry(key, Duration(milliseconds: value)),
        );
    final bibNumber = existingData['bibNumber'];

    // Merge the updates with existing data
    final updatedParticipantData = {
      ...existingData,
      'firstName': firstName,
      'lastName': lastName,
      'age': age,
      'gender': gender,
    };

    // Send the updated data back to Firebase
    final http.Response putResponse = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updatedParticipantData),
    );

    // Handle errors
    if (putResponse.statusCode != HttpStatus.ok) {
      throw Exception('Failed to edit participant');
    }

    // return await getParticipant();
    return Participant(
      segmentTimes,
      firstName: firstName,
      lastName: lastName,
      id: id,
      gender: gender,
      age: age,
      bibNumber: bibNumber,
    );
  }
}
