enum ActivityType{
  running,
  cycling,
  swimming,
  flying,
}

extension SegmentTypeExtension on ActivityType {
  String get label {
    switch (this) {
      case ActivityType.running:
        return 'Running';
      case ActivityType.cycling:
        return 'Cycling';
      case ActivityType.swimming:
        return 'Swimming';
      case ActivityType.flying:
        return 'Flying';
    }
  }
}

class Segment {
  final String id;
  final String name;
  final int order;
  final int? distance;
  final ActivityType activityType;

  Segment({required this.activityType ,required this.id, required this.name, required this.order, required this.distance});
}
