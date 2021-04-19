import 'package:eventevent/helper/API/baseApi.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FeedbackLogic {
  static Future<http.Response> postFeedback(
      String eventId, String reviewTypeId, String description) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String url = BaseApi().apiUrl + '/event_review/post';

    print(eventId + ' ' + reviewTypeId + ' ' + description);

    final response = await http.post(url, body: {
      'X-API-KEY': API_KEY,
      'eventID': eventId,
      'review_type_id': reviewTypeId,
      'description': description
    }, headers: {
      'Authorization': AUTH_KEY,
      'cookie': preferences.getString('Session')
    });

    print(response.body);

    return response;
  }
}
