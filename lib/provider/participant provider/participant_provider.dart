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

  Future<void> addParticipant() async {
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
    await _repository.addParticipant(
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      age: int.parse(ageController.text),
      id: '',
      bibNumber: 0,
      gender: genderController.text,
      segmentTimes: {},
    );

    print("Participant added to Firebase");
    firstNameController.clear();
    lastNameController.clear();
    ageController.clear();
    genderController.clear();
    notifyListeners();

    // 2- Call repo to fetch
    fetchParticipants();
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
  }) async {
    await _repository.editParticipant(
      id: id,
      firstName: firstName,
      lastName: lastName,
      age: age,
      gender: gender,
    );
    firstNameController.clear();
    lastNameController.clear();
    ageController.clear();
    genderController.clear();
    fetchParticipants();
  }

  Future<void> massTrackParticipants(
    Duration arrivalTime,
    List<int> participantIndexes,
  ) async {
    if (participantState == null || participantState!.data == null) return;
    final participants = participantState!.data!;
    for (final idx in participantIndexes) {
      if (idx < 0 || idx >= participants.length) continue;
      final participant = participants[idx];
      // Create a new map for segmentTimes with updated arrival
      final updatedSegmentTimes = Map<String, Duration>.from(
        participant.segmentTimes,
      );
      updatedSegmentTimes["arrival"] = arrivalTime;
      await _repository.editParticipant(
        id: participant.id,
        firstName: participant.firstName,
        lastName: participant.lastName,
        age: participant.age,
        gender: participant.gender,
        segmentTimes: updatedSegmentTimes,
      );
    }
    fetchParticipants();
    notifyListeners();
  }
}
