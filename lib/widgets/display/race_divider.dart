import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class RaceDivider extends StatelessWidget {
  const RaceDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: RaceColors.white,
    );
  }
}
