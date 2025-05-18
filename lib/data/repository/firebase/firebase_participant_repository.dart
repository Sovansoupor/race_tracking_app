import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:race_tracking_app/data/repository/participant_repository.dart';
import 'package:race_tracking_app/models/participant/participant.dart';
import 'package:race_tracking_app/data/dto/participant_dto.dart';

class FirebaseParticipantRepository implements ParticipantRepository {
  static const _baseUrl = 'https://flutter2-race-tracking-app-default-rtdb.asia-southeast1.firebasedatabase.app/';
  static const _bibCounterUrl = 'https://flutter2-race-tracking-app-default-rtdb.asia-southeast1.firebasedatabase.app/bibCounter.json';

  // BIB number management methods
  Future<int> _getNextBib() async {
    // Get current value
    final resp = await http.get(Uri.parse(_bibCounterUrl));
    if (resp.statusCode != 200) {
      throw Exception('Failed to get BIB counter');
    }
    
    int currentVal = int.tryParse(resp.body) ?? 0;
    int nextBib = currentVal + 1;
    // Set new value
    final updateResp = await http.put(
      Uri.parse(_bibCounterUrl),
      headers: {'Content-Type': 'application/json'},
      body: nextBib.toString(),
    );
    
    if (updateResp.statusCode != 200) {
      throw Exception('Failed to update BIB counter');
    }
    
    return nextBib;
  }
  
  Future<void> _resetBibCounter(int value) async {
    await http.put(
      Uri.parse(_bibCounterUrl),
      body: value.toString(),
    );
  }

  // Core CRUD operations
  @override
  Future<Participant> addParticipant({
    required String id,
    required String firstName,
    required String lastName, 
    required int age,
    required int bibNumber,
    required String gender,
    required Map<String, Duration> segmentTimes,
    String raceId = '',
  }) async {
    final url = Uri.parse('$_baseUrl/Participant.json');
    
    // Auto-assign BIB number
    final assignedBib = await _getNextBib();
    
    // Debug
    print("Creating participant with raceId: '$raceId'");
    
    final participantData = {
      'firstName': firstName,
      'lastName': lastName,
      'age': age,
      'gender': gender,
      'bibNumber': assignedBib,
      'raceId': raceId,
      'segmentTimes': segmentTimes.map(
        (key, value) => MapEntry(key, value.inMilliseconds),
      ),
    };
    
    // Debug
    print("Participant data: $participantData");
    
    final resp = await http.post(
      url, 
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(participantData)
    );
    
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final newId = (jsonDecode(resp.body) as Map<String, dynamic>)['name'];
      
      return Participant(
        segmentTimes,
        firstName: firstName,
        lastName: lastName,
        gender: gender,
        id: newId,
        age: age,
        bibNumber: bibNumber,
        raceId: raceId,
      );
    }
    
    throw Exception('Failed to create participant');
  }

  @override
  Future<List<Participant>> getParticipant() async {
    final url = Uri.parse('$_baseUrl/Participant.json');
    final resp = await http.get(url);
    
    if (resp.statusCode == 200 && resp.body != 'null') {
      final data = jsonDecode(resp.body) as Map<String, dynamic>?;
      
      if (data == null) return [];
      
      final participants = data.entries
          .map((e) => ParticipantDto.fromJson(e.key, e.value))
          .toList();
          
      return participants;
    }
    
    return [];
  }

  @override
  Future<List<Participant>> removeParticipant({required String id}) async {
    final url = Uri.parse('$_baseUrl/Participant/$id.json');
    final resp = await http.delete(url);
    
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Failed to delete participant');
    }
    
    // Get all remaining participants
    final participants = await getParticipant();
    
    // If list is empty, reset BIB counter
    if (participants.isEmpty) {
      await _resetBibCounter(0);
      return [];
    }
    
    // Sort and reassign BIB numbers sequentially
    participants.sort((a, b) => a.bibNumber.compareTo(b.bibNumber));
    
    for (int i = 0; i < participants.length; i++) {
      final participant = participants[i];
      final newBibNumber = i + 1;
      
      // Only update if BIB changed
      if (participant.bibNumber != newBibNumber) {
        final updateUrl = Uri.parse('$_baseUrl/Participant/${participant.id}.json');
        final updateData = {'bibNumber': newBibNumber};
        
        await http.patch(
          updateUrl,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(updateData),
        );
      }
    }
    
    // Update BIB counter
    await _resetBibCounter(participants.length);
    
    return participants;
  }

  @override
  Future<Participant> editParticipant({
    required String id,
    required String firstName,
    required String lastName,
    required int age,
    required String gender,
  }) async {
    if (id.isEmpty) throw ArgumentError('Participant ID required');
    
    final url = Uri.parse('$_baseUrl/Participant/$id.json');
    
    // Get current participant for unchanged fields
    final getResp = await http.get(url);
    if (getResp.statusCode != 200 || getResp.body == 'null') {
      throw Exception('Participant not found');
    }
    
    final existingData = jsonDecode(getResp.body) as Map<String, dynamic>;
    
    // Update only changed fields
    final updateData = {
      'firstName': firstName,
      'lastName': lastName,
      'age': age,
      'gender': gender,
    };
    
    final resp = await http.patch(
      url, 
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updateData)
    );
    
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      // Extract unchanged fields
      final bibNumber = existingData['bibNumber'] as int? ?? 0;
      final segmentTimes = 
          (existingData['segmentTimes'] as Map<String, dynamic>? ?? {}).map(
            (key, value) => MapEntry(key, Duration(milliseconds: value is int ? value : 0)),
          );
      final raceId = existingData['raceId'] as String? ?? '';
      
      return Participant(
        segmentTimes,
        firstName: firstName,
        lastName: lastName,
        gender: gender,
        id: id,
        age: age,
        bibNumber: bibNumber,
        raceId: raceId,
      );
    }
    
    throw Exception('Failed to update participant');
  }
  
  // New method to assign a participant to a race
  Future<void> assignParticipantToRace(String participantId, String raceId) async {
    final url = Uri.parse('$_baseUrl/Participant/$participantId.json');
    
    print("Assigning participant $participantId to race $raceId");
    
    final updateData = {'raceId': raceId};
    final resp = await http.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updateData),
    );
    
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Failed to assign participant to race');
    }
    
    print("Successfully assigned participant to race");
  }
  
  // New method to get participants for a specific race
  Future<List<Participant>> getParticipantsByRace(String raceId) async {
    if (raceId.isEmpty) return [];
    
    final allParticipants = await getParticipant();
    return allParticipants.where((p) => p.raceId == raceId).toList();
  }
}
