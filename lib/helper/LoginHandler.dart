import 'dart:io';

import 'package:eventevent/helper/API/baseApi.dart';
import 'package:http/http.dart' as http;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginHandler {
  static Future<Map<String, dynamic>> SignInWIthAppleAction() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName
      ],
    );

    print('athcd: ' + credential.authorizationCode);
    print('idtkn: ' + credential.identityToken);
    print('usrid: ' + credential.userIdentifier);

    // This is the endpoint that will convert an authorization code obtained
    // via Sign in with Apple into a session in your system

    return {
      'id_token': credential.identityToken,
      'user_id': credential.userIdentifier
    };
  }

  static Future<http.Response> processAppleLogin() async {
    String baseUrl = BaseApi().apiUrl + "/signin/apple";
    Map<String, dynamic> appleData;

    await SignInWIthAppleAction().then((data) => appleData = data);

    print('apple data' + appleData.toString());

    final response = await http.post(
      baseUrl,
      body: {
        'identity_token': appleData['id_token'],
        'user_id': appleData['user_id'],
        'X-API-KEY': API_KEY
      },
      headers: {
        'Authorization': AUTHORIZATION_KEY,
      }
    );

    return response;
  }
}
