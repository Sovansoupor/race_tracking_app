import 'package:flutter/material.dart';
import 'package:race_tracking_app/models/segment/segment.dart';

enum ViewMode { grid, massArrival }

class SegmentProvider extends ChangeNotifier{
  ActivityType _activityType = ActivityType.swimming;
  ViewMode _viewMode = ViewMode.grid;

  ActivityType get activityType => _activityType;
  ViewMode get viewMode => _viewMode;

  void selectSegment(ActivityType segment) {
    if (_activityType != segment) {
      _activityType = segment;
      notifyListeners();
    }
  }

  void selectView(ViewMode view) {
    if (_viewMode != view) {
      _viewMode = view;
      notifyListeners();
    }
  }
}