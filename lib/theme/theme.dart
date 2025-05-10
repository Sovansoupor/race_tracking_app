import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

///
/// Definition of App Colors for RaceTheme.
///
class RaceColors {
  static Color primary            = const Color(0xFFFF5532);
  static Color functional         = const Color(0xFF872822);

  static Color backgroundAccent   = const Color(0xFF0F232E);
  static Color backgroundAccentDark   = const Color(0xFF101F28);


  static Color neutralDark        = const Color(0xFF2E3F48);
  static Color neutralLight       = const Color(0xFFE2EFF7);

  static Color greyLight          = const Color(0xFFE1E1E1);
  static Color grey               = const Color(0xFF797979);

  static Color red              = const Color(0xFFEB463D);
  static Color white            = Colors.white;
  static Color green            = const Color(0xFF4DBA0E);

  static Color get backGroundColor { 
    return RaceColors.primary;
  }

  static Color get textNormal {
    return RaceColors.white;
  }

  static Color get textLight {
    return RaceColors.greyLight;
  }

  static Color get iconNormal {
    return RaceColors.primary;
  }

  static Color get iconLight {
    return RaceColors.neutralDark;
  }

  static Color get disabled {
    return RaceColors.grey;
  }
}

///
/// Definition of Text Styles for RaceTheme.
///
class RaceTextStyles {
  static TextStyle heading = GoogleFonts.dmSans(fontSize: 35, fontWeight: FontWeight.w800);

  static TextStyle subheadline = GoogleFonts.dmSans(fontSize: 24, fontWeight: FontWeight.w800);

  static TextStyle body = GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.w800);

  static TextStyle label = GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500);

  static TextStyle button = GoogleFonts.dmSans(fontSize: 17, fontWeight: FontWeight.w700);
}

///
/// Definition of Spacings for RaceTheme.
///
class RaceSpacings {
  static const double xs = 8;
  static const double s = 12;
  static const double m = 18; 
  static const double l = 24; 
  static const double xl = 32; 
  static const double xxl = 40; 

  static const double radius = 10; 
  static const double radiusMedium = 12;
  static const double radiusLarge = 15; 
}

///
/// Definition of App Theme for RaceTheme.
///
ThemeData raceTheme = ThemeData(
  fontFamily: 'DM Sans',
  scaffoldBackgroundColor: RaceColors.backgroundAccent,
);
