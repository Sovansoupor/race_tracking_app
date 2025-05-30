import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:race_tracking_app/data/repository/firebase/firebase_participant_repository.dart';
import '../../provider/race/race_provider.dart';
import '../../theme/theme.dart';
import '../race/race_details.dart';

class RaceHomeScreen extends StatelessWidget {
  const RaceHomeScreen({super.key});
  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final participantRepository = FirebaseParticipantRepository();

    return Consumer<RaceProvider>(
      builder: (context, raceProvider, child) {
        final races = raceProvider.races;

        if (races.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'No competition',
                  style: RaceTextStyles.body.copyWith(
                    color: RaceColors.textNormal,
                  ),
                ),
                Text(
                  'Create a new competition',
                  style: RaceTextStyles.label.copyWith(
                    color: RaceColors.textNormal,
                  ),
                ),
                Text(
                  'Tap + to create',
                  style: RaceTextStyles.label.copyWith(
                    color: RaceColors.textNormal,
                  ),
                ),
              ],
            ),
          );
        }

        return FutureBuilder(
          future: participantRepository.getParticipant(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            final allParticipants = snapshot.data ?? [];

            return ListView.builder(
              padding: const EdgeInsets.all(RaceSpacings.s),
              itemCount: races.length,
              itemBuilder: (context, index) {
                final race = races[index];

                // Count participants for this race
                final participants =
                    allParticipants.where((p) => p.raceId == race.id).toList();

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: RaceSpacings.xs),
                  color: RaceColors.neutralLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(RaceSpacings.radius),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(RaceSpacings.s),
                    title: Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                race.name,
                                style: RaceTextStyles.body.copyWith(
                                  fontWeight: FontWeight.w200,
                                ),
                              ),
                              Spacer(),
                              IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => RaceDetails(
                                            race: race,
                                            participants: participants,
                                          ),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.chevron_right, size: 30),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_month,
                                color: Colors.black,
                                size: 15,
                              ),
                              SizedBox(width: 10),
                              Text(
                                DateFormat(
                                  'dd MMM, yyyy',
                                ).format(race.startTime),
                                style: RaceTextStyles.label.copyWith(),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.people_alt_outlined,
                                color: Colors.black,
                                size: 15,
                              ),
                              SizedBox(width: 10),
                              Text(
                                '${participants.length} participants',
                                style: RaceTextStyles.label.copyWith(),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                        ],
                      ),
                    ),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...race.segments.map((segment) {
                          final distanceText =
                              segment.distance.trim().isEmpty
                                  ? 'No distance'
                                  : segment.distance;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Container(
                              decoration: BoxDecoration(
                                color: RaceColors.white,
                                borderRadius: BorderRadius.circular(
                                  RaceSpacings.radius,
                                ),
                                border: Border.all(
                                  color: RaceColors.neutralDark,
                                  width: 0.25,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(RaceSpacings.s),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _capitalizeFirstLetter(segment.name),
                                      style: RaceTextStyles.label.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      " Distance $distanceText",
                                      style: RaceTextStyles.label.copyWith(
                                        color: RaceColors.neutralDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    RaceSpacings.radius,
                                  ),
                                ),
                              ),
                              onPressed: () {
                                raceProvider.deleteRace(race.id);
                              },
                              child: Text(
                                'Delete Race',
                                style: RaceTextStyles.label.copyWith(
                                  color: RaceColors.neutralDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
