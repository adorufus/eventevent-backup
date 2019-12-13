import UIKit
import Flutter
import GoogleMaps
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // FirebaseApp.Configure()
    GeneratedPluginRegistrant.register(with: self)
    GMSServices.provideAPIKey("AIzaSyDO-ES5Iy3hOfiwz-IMQ-tXhOtH9d01RwI")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
