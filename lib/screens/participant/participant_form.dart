import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracking_app/models/participant/participant.dart';
import 'package:race_tracking_app/provider/participant%20provider/participant_provider.dart';
import 'package:race_tracking_app/theme/theme.dart';
import 'package:race_tracking_app/widgets/action/race_button.dart';
import 'package:race_tracking_app/widgets/input/textfield_input.dart';

enum formMode { add, edit }

class ParticipantForm extends StatefulWidget {
  final formMode mode;
  final Participant? participant;
  const ParticipantForm({super.key, required this.mode, this.participant});

  @override
  State<ParticipantForm> createState() => _ParticipantFormState();
}

class _ParticipantFormState extends State<ParticipantForm> {
  late ParticipantProvider _participantProvider;

  @override
  void initState() {
    super.initState();
    // _participantProvider = ParticipantProvider();
    _participantProvider = context.read<ParticipantProvider>();
    if (widget.mode == formMode.edit && widget.participant != null) {
      _participantProvider.firstNameController.text = widget.participant!.firstName;
      _participantProvider.lastNameController.text = widget.participant!.lastName;
      _participantProvider.ageController.text = widget.participant!.age.toString();
      _participantProvider.genderController.text = widget.participant!.gender;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _participantProvider,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          leading: IconButton(
            icon: Icon(Icons.chevron_left, color: RaceColors.white, size: 35),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            widget.mode == formMode.edit
                ? 'Edit Participant'
                : 'Add Participant',
            style: RaceTextStyles.subheadline.copyWith(color: RaceColors.white),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: _buildForm(
          mode: widget.mode,
          participant: widget.participant,
        ),
      ),
    );
  }
}

class _buildForm extends StatelessWidget {
  final formMode mode;
  final Participant? participant;
  const _buildForm({required this.mode, this.participant});

  @override
  Widget build(BuildContext context) {
    final participantProvider = Provider.of<ParticipantProvider>(context);
    return Container(
      padding: const EdgeInsets.all(RaceSpacings.m),
      child: Column(
        children: [
          TextfieldInput(
            label: "First Name",
            controller: participantProvider.firstNameController,
            hint: "Type here..",
          ),
          const SizedBox(height: RaceSpacings.s),
          TextfieldInput(
            label: "Last Name",
            controller: participantProvider.lastNameController,
            hint: "Type here..",
          ),
          const SizedBox(height: RaceSpacings.s),
          TextfieldInput(
            label: "Age",
            controller: participantProvider.ageController,
            hint: "Type here..",
          ),
          const SizedBox(height: RaceSpacings.s),
          TextfieldInput(
            label: "Gender",
            controller: participantProvider.genderController,
            hint: "Type here..",
          ),
          const Spacer(),
          RaceButton(
            onPressed: () async {
              try {
                if (mode == formMode.add) {
                  await participantProvider.addParticipant();
                } else if (mode == formMode.edit &&
                    participant != null) {
                  await participantProvider.editParticipant(
                    id: participant!.id,
                    firstName: participantProvider.firstNameController.text,
                    lastName: participantProvider.lastNameController.text,
                    age: int.parse(participantProvider.ageController.text),
                    gender: participantProvider.genderController.text,
                  );
                }
                Navigator.of(context).pop();
              } catch (e) {
                print("Error saving participant: $e");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to save participant: $e")),
                );
              }
            },
            text: mode == formMode.add ? "Add" : "Update",
          ),
        ],
      ),
    );
  }
}
