import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:race_tracking_app/data/dto/race_dto.dart';
import 'package:race_tracking_app/data/dto/race_result_dto.dart';
import 'package:race_tracking_app/data/repository/race_repository.dart';
import 'package:race_tracking_app/models/participant/participant.dart';
import 'package:race_tracking_app/models/race/race.dart';
import 'package:race_tracking_app/models/segment/segment.dart';
import '../../dto/segment_dto.dart';

class FirebaseRaceRepository extends RaceRepository {
  static const String _baseUrl =
      'https://flutter2-race-tracking-app-default-rtdb.asia-southeast1.firebasedatabase.app/';
  static const String _raceCollection = "Race";
  static const String _raceResultsCollection = "RaceResults";

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
      'completed': false,
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

    // Also delete race results
    await _deleteRaceResults(id);

    return await getRace();
  }
  
  // Save race results to Firebase
  Future<void> saveRaceResults(String raceId, List<Participant> participants, Map<int, Duration> totalTimes) async {
    final Uri url = Uri.parse('$_baseUrl/$_raceResultsCollection/$raceId.json');
    
    // Sort participants by total time
    final sortedParticipants = List<Participant>.from(participants);
    sortedParticipants.sort((a, b) {
      final timeA = totalTimes[a.bibNumber] ?? Duration.zero;
      final timeB = totalTimes[b.bibNumber] ?? Duration.zero;
      return timeA.compareTo(timeB);
    });
    
    // Create result DTOs
    final resultDtos = <Map<String, dynamic>>[];
    for (int i = 0; i < sortedParticipants.length; i++) {
      final participant = sortedParticipants[i];
      final totalTime = totalTimes[participant.bibNumber] ?? Duration.zero;
      
      // Skip participants with zero time
      if (totalTime.inMilliseconds == 0) continue;
      
      try {
        final dto = RaceResultDto.fromParticipant(
          participant: participant,
          rank: i + 1,
          totalTime: totalTime,
        );
        
        resultDtos.add(dto.toJson());
      } catch (e) {
        // Skip this participant if there's an error
      }
    }
    
    if (resultDtos.isEmpty) return;
    
    try {
      // Save as an object with numeric keys
      final resultObject = <String, dynamic>{};
      for (int i = 0; i < resultDtos.length; i++) {
        resultObject[i.toString()] = resultDtos[i];
      }
      
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(resultObject),
      );
      
      if (response.statusCode != HttpStatus.ok) {
        throw Exception('Failed to save race results');
      }
    } catch (e) {
      // Try saving each result individually as a fallback
      for (int i = 0; i < resultDtos.length; i++) {
        try {
          final individualUrl = Uri.parse('$_baseUrl/$_raceResultsCollection/$raceId/$i.json');
          await http.put(
            individualUrl,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(resultDtos[i]),
          );
        } catch (_) {
          // Ignore individual failures
        }
      }
    }
  }
  
  // Check if race results exist
  Future<bool> raceResultsExist(String raceId) async {
    final Uri url = Uri.parse('$_baseUrl/$_raceResultsCollection/$raceId.json');
    final response = await http.get(url);
    
    if (response.statusCode != HttpStatus.ok) {
      return false;
    }
    
    return response.body != 'null' && response.body.isNotEmpty && response.body != '[]';
  }
  
  // Get race results from Firebase
  Future<List<Map<String, dynamic>>> getRaceResults(String raceId) async {
    final Uri url = Uri.parse('$_baseUrl/$_raceResultsCollection/$raceId.json');
    final response = await http.get(url);
    
    if (response.statusCode != HttpStatus.ok) {
      throw Exception('Failed to get race results');
    }
    
    try {
      final data = json.decode(response.body);
      
      if (data == null) {
        return [];
      }
      
      if (data is List) {
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else if (data is Map) {
        // If it's a map with numeric keys, convert to list
        final resultsList = <Map<String, dynamic>>[];
        data.forEach((key, value) {
          if (value is Map<String, dynamic>) {
            resultsList.add(value);
          }
        });
        return resultsList;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
  
  // Mark a race as completed
  Future<void> markRaceAsCompleted(String raceId) async {
    final Uri url = Uri.parse('$_baseUrl/$_raceCollection/$raceId.json');
    
    try {
      // Check if the race exists at this URL
      final checkResponse = await http.get(url);
      
      if (checkResponse.body == 'null' || checkResponse.body.isEmpty) {
        // Try to find the race in all races
        final allRacesUrl = Uri.parse('$_baseUrl/$_raceCollection.json');
        final allRacesResponse = await http.get(allRacesUrl);
        
        if (allRacesResponse.statusCode == HttpStatus.ok) {
          final data = json.decode(allRacesResponse.body) as Map<String, dynamic>?;
          
          if (data != null) {
            // Find the race with the matching ID
            for (var entry in data.entries) {
              if (entry.value is Map<String, dynamic> && entry.value['id'] == raceId) {
                // Update the race with the actual key
                final updateUrl = Uri.parse('$_baseUrl/$_raceCollection/${entry.key}.json');
                final updateData = {'completed': true};
                final updateResponse = await http.patch(
                  updateUrl,
                  headers: {'Content-Type': 'application/json'},
                  body: json.encode(updateData),
                );
                
                if (updateResponse.statusCode == HttpStatus.ok) {
                  return;
                }
              }
            }
          }
        }
      }
      
      // If we couldn't find the race by ID, try the original approach
      final updateData = {'completed': true};
      await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updateData),
      );
    } catch (e) {
      // If all else fails, try to update the entire race object
      try {
        final getRaceUrl = Uri.parse('$_baseUrl/$_raceCollection.json');
        final getRaceResponse = await http.get(getRaceUrl);
        
        if (getRaceResponse.statusCode == HttpStatus.ok) {
          final data = json.decode(getRaceResponse.body) as Map<String, dynamic>?;
          
          if (data != null) {
            // Find the race with the matching ID
            data.forEach((key, value) {
              if (value is Map<String, dynamic> && value['id'] == raceId) {
                // Update the race with completed=true
                final raceData = Map<String, dynamic>.from(value);
                raceData['completed'] = true;
                
                final updateUrl = Uri.parse('$_baseUrl/$_raceCollection/$key.json');
                http.put(
                  updateUrl,
                  headers: {'Content-Type': 'application/json'},
                  body: json.encode(raceData),
                );
              }
            });
          }
        }
      } catch (_) {
        // Ignore errors in the fallback approach
      }
    }
  }
  
  // Check if a race is completed
  Future<bool> isRaceCompleted(String raceId) async {
    final Uri url = Uri.parse('$_baseUrl/$_raceCollection/$raceId.json');
    final response = await http.get(url);
    
    if (response.statusCode != HttpStatus.ok) {
      return false;
    }
    
    final data = json.decode(response.body) as Map<String, dynamic>?;
    if (data == null) {
      // Try to find the race in all races
      try {
        final allRacesUrl = Uri.parse('$_baseUrl/$_raceCollection.json');
        final allRacesResponse = await http.get(allRacesUrl);
        
        if (allRacesResponse.statusCode == HttpStatus.ok) {
          final allData = json.decode(allRacesResponse.body) as Map<String, dynamic>?;
          
          if (allData != null) {
            // Find the race with the matching ID
            for (var entry in allData.entries) {
              if (entry.value is Map<String, dynamic> && 
                  (entry.value['id'] == raceId || entry.key == raceId)) {
                return entry.value['completed'] == true;
              }
            }
          }
        }
      } catch (_) {
        // Ignore errors in the fallback approach
      }
      
      return false;
    }
    
    return data['completed'] == true;
  }
  
  // Private helper method to delete race results
  Future<void> _deleteRaceResults(String raceId) async {
    final Uri url = Uri.parse('$_baseUrl/$_raceResultsCollection/$raceId.json');
    await http.delete(url);
  }
}
