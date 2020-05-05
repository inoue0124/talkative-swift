import UIKit
import Firebase
import FirebaseUI
import RealmSwift
import FirebaseMessaging
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var skywayAPIKey:String? = "xxxxxx"
    var skywayDomain:String? = "xxxxxx"

    override init() {
        super.init()
        FirebaseApp.configure()
    }

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        var config = Realm.Configuration()
        config.deleteRealmIfMigrationNeeded = true
        let realm = try! Realm(configuration: config)
//        try! realm.write {
//            realm.deleteAll()
//        }
        if realm.isEmpty {
            do {
                try Auth.auth().signOut()
            } catch let error {
                print(error)
            }
        }
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user == nil {
                self.window = UIWindow(frame: UIScreen.main.bounds)
                let loginStoryboard: UIStoryboard = UIStoryboard(name: "loginView", bundle: nil)
                let loginVC = loginStoryboard.instantiateInitialViewController()
                self.window?.rootViewController = loginVC
                self.window?.makeKeyAndVisible()
            }
        }
        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        application.registerForRemoteNotifications()
        AppEventHandler.sharedInstance.startObserving()
        return true
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
      if let messageID = userInfo["gcm.message_id"] {
        print("Message ID: \(messageID)")
      }
      print(userInfo)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
      if let messageID = userInfo["gcm.message_id"] {
        print("Message ID: \(messageID)")
      }
      print(userInfo)
      completionHandler(UIBackgroundFetchResult.newData)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
      print("Unable to register for remote notifications: \(error.localizedDescription)")
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
      print("APNs token retrieved: \(deviceToken)")
        Messaging.messaging().apnsToken = deviceToken
    }
}

extension AppDelegate : UNUserNotificationCenterDelegate {

    // 通知を受け取った時に(開く前に)呼ばれるメソッド
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo

        if let messageID = userInfo["gcm.message_id"] {
            print("Message ID: \(messageID)")
        }
        print(userInfo)
        completionHandler([.alert])
    }

    // 通知を開いた時に呼ばれるメソッド
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        if let messageID = userInfo["gcm.message_id"] {
            print("Message ID: \(messageID)")
        }
        print(userInfo)
        completionHandler()
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        UserDefaults.standard.set(fcmToken, forKey: "FCM_TOKEN")
        UserDefaults.standard.synchronize()
        print("Firebase registration token: \(fcmToken)")
    }

    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
}
