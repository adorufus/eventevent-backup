// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:eventevent/helper/API/baseApi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eventevent/main.dart';
import 'package:eventevent/Widgets/eventDetailsWidget.dart';
import 'package:http/http.dart' as http;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // testWidgets('Counter increments smoke test', (WidgetTester tester) async {
  //   final eventDetail = EventDetailsConstructView();

  //   // Build our app and trigger a frame.
  //   await tester.pumpWidget(RunApp());

  //   // Verify that our counter starts at 0.
  //   expect(find.text('0'), findsOneWidget);
  //   expect(find.text('1'), findsNothing);

  //   // Tap the '+' icon and trigger a frame.
  //   await tester.tap(find.byIcon(Icons.add));
  //   await tester.pump();

  //   // Verify that our counter has incremented.
  //   expect(find.text('0'), findsNothing);
  //   expect(find.text('1'), findsOneWidget);
  // });

  test("testing api", () async {
    String url = BaseApi().apiUrl + '';

    await http.post(
      url,
      body: {
        'X-API-KEY': API_KEY,
        'body': 'test notif masuk ga nih',
        'title': 'test notif',
        'token': '',
      },
      headers: {
        'Authorization': AUTH_KEY,
        'cookie': 'ci_session=f46lgela6s4487t4nvi6bi9lqc7kmfbe',
      },
    ).then((response) {
      print(response.body);
      print(response.statusCode);
    });
  });
}
