import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData darkMode = ThemeData(
  colorScheme: ColorScheme.dark( //built in class dark color scheme
    surface: Colors.black54,
    primary:  Colors.red.shade900,
    secondary: Colors.grey.shade500,
    tertiary:Colors.grey.shade200,
    inversePrimary: Colors.grey.shade200,
  ),
  textTheme: GoogleFonts.poppinsTextTheme(),
);
