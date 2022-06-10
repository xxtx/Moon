//
//  AppDelegate.swift
//  Moon
//
//  Created by ZY on 2022/5/30.
//

import UIKit
//import FBSDKCoreKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
//        ApplicationDelegate.shared.application(application,didFinishLaunchingWithOptions: launchOptions)
//        Settings.shared.isAdvertiserTrackingEnabled = true
//        Settings.shared.isAutoLogAppEventsEnabled = true
//        Settings.shared.isAdvertiserIDCollectionEnabled = true
//        Settings.shared.isCodelessDebugLogEnabled = false
        
        FirebaseApp.configure()
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

