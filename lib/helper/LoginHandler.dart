import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginHandler {
  static void SignInWIthAppleAction() async {
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
    final signInWithAppleEndpoint = Uri(
      scheme: 'https',
      host: 'enchanting-mountain-macaw.glitch.me',
      path: '/sign_in_with_apple',
      queryParameters: <String, String>{
        'code': credential.authorizationCode,
        'firstName': credential.givenName,
        'lastName': credential.familyName,
        'useBundleId': Platform.isIOS || Platform.isMacOS ? 'true' : 'false',
        if (credential.state != null) 'state': credential.state,
      },
    );

    final session = await http.Client().post(
      signInWithAppleEndpoint,
    );

    print(session.body);
  }
}
