class Participant {
  final String firstName;
  final String lastName;
  final String gender;
  final String id;
  final int age;
  final int bibNumber;
  final String raceId;
  final Map<String, Duration> segmentTimes;

  Participant(
    this.segmentTimes, {
    required this.firstName,
    required this.lastName,
    required this.gender,
    // required this.id,
    required this.age,
    required this.bibNumber,
    this.id = '',
    this.raceId = '',
  });
}
