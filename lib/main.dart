import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracking_app/provider/race/race_provider.dart';
import 'package:race_tracking_app/widgets/navigation/bottom_nav_bar.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RaceProvider()..fetchRaces()),
        // ChangeNotifierProvider(
        //   create: (_) => SegmentProvider()..fetchSegments(),
        // ),
      ],
      child: MaterialApp(
        home: BottomNavBar(),
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}
