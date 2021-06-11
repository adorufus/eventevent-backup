import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:eventevent/helper/colorsManagement.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode mode = ThemeMode.light;
  bool isUsingSystem = true;

  bool get isDarkMode => mode == ThemeMode.dark;

  void toggleSystemTheme(bool isOn) {
    isUsingSystem = isOn ? true : false;

    notifyListeners();
  }

  void toggleTheme(bool isOn) {
    mode = isOn ? ThemeMode.dark : ThemeMode.light;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: isOn ? darkPrimarySwatch : Colors.white,
        statusBarIconBrightness: isOn
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarColor: isOn
            ? darkPrimarySwatch
            : Colors.white,
      ),
    );

    notifyListeners();
  }
}