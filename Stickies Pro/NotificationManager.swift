//
//  File.swift
//  Stickies
//
//  Created by Shams Tabrej Alam on 18/02/25.
//

import Foundation
import UserNotifications

class NotificationManager {
    @MainActor static let shared = NotificationManager()

    private init() {}

    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else {
                print("Notification permission denied: \(error?.localizedDescription ?? "Unknown error")")
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

                if date <= Date() {
                    print("Notification date is in the past. Skipping notification.")
                    return
                }

                let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

                center.add(request) { error in
                    if let error = error {
                        print("Failed to schedule notification: \(error.localizedDescription)")
                    } else {
                        print("Reminder set for \(date) with ID: \(identifier)")
                    }
                }
            } else {
                print("Notifications not enabled in settings")
            }
        }
    }

    func removeNotification(identifier: String) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        print("Removed notification with ID: \(identifier)")
    }
}
