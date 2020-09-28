//
//  AppDelegate.swift
//  labo_atte
//
//  Created by jun on 2020/09/27.
//

import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        if #available(iOS 13, *) {
        } else {
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.rootViewController = Routes.decideRootViewController()
            window?.makeKeyAndVisible()
        }
        
        
        
        Messaging.messaging().delegate = self
        setRemoteNotification(application: application)
        

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

}



extension AppDelegate: UNUserNotificationCenterDelegate {
    func setRemoteNotification(application: UIApplication) {
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_, _ in })
        application.registerForRemoteNotifications()
    }
    
    
    // アプリがフォアグラウンドで起動している際にプッシュ通知が届いたら呼ばれる。
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
    }
    
    // プッシュ通知に対しタッチ等のアクションを行った時に呼ばれる。
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    }
}


extension AppDelegate: MessagingDelegate {
    // fcmTokenを受け取った時に呼ばれる。
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        if let uid = Auth.auth().currentUser?.uid {
            print("FcmToken: \(fcmToken)")
            self.setFcmToken(userId: uid, fcmToken: fcmToken)
        }
    }
    
    func setFcmToken(userId: String, fcmToken: String) {
        //let reference = Database.database().reference().child("user").child(userId).child("fcm_token")
        //UserDefaults.standard.set(fcmToken, forKey: "fcmToken")
        //reference.setValue(fcmToken)
    }
}
