class Race {
  final String id;
  final String name;
  final DateTime startTime;
  final List<String> participantIds;
  final List<String> segments;

  Race({required this.id, required this.name, required this.participantIds, required this.startTime, required this.segments});
}