//
//  NotificationManager.swift
//  Cue
//
//  Created by Mario Hernández Corral on 16/2/26.
//

import Foundation
import UserNotifications

@Observable
final class NotificationManager {
    static let shared = NotificationManager()

    private let center = UNUserNotificationCenter.current()

    private init() {}

    // MARK: - Authorization

    func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    // MARK: - Schedule notification

    func schedule(for task: DayTask) async {
        let triggerDate = task.scheduledTime.addingTimeInterval(
            -Double(task.reminderOffset * 60)
        )

        // Don't schedule if the reminder time has already passed
        guard triggerDate > .now else { return }

        let content = UNMutableNotificationContent()
        content.title = "En \(task.reminderOffset) minutos"
        content.body = task.title
        content.sound = .default

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: triggerDate
        )
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: task.notificationID,
            content: content,
            trigger: trigger
        )

        try? await center.add(request)
    }

    // MARK: - Cancel notification

    func cancel(for task: DayTask) {
        center.removePendingNotificationRequests(
            withIdentifiers: [task.notificationID]
        )
    }
}
