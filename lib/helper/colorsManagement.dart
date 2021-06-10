import 'package:eventevent/Providers/ThemeProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/painting.dart';
import 'package:provider/provider.dart';

///Pengaturan Warna taro disini aja gan :)

final Color eventajaRedTeal = Color.fromRGBO(198, 47, 89, 1.0);
final Color eventajaGreenTeal = new Color.fromRGBO(0, 222, 145, 1.0);
final Color eventajaBlack = new Color.fromRGBO(94, 94, 94, 1.0);
final Color themeBasedTextColor = ThemeData.fallback()
    .textTheme.body1.color;
final Color appBarColor = ThemeData.fallback().appBarTheme.color;

const MaterialColor eventajaGreen =
    const MaterialColor(0xFF00DE91, const <int, Color>{
  50: const Color(0xFF00DE91),
  100: const Color(0xFF00DE91),
  200: const Color(0xFF00DE91),
  300: const Color(0xFF00DE91),
  400: const Color(0xFF00DE91),
  500: const Color(0xFF00DE91),
  600: const Color(0xFF00DE91),
  700: const Color(0xFF00DE91),
  800: const Color(0xFF00DE91),
  900: const Color(0xFF00DE91),
});

const MaterialColor darkPrimarySwatch = const MaterialColor(
  0xff232931,
  <int, Color>{
    50: Color(0xff393e46),
  },
);

const MaterialColor whitePrimarySwatch = const MaterialColor(
  0xff000000,
  <int, Color>{
    50: Color(0xffffffff),
  },
);

Color checkForBackgroundColor(BuildContext context) {
  return Provider.of<ThemeProvider>(context).isDarkMode ? darkPrimarySwatch :
  Colors.white;
}

Color checkForContainerBackgroundColor(BuildContext context) {
  return Provider.of<ThemeProvider>(context).isDarkMode ?
  Color(0xff383838) : Colors.white;
}

Color checkForSettingsTitleColor(BuildContext context) {
  return Provider.of<ThemeProvider>(context).isDarkMode ? Colors.white : Colors
      .grey[700];
}

Color checkForEventDetailsEOMenuTitle(BuildContext context) {
  return Provider.of<ThemeProvider>(context).isDarkMode ? Colors.white :
  Color(0xff404041);
}

Color checkForAppBarTitleColor(BuildContext context) {
  return Provider.of<ThemeProvider>(context).isDarkMode ? Colors.white :
  Colors.black54;
}

Color checkForTextTitleColor(BuildContext context) {
  return Provider.of<ThemeProvider>(context).isDarkMode ? Colors.grey :
  Colors.black;
}

Color barColor(BuildContext context) {
  return Provider.of<ThemeProvider>(context).isDarkMode ?
  darkPrimarySwatch : Colors.white;
}

Color checkForIconThemeColor(BuildContext context) {
  return Provider.of<ThemeProvider>(context).isDarkMode ? ThemeData.dark()
      .iconTheme.color : ThemeData.light().iconTheme.color;
}

bool isBlackThemed(BuildContext context) {
  return Provider.of<ThemeProvider>(context).isDarkMode;
}