import 'package:eventevent/Providers/ThemeProvider.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DarkModeSettings extends StatefulWidget {
  @override
  _DarkModeSettingsState createState() => _DarkModeSettingsState();
}

class _DarkModeSettingsState extends State<DarkModeSettings> {
  bool isSystem = false;
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final themeProviderNonListenable = Provider.of<ThemeProvider>(
      context,
      listen: false,
    );
    isSystem = themeProvider.isUsingSystem;
    isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: checkForBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          child: Icon(Icons.arrow_back_ios, color: Theme.of(context)
              .iconTheme.color,),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: <Widget>[
            // listTileItem(
            //   "Use System Theme (experimental)",
            //   onChanged: (value) {
            //     themeProviderNonListenable.toggleSystemTheme(value);
            //   },
            //   switchValue: isSystem,
            //   isSwitchEnabled: true,
            // ),
            listTileItem(
              "Toggle Dark Mode (experimental)",
              onChanged: (value) {
                themeProviderNonListenable.toggleTheme(value);
              },
              switchValue: isDarkMode,
              isSwitchEnabled: themeProvider.isUsingSystem ? false : true,
            ),
          ],
        ),
      ),
    );
  }

  Widget listTileItem(String title,
      {Function(bool) onChanged, bool switchValue, bool isSwitchEnabled}) {
    return Container(
      color: checkForContainerBackgroundColor(context),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            color: checkForAppBarTitleColor(context),
          ),
        ),
        enabled: isSwitchEnabled,
        trailing: Switch(
          onChanged: onChanged,
          value: switchValue,
          activeColor: eventajaGreenTeal,
        ),
      ),
    );
  }
}
