import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode mode = ThemeMode.dark;
  bool isUsingSystem = true;

  bool get isDarkMode => mode == ThemeMode.dark;
}