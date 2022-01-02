//
//  MQTT_MessagingApp.swift
//  MQTT Messaging
//
//  Created by Neil McGrogan on 1/2/22.
//

import SwiftUI
import UIKit

@available(iOS 15, *)
@main
struct MQTT_MessagingApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ViewController()
                .environmentObject(ViewRouter())
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        return true
    }
}
