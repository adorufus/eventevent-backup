import UIKit
import Flutter
import GoogleMaps
import Firebase
import CleverTap
import CleverTapPlugin

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // FirebaseApp.Configure()
    GeneratedPluginRegistrant.register(with: self)
    GMSServices.provideAPIKey("AIzaSyDO-ES5Iy3hOfiwz-IMQ-tXhOtH9d01RwI")
    CleverTap.autoIntegrate()
    CleverTapPlugin.sharedInstance().applicationDidLaunch(withOptions: launchOptions)
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
