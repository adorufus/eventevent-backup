// import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';

// class InitInAppBrowser extends InAppBrowser{
//   @override
//   Future onLoadStart(String url) async {
//     print("\n\nStarted $url\n\n");
//   }

//   @override
//   Future onLoadStop(String url) async {
//     print("\n\nStopped $url\n\n");
//   }

//   @override
//   void onLoadError(String url, int code, String message) {
//     print("\n\nCan't load $url.. Error: $message\n\n");
//   }

//   @override
//   void onExit() {
//     print("\n\nBrowser closed!\n\n");
//   }
// }

// InitInAppBrowser inAppBrowserFallback = new InitInAppBrowser();

// class MyChromeSafariBrowser extends ChromeSafariBrowser{
//   MyChromeSafariBrowser(browserFallback) : super(browserFallback);
  
//   @override
//   void onOpened() {
//     // TODO: implement onOpened
//     super.onOpened();
//     print('ChromeSafari browser opened');
//   }

//   @override
//   void onLoaded() {
//     // TODO: implement onLoaded
//     super.onLoaded();
//     print('ChromeSafari browser loaded');
//   }

//   @override
//   void onClosed() {
//     // TODO: implement onClosed
//     super.onClosed();
//     print('ChromeSafari browser closed');
//   }
// }