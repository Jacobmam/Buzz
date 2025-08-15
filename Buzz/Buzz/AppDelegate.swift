//
//  AppDelegate.swift
//
//  Created by Jay Borania on 04/06/24.
//

@_exported import FirebaseAuth
@_exported import FirebaseCore
@_exported import FirebaseFirestore
@_exported import FirebaseMessaging
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        application.isIdleTimerDisabled = true
//        createLogFolder()
        
        print("launchOptions: \(String(describing: launchOptions))")
        FirebaseApp.configure()
        return true
    }
    
    // MARK: - APP CONSOLE LOGS
    func createLogFolder() {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectoryURL = urls[urls.count - 1] as URL
        
        let dbDirectoryURL = documentDirectoryURL.appendingPathComponent("Logs")
        print("Logs FOLDER PATH:", dbDirectoryURL)
        
        if FileManager.default.fileExists(atPath: dbDirectoryURL.path) == false {
            do {
                try FileManager.default.createDirectory(at: dbDirectoryURL, withIntermediateDirectories: false, attributes: nil)
            } catch let error as NSError {
                print("CAN'T CREATE FOLDER:", error.localizedDescription)
            }
        } else {
            print("FOLDER EXIST")
        }
        redirectLogToDocuments(logurl: dbDirectoryURL.path)
    }
    
    func redirectLogToDocuments(logurl: String) {
        let logpathe = "\(logurl)/Logerr.txt"
        freopen(logpathe.cString(using: .ascii)!, "a+", stderr)
        let logpatho = "\(logurl)/Logout.txt"
        freopen(logpatho.cString(using: .ascii)!, "a+", stdout)
    }
    
    static var orientationLock = UIInterfaceOrientationMask.portrait
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate, MessagingDelegate {
    // MARK: - REGISTER FOR PUSH NOTIFICATION
    
    func registerForPushNotifications() {
        Messaging.messaging().delegate = self
        
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else { return }
        print("Firebase registration token: \(fcmToken)")
        
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        
        NotificationTokenManager.shared.setNotificationToken(token: fcmToken)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // DISPLAY NOTIFICATION WHILE APPLICATION IS IN FOREGROUND
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        // Print full message.
        print(userInfo)
        
        if let type = userInfo["type"] as? String,
           type.count > 0 {
            print("type \(type)")
        }
        
        // Change this to your preferred presentation option
        completionHandler([[.badge, .banner, .list, .sound]])
        
    }

    // HANDLE NOTIFICATION TAP WHILE APPLICATION IS IN BACKGROUND
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print(userInfo)
        
        if let type = userInfo["type"] as? String,
           type.count > 0 {
            print("type \(type)")
            
            switch type {
            case "new_request":
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    NotificationCenter.default.post(name: .navigateToNotificationsView , object: nil)
                }
            default: break
            }
        }
        completionHandler()
    }
}
