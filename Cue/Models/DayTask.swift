//
//  DayTask.swift
//  Cue
//
//  Created by Mario Hernández Corral on 15/2/26.
//

import Foundation
import SwiftData

@Model
final class DayTask {
    var title: String
    var scheduledTime: Date
    var reminderOffset: Int
    var isCompleted: Bool
    var notificationID: String
    var createdAt: Date
    var originalScheduledTime: Date?

    init(
        title: String,
        scheduledTime: Date,
        reminderOffset: Int = 15,
        isCompleted: Bool = false,
        notificationID: String = UUID().uuidString,
        createdAt: Date = .now,
        originalScheduledTime: Date? = nil
    ) {
        self.title = title
        self.scheduledTime = scheduledTime
        self.reminderOffset = reminderOffset
        self.isCompleted = isCompleted
        self.notificationID = notificationID
        self.createdAt = createdAt
        self.originalScheduledTime = originalScheduledTime
    }

    var isOverdue: Bool {
        originalScheduledTime != nil
    }

    var overdueBadge: String? {
        guard originalScheduledTime != nil else { return nil }
        return String(localized: "Yesterday")
    }
}
