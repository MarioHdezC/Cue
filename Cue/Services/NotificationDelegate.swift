//
//  NotificationDelegate.swift
//  Cue
//
//  Created by Mario Hernández Corral on 23/4/26.
//

import Foundation
import os
import SwiftData
import UserNotifications

final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()

    private let logger = Logger(subsystem: "com.mariohernandez.Cue", category: "NotificationDelegate")

    private override init() {
        super.init()
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let notificationID = response.notification.request.identifier
        let actionID = response.actionIdentifier

        switch actionID {
        case NotificationManager.completeActionID:
            await handleComplete(notificationID: notificationID)
        case NotificationManager.snooze30ActionID:
            await handleSnooze(notificationID: notificationID, seconds: 30 * 60)
        case NotificationManager.snooze60ActionID:
            await handleSnooze(notificationID: notificationID, seconds: 60 * 60)
        case NotificationManager.snoozeTomorrowActionID:
            await handleSnoozeTomorrow(notificationID: notificationID)
        default:
            break
        }
    }

    // MARK: - Handlers

    @MainActor
    private func handleComplete(notificationID: String) async {
        guard let task = fetchTask(notificationID: notificationID) else { return }
        task.isCompleted = true
        task.originalScheduledTime = nil
        NotificationManager.shared.cancel(for: task)
        save(context: task.modelContext)
    }

    @MainActor
    private func handleSnooze(notificationID: String, seconds: TimeInterval) async {
        guard let task = fetchTask(notificationID: notificationID) else { return }

        let offsetSeconds = TimeInterval(task.reminderOffset * 60)
        task.scheduledTime = Date.now.addingTimeInterval(seconds + offsetSeconds)
        task.isCompleted = false
        task.originalScheduledTime = nil

        NotificationManager.shared.cancel(for: task)
        save(context: task.modelContext)
        await NotificationManager.shared.schedule(for: task)
    }

    @MainActor
    private func handleSnoozeTomorrow(notificationID: String) async {
        guard let task = fetchTask(notificationID: notificationID) else { return }

        guard let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: task.scheduledTime) else {
            logger.error("Failed to compute tomorrow's date for task '\(task.title)'")
            return
        }

        task.scheduledTime = tomorrow
        task.isCompleted = false
        task.originalScheduledTime = nil

        NotificationManager.shared.cancel(for: task)
        save(context: task.modelContext)
        await NotificationManager.shared.schedule(for: task)
    }

    // MARK: - Helpers

    @MainActor
    private func fetchTask(notificationID: String) -> DayTask? {
        let context = CueApp.sharedModelContainer.mainContext
        let descriptor = FetchDescriptor<DayTask>(
            predicate: #Predicate { $0.notificationID == notificationID }
        )
        do {
            return try context.fetch(descriptor).first
        } catch {
            logger.error("Failed to fetch task \(notificationID): \(error.localizedDescription)")
            return nil
        }
    }

    @MainActor
    private func save(context: ModelContext?) {
        guard let context else { return }
        do {
            try context.save()
        } catch {
            logger.error("Failed to save context: \(error.localizedDescription)")
        }
    }
}
