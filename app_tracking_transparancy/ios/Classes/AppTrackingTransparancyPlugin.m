#import "AppTrackingTransparancyPlugin.h"
#if __has_include(<app_tracking_transparancy/app_tracking_transparancy-Swift.h>)
#import <app_tracking_transparancy/app_tracking_transparancy-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "app_tracking_transparancy-Swift.h"
#endif

@implementation AppTrackingTransparancyPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAppTrackingTransparancyPlugin registerWithRegistrar:registrar];
}
@end
