import 'package:flutter/material.dart';

enum ActivityType { swimming, cycling, running }

extension SegmentTypeExtension on ActivityType {
  String get label {
    switch (this) {
      case ActivityType.swimming:
        return 'Swimming';
      case ActivityType.running:
        return 'Running';
      case ActivityType.cycling:
        return 'Cycling';
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
    }
  }
}

class Segment {
  final String id;
  final String name;
  final int order;
  final int? distance;
  final ActivityType activityType;
  final String? unit;

  Segment({
    required this.activityType,
    required this.id,
    required this.name,
    required this.order,
    this.distance,
    this.unit,
  });

  // Add this copyWith method
  Segment copyWith({
    String? id,
    String? name,
    int? order,
    int? distance,
    ActivityType? activityType,
    String? unit,
  }) {
    return Segment(
      id: id ?? this.id,
      name: name ?? this.name,
      order: order ?? this.order,
      distance: distance ?? this.distance,
      activityType: activityType ?? this.activityType,
      unit: unit ?? this.unit,
    );
  }

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
