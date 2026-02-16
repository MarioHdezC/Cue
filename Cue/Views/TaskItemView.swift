//
//  TaskItemView.swift
//  Cue
//
//  Created by Mario Hernández Corral on 15/2/26.
//

import SwiftUI
import SwiftData

struct TaskItemView: View {
    @Bindable var task: DayTask

    var body: some View {
        HStack(spacing: 12) {
            Button {
                task.isCompleted.toggle()
                if task.isCompleted {
                    NotificationManager.shared.cancel(for: task)
                } else {
                    Task { await NotificationManager.shared.schedule(for: task) }
                }
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(task.isCompleted ? .green : .secondary)
                    .font(.title3)
            }
            .buttonStyle(.borderless)

            Text(task.title)
                .strikethrough(task.isCompleted)
                .foregroundStyle(task.isCompleted ? .secondary : .primary)

            Spacer()

            Text(task.scheduledTime, format: .dateTime.hour().minute())
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
