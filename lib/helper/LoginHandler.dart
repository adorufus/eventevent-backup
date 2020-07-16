import 'dart:io';

import 'package:eventevent/helper/API/baseApi.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginHandler {
  static Future<Map<String, dynamic>> SignInWIthAppleAction() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      // webAuthenticationOptions: WebAuthenticationOptions(
      //   clientId: ,
      //   redirectUri: ,
      // )
    );

    // AppleIDAuthorizationRequest(
    //   scopes: [
    //     AppleIDAuthorizationScopes.email,
    //     AppleIDAuthorizationScopes.fullName,
    //   ]
    // );

    print('athcd: ' + credential.authorizationCode);
    print('idtkn: ' + credential.identityToken);
    print('usrid: ' + credential.userIdentifier);

    // This is the endpoint that will convert an authorization code obtained
    // via Sign in with Apple into a session in your system

    var payload = Jwt.parseJwt(credential.identityToken);
    print(payload);

    return {
      'id_token': credential.identityToken,
      'user_id': credential.userIdentifier,
      'first_name': credential.givenName,
      'last_name': credential.familyName,
      'email': payload['email']
    };
  }

  static Future<Map<dynamic, dynamic>> processAppleLogin() async {
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

    print(response.statusCode);
    print(response.body);

    return {
      'response': response,
      'appleData': appleData
    };
  }

  static Future<http.Response> proccessAppleRegister() {

  }
}
