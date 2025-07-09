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
        let center = UNUserNotificationCenter.current()
        
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    DispatchQueue.main.async {
                        // No print
                    }
                }
            case .authorized:
                break // No print
            case .denied:
                break // No print
            case .provisional:
                break // No print
            @unknown default:
                break // No print
            }
        }
    }

    func scheduleNotification(title: String, body: String, date: Date, identifier: String) {
        let center = UNUserNotificationCenter.current()

        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                center.removePendingNotificationRequests(withIdentifiers: [identifier])

                let content = UNMutableNotificationContent()
                content.title = title
                content.body = body
                content.sound = .default
                content.badge = 1

                if date <= Date() {
                    return
                }

                let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

                center.add(request) { error in
                    if let error = error {
                        // No print
                    } else {
                        center.getPendingNotificationRequests { requests in
                            // No print
                        }
                    }
                }
            } else {
                // No print
            }
        }
    }

    func removeNotification(identifier: String) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        completionHandler()
    }
}
