//  Converted to Swift 5.3 by Swiftify v5.3.29144 - https://swiftify.com/
import Flutter
import flutter_local_notifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
        }
    
    let dex = FlutterMethodChannel(name: "dexterx.dev/flutter_local_notifications_example",
                                                  binaryMessenger: controller.binaryMessenger)

    dex.setMethodCallHandler({
         (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
        if (call.method == "getTimeZoneName") {
            result(NSTimeZone.local.identifier)
        } else {
            result(nil)
        }
         // Note: this method is invoked on the UI thread.
         // Handle battery messages.
       })
    
    GeneratedPluginRegistrant.register(with: self)
        // Override point for customization after application launch.
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
