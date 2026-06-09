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
    @Binding var editingTaskID: String?
    @State private var editingTitle = ""
    @State private var editingTime = Date.now

    private var isEditing: Bool {
        editingTaskID == task.notificationID
    }

    var body: some View {
        HStack(spacing: 12) {
            if isEditing {
                editingContent
            } else {
                readOnlyContent
            }
        }
        .padding(.vertical, 4)
        .onTapGesture(count: 2) {
            startEditing()
        }
        .onChange(of: editingTaskID) {
            if editingTaskID == task.notificationID {
                editingTitle = task.title
                editingTime = task.scheduledTime
            }
        }
    }

    // MARK: - Read-only mode

    private var readOnlyContent: some View {
        Group {
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
            .accessibilityLabel(task.isCompleted ? "Mark as pending" : "Mark as completed")

            Text(task.title)
                .strikethrough(task.isCompleted)
                .foregroundStyle(task.isCompleted ? .secondary : .primary)

            Spacer()

            if let badge = task.overdueBadge {
                Text(badge)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("·")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(task.scheduledTime, format: .dateTime.hour().minute())
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .accessibilityLabel(String(localized: "Overdue from yesterday"))
            } else {
                Text(task.scheduledTime, format: .dateTime.hour().minute())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Editing mode

    private var editingContent: some View {
        Group {
            TextField("", text: $editingTitle)
                .textFieldStyle(.roundedBorder)
                .onSubmit { saveEdit() }
                .onExitCommand { cancelEdit() }

            DatePicker("", selection: $editingTime, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .frame(width: 80)

            Button { saveEdit() } label: {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.title3)
            }
            .buttonStyle(.borderless)
            .accessibilityLabel("Save changes")

            Button { cancelEdit() } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
                    .font(.title3)
            }
            .buttonStyle(.borderless)
            .accessibilityLabel("Cancel editing")
        }
    }

    // MARK: - Actions

    private func startEditing() {
        editingTitle = task.title
        editingTime = task.scheduledTime
        editingTaskID = task.notificationID
    }

    private func saveEdit() {
        let trimmed = editingTitle.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        NotificationManager.shared.cancel(for: task)

        task.title = trimmed
        task.scheduledTime = Calendar.current.date(
            bySettingHour: Calendar.current.component(.hour, from: editingTime),
            minute: Calendar.current.component(.minute, from: editingTime),
            second: 0,
            of: task.scheduledTime
        ) ?? editingTime

        Task { await NotificationManager.shared.schedule(for: task) }

        editingTaskID = nil
    }

    private func cancelEdit() {
        editingTaskID = nil
    }
}
