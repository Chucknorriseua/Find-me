//
//  NotificatioManager.swift
//  Find me
//
//  Created by Евгений Полтавец on 14/12/2024.
//

import UIKit
import UserNotifications


final class NotificatioManager {
    
    static let shared = NotificatioManager()
    
    var notificationCenter = UNUserNotificationCenter.current()
    
    func notify(title: String, subTitle: String, timeInterval: Int) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subTitle
        content.sound = UNNotificationSound.default
        content.badge = 0
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(timeInterval), repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error adding notification: \(error.localizedDescription)")
            }
        }
    }
    
    func requestAuthorization() {
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("Permission granted for notifications.")
                    UIApplication.shared.registerForRemoteNotifications()
                    self.getNotificationsSetting()
                } else {
                    print("Permission for push notifications denied.")
                }
            }
        }
    }
    
    func getNotificationsSetting() {
        notificationCenter.getNotificationSettings { settings in
            print("Notifications settings: \(settings)")
            if settings.authorizationStatus == .authorized {
                print("Notifications are authorized.")
            } else {
                print("Notifications are not authorized.")
            }
        }
    }
}
