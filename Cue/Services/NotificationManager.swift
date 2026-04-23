//
//  NotificationManager.swift
//  Cue
//
//  Created by Mario Hernández Corral on 16/2/26.
//

import Foundation
import os
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()

    static let categoryIdentifier = "DAY_TASK"
    static let completeActionID = "COMPLETE_ACTION"
    static let snooze30ActionID = "SNOOZE_30_ACTION"
    static let snooze60ActionID = "SNOOZE_60_ACTION"
    static let snoozeTomorrowActionID = "SNOOZE_TOMORROW_ACTION"

    private let center = UNUserNotificationCenter.current()
    private let logger = Logger(subsystem: "com.mariohernandez.Cue", category: "Notifications")

    private init() {}

    // MARK: - Authorization

    func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func authorizationStatus() async -> UNAuthorizationStatus {
        await center.notificationSettings().authorizationStatus
    }

    // MARK: - Categories

    func registerCategories() {
        let complete = UNNotificationAction(
            identifier: Self.completeActionID,
            title: String(localized: "Mark as completed"),
            options: []
        )
        let snooze30 = UNNotificationAction(
            identifier: Self.snooze30ActionID,
            title: String(localized: "Remind in 30 min"),
            options: []
        )
        let snooze60 = UNNotificationAction(
            identifier: Self.snooze60ActionID,
            title: String(localized: "Remind in 1 hour"),
            options: []
        )
        let snoozeTomorrow = UNNotificationAction(
            identifier: Self.snoozeTomorrowActionID,
            title: String(localized: "Remind tomorrow"),
            options: []
        )

        let category = UNNotificationCategory(
            identifier: Self.categoryIdentifier,
            actions: [complete, snooze30, snooze60, snoozeTomorrow],
            intentIdentifiers: [],
            options: []
        )

        center.setNotificationCategories([category])
    }

    // MARK: - Schedule notification

    func schedule(for task: DayTask) async {
        let triggerDate = task.scheduledTime.addingTimeInterval(
            -Double(task.reminderOffset * 60)
        )

        // Don't schedule if the reminder time has already passed
        guard triggerDate > .now else { return }

        let content = UNMutableNotificationContent()
        content.title = String(localized: "In \(task.reminderOffset) minutes")
        content.body = task.title
        content.sound = .default
        content.categoryIdentifier = Self.categoryIdentifier

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

        do {
            try await center.add(request)
        } catch {
            logger.error("Failed to schedule notification for task '\(task.title)': \(error.localizedDescription)")
        }
    }

    // MARK: - Cancel notification

    func cancel(for task: DayTask) {
        center.removePendingNotificationRequests(
            withIdentifiers: [task.notificationID]
        )
    }
}
