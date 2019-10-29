//
//  AppDelegate.swift
//  talkative
//
//  Created by Yusuke Inoue on 2019/10/08.
//  Copyright © 2019 Yusuke Inoue. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var skywayAPIKey:String? = "6aa642bb-37f2-46bd-b78c-4a148ce7efb6"
    var skywayDomain:String? = "talkative.io"

    override init() {
         super.init()
         FirebaseApp.configure()
    }

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//        let realm = try! Realm()
//        do {
//            try Auth.auth().signOut()
//        } catch let error {
//            print(error)
//        }
//        var config = Realm.Configuration()
//        config.deleteRealmIfMigrationNeeded = true
//        try! realm.write {
//            realm.deleteAll()
//        }
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
        AppEventHandler.sharedInstance.startObserving()
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
        // GoogleもしくはFacebook認証の場合、trueを返す
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        // 電話番号認証の場合、trueを返す
        if Auth.auth().canHandle(url) {
            return true
        }
        return false
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification notification: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if Auth.auth().canHandleNotification(notification) {
            completionHandler(.noData)
            return
        }
        // エラーの時の処理を書く
    }

    // MARK: UISceneSession Lifecycle

//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        // Called when a new scene session is being created.
//        // Use this method to select a configuration to create the new scene with.
//        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
//    }
//
//    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
//        // Called when the user discards a scene session.
//        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
//        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
//    }


}

