import 'package:flutter/material.dart';
import 'package:project/themes/darkmode.dart';
import 'package:project/themes/lightmode.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = lightMode;

  ThemeData get themeData =>
      _themeData; // This is a getter method that lets other files access the current theme.

  bool get isDarkMode =>
      _themeData ==
      darkMode; // This returns true if the current theme is dark mode.

  //This is a setter. When you set a new theme, it updates _themeData and calls notifyListeners()
  // — this tells the app: "Hey, something changed! Rebuild the UI!"
  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeData == lightMode) {
      themeData = darkMode;
    } else {
      themeData = lightMode;
    }
  }
}
