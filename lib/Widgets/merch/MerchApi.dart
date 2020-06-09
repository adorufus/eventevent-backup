import 'package:eventevent/helper/API/baseApi.dart';
import 'package:http/http.dart' as http;
import 'package:eventevent/Models/MerchBannerModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MerchApi {
  static Future<http.Response> getMerchBanner(bool isRest, viewModel) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String baseUrl = '';
    Map<String, String> headers;

    if (isRest) {
      baseUrl = BaseApi().restUrl;
      headers = {'Authorization': AUTHORIZATION_KEY, 'signature': SIGNATURE};
    } else {
      baseUrl = BaseApi().apiUrl;
      headers = {
        'Authorization': AUTHORIZATION_KEY,
        'cookie': preferences.getString('Session')
      };
    }

    String url = baseUrl + '/product/banner?X-API-KEY=$API_KEY&page=1';

    final response = await http.get(url, headers: headers);

    return response;
  }

  static Future<http.Response> discover(bool isRest) async {
    return null;
  }
}
