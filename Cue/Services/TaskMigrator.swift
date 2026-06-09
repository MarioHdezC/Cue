//
//  TaskMigrator.swift
//  Cue
//
//  Created by Mario Hernández Corral on 9/6/26.
//

import Foundation
import SwiftData
import os

final class TaskMigrator {
    static let shared = TaskMigrator()

    private let logger = Logger(subsystem: "com.mariohernandez.Cue", category: "TaskMigrator")

    private init() {}

    @MainActor
    func migrateOverdueTasks(in context: ModelContext) {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date.now)
        let startOfYesterday = calendar.startOfDay(for: calendar.date(byAdding: .day, value: -1, to: Date.now)!)

        let descriptor = FetchDescriptor<DayTask>(
            predicate: #Predicate { !$0.isCompleted && $0.scheduledTime >= startOfYesterday && $0.scheduledTime < startOfToday }
        )

        let overdueTasks: [DayTask]
        do {
            overdueTasks = try context.fetch(descriptor)
        } catch {
            logger.error("Failed to fetch overdue tasks: \(error.localizedDescription)")
            return
        }

        guard !overdueTasks.isEmpty else { return }

        for task in overdueTasks {
            task.originalScheduledTime = task.scheduledTime

            let timeComponents = calendar.dateComponents([.hour, .minute], from: task.scheduledTime)
            task.scheduledTime = calendar.date(
                bySettingHour: timeComponents.hour ?? 0,
                minute: timeComponents.minute ?? 0,
                second: 0,
                of: Date.now
            ) ?? Date.now

            NotificationManager.shared.cancel(for: task)

            logger.info("Migrated overdue task '\(task.title)' to today")
        }

        do {
            try context.save()
        } catch {
            logger.error("Failed to save migrated tasks: \(error.localizedDescription)")
        }
    }
}