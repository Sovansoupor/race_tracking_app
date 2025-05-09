import 'package:flutter/material.dart';

enum ActivityType { swimming, cycling, running, flying }

extension SegmentTypeExtension on ActivityType {
  String get label {
    switch (this) {
      case ActivityType.swimming:
        return 'Swimming';
      case ActivityType.running:
        return 'Running';
      case ActivityType.cycling:
        return 'Cycling';
      case ActivityType.flying:
        return 'Flying';
    }
  }

  IconData get icon {
    switch (this) {
      case ActivityType.swimming:
        return Icons.pool; // Icon for Swimming
      case ActivityType.running:
        return Icons.directions_run; // Icon for Running
      case ActivityType.cycling:
        return Icons.directions_bike; // Icon for Cycling
      case ActivityType.flying:
        return Icons.airplanemode_active; // Icon for Flying
    }
  }
}

class Segment {
  final String id;
  final String name;
  final int order;
  final int? distance;
  final ActivityType activityType;

  Segment({
    required this.activityType,
    required this.id,
    required this.name,
    required this.order,
    required this.distance,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Segment &&
        other.id == id &&
        other.name == name &&
        other.order == order &&
        other.distance == distance &&
        other.activityType == activityType;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        order.hashCode ^
        distance.hashCode ^
        activityType.hashCode;
  }
}
