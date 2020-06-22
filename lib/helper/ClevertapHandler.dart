// import 'package:clevertap_flutter/clevertap_flutter.dart';
import 'package:clevertap_plugin/clevertap_plugin.dart';
import 'package:uuid/uuid.dart';

class ClevertapHandler {
  static void recordEvent(String name, {Map<String, dynamic> withProps}) {
    CleverTapPlugin.recordEvent(name, withProps);
  }

  //Event Handling
  static void handleEventDetail(String eventName, String eventOrganizer,
      String startDate, String endDate, String private, List categories) {
    print("************************");
    print("CleverTap record Event");

    String privateType = "Undefined";

    if (private == '0') {
      privateType = "Public event";
    } else if (private == '1') {
      privateType = "Private event";
    }

    String categoryString = "";

    if (categories != null) {
      for (var cat in categories) {
        if (categoryString == "") {
          categoryString = cat['name'].toString() ?? "";
        } else {
          categoryString = categoryString + ", " + cat['name'].toString() ?? "";
        }
      }
    }

    Map<String, dynamic> props = {
      'Event name': eventName ?? "-",
      'Event organizer': eventOrganizer ?? "-",
      'Is private': privateType,
      'Category': categoryString,
      'Start date': startDate ?? '-',
      'End date': endDate ?? '-'
    };

    recordEvent('Event viewed', withProps: props);
  }

  //Authentication method

  static void pushUserProfile(
      String userFullName,
      String userLastName,
      String email,
      String pictureNormalUrl,
      String userBirthDay,
      String username,
      String userGender,
      String userPhone) {
    print("************************");
    print("CleverTap push user data");

    var parameters = Map<String, dynamic>();
    parameters['Name'] = userFullName ?? '' + ' ' + userLastName ?? '';
    parameters['Email'] = email ?? '';

    if (pictureNormalUrl != null) {
      parameters['Photo'] = pictureNormalUrl;
    }

    parameters['Tz'] = DateTime.now().timeZoneName;

    if (userBirthDay != null) {
      parameters['DOB'] = userBirthDay;
    }

    parameters['Identity'] = username;

    if (userGender.toLowerCase() == "male") {
      parameters['Gender'] = 'M';
    } else if (userGender.toLowerCase() == "female") {
      parameters['Gender'] = 'F';
    }

    if (userPhone != null) {
      parameters['Phone'] = userPhone;
    }

    CleverTapPlugin.onUserLogin(parameters);
  }

  static void removeUserProfile(
      String deviceName,
      String email,
      String pictureNormalUrl,
      String userBirthDay,
      String username,
      String userGender,
      String userPhone) {
    print("************************");
    print("CleverTap push user data");

    var uuid = new Uuid();

    var parameters = Map<String, dynamic>();
    parameters['Name'] = '$deviceName Unauthenticated';
    parameters['Email'] = '-';

    parameters['Tz'] = DateTime.now().timeZoneName;

    if (userBirthDay != null) {
      parameters['DOB'] = '-';
    }

    parameters['Identity'] = uuid.v4.toString();

    parameters['Gender'] = '-';
    parameters['Phone'] = '-';

    CleverTapPlugin.onUserLogin(parameters);
  }
}
