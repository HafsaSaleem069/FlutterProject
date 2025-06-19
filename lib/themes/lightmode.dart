import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    surface: Colors.white,
    primary: Colors.red.shade900,
    secondary: Colors.grey.shade100,
    tertiary: Colors.black,
    inversePrimary: Colors.redAccent.shade100,
  ),
  textTheme: GoogleFonts.poppinsTextTheme(),
);
