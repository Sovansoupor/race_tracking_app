import 'package:flutter/material.dart';
import 'package:race_tracking_app/models/participant/participant.dart';
import 'package:race_tracking_app/provider/async_value.dart';

import '../../data/repository/firebase/firebase_participant_repository.dart';

class ParticipantProvider extends ChangeNotifier {
  final FirebaseParticipantRepository _repository =
      FirebaseParticipantRepository();
  AsyncValue<List<Participant>>? participantState;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController genderController = TextEditingController();

  ParticipantProvider() {
    fetchParticipants();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    ageController.dispose();
    genderController.dispose();
    super.dispose();
  }

  bool get isLoading =>
      participantState != null &&
      participantState!.state == AsyncValueState.loading;
  bool get hasData =>
      participantState != null &&
      participantState!.state == AsyncValueState.success;

  void fetchParticipants() async {
    try {
      // 1- loading state
      participantState = AsyncValue.loading();
      notifyListeners();

      // 2 - Fetch participants
      participantState = AsyncValue.success(await _repository.getParticipant());

      print("SUCCESS: list size ${participantState!.data!.length.toString()}");

      // 3 - Handle errors
    } catch (error) {
      print("ERROR: $error");
      participantState = AsyncValue.error(error);
    }

    notifyListeners();
  }

  // New method to fetch participants for a specific race
  void fetchParticipantsByRace(String raceId) async {
    try {
      // 1- loading state
      participantState = AsyncValue.loading();
      notifyListeners();

      // 2 - Fetch all participants
      final allParticipants = await _repository.getParticipant();
      
      // Log for debugging
      print("Fetched ${allParticipants.length} total participants");
      print("Filtering for race ID: $raceId");
      
      // Debug: Print all participants and their raceIds
      for (final p in allParticipants) {
        print("Participant ${p.firstName} ${p.lastName} (ID: ${p.id}) has raceId: '${p.raceId}'");
      }
      
      // Filter participants by race ID
      final raceParticipants = allParticipants.where((p) => p.raceId == raceId).toList();
      
      print("Found ${raceParticipants.length} participants for race $raceId");
      
      // Update state with filtered participants
      participantState = AsyncValue.success(raceParticipants);

    } catch (error) {
      print("ERROR fetching participants by race: $error");
      participantState = AsyncValue.error(error);
    }

    notifyListeners();
  }

  Future<void> addParticipant({String raceId = ''}) async {
    if (firstNameController.text.trim().isEmpty ||
        lastNameController.text.trim().isEmpty ||
        ageController.text.trim().isEmpty ||
        genderController.text.trim().isEmpty) {
      throw Exception("Please fill all fields");
    }
    final age = int.tryParse(ageController.text);
    if (age == null) {
      throw Exception("Please enter a valid age");
    }
    
    print("Adding participant with raceId: '$raceId'");
    
    // Pass raceId to the repository
    await _repository.addParticipant(
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      age: int.parse(ageController.text),
      id: '',
      bibNumber: 0,
      gender: genderController.text,
      segmentTimes: {},
      raceId: raceId,
    );

    print("Participant added to Firebase with raceId: '$raceId'");
    firstNameController.clear();
    lastNameController.clear();
    ageController.clear();
    genderController.clear();
    notifyListeners();

    // If we're adding to a specific race, fetch only that race's participants
    if (raceId.isNotEmpty) {
      fetchParticipantsByRace(raceId);
    } else {
      // Otherwise fetch all participants
      fetchParticipants();
    }
  }

  Future<void> removeParticipant({required String id}) async {
    try {
      await _repository.removeParticipant(id: id);
      fetchParticipants();
    } catch (e) {
      throw Exception("Failed to delete participant: $e");
    }
  }

  Future<void> editParticipant({
    required String id,
    required String firstName,
    required String lastName,
    required int age,
    required String gender,
    String raceId = '',
  }) async {
    // First update the basic participant info
    await _repository.editParticipant(
      id: id,
      firstName: firstName,
      lastName: lastName,
      age: age,
      gender: gender,
    );
    
    // If a raceId is provided, assign the participant to that race
    if (raceId.isNotEmpty) {
      print("Assigning participant $id to race $raceId");
      await _repository.assignParticipantToRace(id, raceId);
    }
    
    firstNameController.clear();
    lastNameController.clear();
    ageController.clear();
    genderController.clear();
    
    // If we're editing a participant for a specific race, refresh that race's participants
    if (raceId.isNotEmpty) {
      fetchParticipantsByRace(raceId);
    } else {
      fetchParticipants();
    }
  }
}
