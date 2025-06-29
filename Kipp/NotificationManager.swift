//
//  NotificationManager.swift
//  Kipp
//
//  Created by Shams Tabrej Alam on 18/02/25.
//

import Foundation
import UserNotifications
import UIKit

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    @MainActor static let shared = NotificationManager()

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    func requestNotificationPermission() {
        print("🔔 Requesting notification permission...")
        let center = UNUserNotificationCenter.current()
        
        center.getNotificationSettings { settings in
            print("📱 Current notification settings:")
            print("   - Authorization status: \(settings.authorizationStatus.rawValue)")
            print("   - Alert setting: \(settings.alertSetting.rawValue)")
            print("   - Sound setting: \(settings.soundSetting.rawValue)")
            print("   - Badge setting: \(settings.badgeSetting.rawValue)")
            
            switch settings.authorizationStatus {
            case .notDetermined:
                print("🔔 Permission not determined - requesting...")
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    DispatchQueue.main.async {
                        if granted {
                            print("✅ Notification permission granted!")
                        } else {
                            print("❌ Notification permission denied: \(error?.localizedDescription ?? "Unknown error")")
                        }
                    }
                }
            case .authorized:
                print("✅ Notification permission already authorized")
            case .denied:
                print("❌ Notification permission denied - user needs to enable in Settings")
            case .provisional:
                print("⚠️ Provisional notification permission")
            case .ephemeral:
                print("⚠️ Ephemeral notification permission")
            @unknown default:
                print("❓ Unknown notification permission status")
            }
        }
    }

    func scheduleNotification(title: String, body: String, date: Date, identifier: String) {
        print("🔔 Attempting to schedule notification:")
        print("   - Title: \(title)")
        print("   - Body: \(body)")
        print("   - Date: \(date)")
        print("   - ID: \(identifier)")
        
        let center = UNUserNotificationCenter.current()

        center.getNotificationSettings { settings in
            print("📱 Checking notification settings before scheduling...")
            print("   - Authorization status: \(settings.authorizationStatus.rawValue)")
            
            if settings.authorizationStatus == .authorized {
                print("✅ Notifications authorized - proceeding with scheduling")
                
                center.removePendingNotificationRequests(withIdentifiers: [identifier])
                print("🗑️ Removed existing notification with ID: \(identifier)")

                let content = UNMutableNotificationContent()
                content.title = title
                content.body = body
                content.sound = .default
                content.badge = 1

                if date <= Date() {
                    print("❌ Notification date is in the past. Skipping notification.")
                    return
                }

                let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
                
                print("⏰ Trigger date components: \(triggerDate)")

                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

                center.add(request) { error in
                    if let error = error {
                        print("❌ Failed to schedule notification: \(error.localizedDescription)")
                    } else {
                        print("✅ Notification scheduled successfully for \(date) with ID: \(identifier)")
                        
                        center.getPendingNotificationRequests { requests in
                            print("📋 Total pending notifications: \(requests.count)")
                            for request in requests {
                                print("   - ID: \(request.identifier)")
                                if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                                    print("   - Next trigger: \(trigger.nextTriggerDate() ?? Date())")
                                }
                            }
                        }
                    }
                }
            } else {
                print("❌ Notifications not authorized. Current status: \(settings.authorizationStatus.rawValue)")
                print("💡 User needs to enable notifications in Settings > Notifications > Kipp")
            }
        }
    }

    func removeNotification(identifier: String) {
        print("🗑️ Removing notification with ID: \(identifier)")
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        print("✅ Removed notification with ID: \(identifier)")
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("🔔 Notification received while app is in foreground")
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("🔔 User tapped on notification: \(response.notification.request.identifier)")
        UIApplication.shared.applicationIconBadgeNumber = 0
        completionHandler()
    }
}
