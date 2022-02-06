import 'package:flutter/material.dart';

class Constants {
  static String appName = 'GnuCash Mobile';

  // Colors
  static Color white = Color(0xfff3f4f9);
  static Color black = Color(0xff1B1B1B);
  static Color mutedBlack = Color(0xff2B2B2B);
  static Color blue = Color(0xff597ef7);
  static Color mutedBlue = Color(0xff597ef7);
  static Color red = Color(0xffc11c1c);
  static Color mutedRed = Color(0xffc94848);
  static Color green = Color(0xff76c759);
  static Color mutedGreen = Color(0xff589244);

  static TextStyle biggerFont = TextStyle(fontSize: 18.0);

  static ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.light().copyWith(
      background: white,
      onBackground: black,
      brightness: Brightness.light,
      primary: green,
      onPrimary: black,
      secondary: blue,
      onSecondary: white,
      error: red,
      onError: white,
    )
  );

  static ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.dark().copyWith(
      primary: mutedGreen,
      onPrimary: white,
      secondary: mutedBlue,
      onSecondary: white,
      error: mutedRed,
      onError: white,
      background: mutedBlack,
      onBackground: white,
      brightness: Brightness.dark,
    )
  );
}
