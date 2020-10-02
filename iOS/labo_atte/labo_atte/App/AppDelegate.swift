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
        
        application.applicationIconBadgeNumber = 0
        
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        

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
    

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard let currentNumOfAttendeesStr = userInfo["currentNumOfAttendees"] as? String else {
            completionHandler(.noData)
            return
        }
        guard let currentNumOfAttendeesNum = Int(currentNumOfAttendeesStr) else {
            completionHandler(.failed)
            return
        }
        
        UserDefaults.standard.set(currentNumOfAttendeesNum, forKey: "currentNumOfAttendees")
        completionHandler(.newData)
    }

}



extension AppDelegate: UNUserNotificationCenterDelegate {
    // ForeGround
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if #available(iOS 14, *) {
            completionHandler([.banner, .sound])
        } else {
            completionHandler([.alert, .sound])
        }
        
    }
    
    // response
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        

    }
    
    
}


extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        if let uid = Auth.auth().currentUser?.uid {
            print("fcmToken: \(fcmToken)")
            self.setFcmToken(userID: uid, fcmToken: fcmToken)
        }
    }
    
    func setFcmToken(userID: String, fcmToken: String) {
        let firestore = Firestore.firestore()
        let settings = FirestoreSettings()
        firestore.settings = settings
        firestore.collection("todo/v1/users/").document(userID).updateData(["fcmToken": fcmToken]) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
        }
    }
}
