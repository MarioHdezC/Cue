//
//  TaskListView.swift
//  Cue
//
//  Created by Mario Hernández Corral on 15/2/26.
//

import SwiftUI
import SwiftData

struct TaskListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DayTask.scheduledTime) private var allTasks: [DayTask]
    @State private var selectedDate: Date = .now
    @State private var editingTaskID: String?
    @State private var taskToDelete: DayTask?

    private var filteredTasks: [DayTask] {
        allTasks.filter { Calendar.current.isDate($0.scheduledTime, inSameDayAs: selectedDate) }
    }

    private var headerTitle: LocalizedStringKey {
        if Calendar.current.isDateInToday(selectedDate) { return "Today" }
        if Calendar.current.isDateInYesterday(selectedDate) { return "Yesterday" }
        if Calendar.current.isDateInTomorrow(selectedDate) { return "Tomorrow" }
        let systemLocale = Locale(identifier: Locale.preferredLanguages.first ?? "en")
        return "\(selectedDate.formatted(.dateTime.day().month(.wide).locale(systemLocale)))"
    }

    private var isToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }

    var body: some View {
        VStack(spacing: 0) {
            dateNavigationHeader
            goToTodayButton
            taskListContent
            AddTaskView(selectedDate: selectedDate)
        }
        .frame(width: 350, height: 400)
    }

    // MARK: - Subviews

    private var dateNavigationHeader: some View {
        HStack {
            Button {
                selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate)!
            } label: {
                Image(systemName: "chevron.left")
            }
            .buttonStyle(.borderless)
            .accessibilityLabel("Previous day")

            Spacer()

            Text(headerTitle)
                .font(.headline)

            Spacer()

            Button {
                selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate)!
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.borderless)
            .accessibilityLabel("Next day")
        }
        .padding()
    }

    @ViewBuilder
    private var goToTodayButton: some View {
        if !isToday {
            Button("Go to Today") {
                selectedDate = .now
            }
            .buttonStyle(.borderless)
            .font(.caption)
            .padding(.bottom, 4)
        }
    }

    @ViewBuilder
    private var taskListContent: some View {
        if filteredTasks.isEmpty {
            Spacer()
            ContentUnavailableView(
                "No tasks",
                systemImage: "checklist",
                description: Text("Add a task to get started")
            )
            Spacer()
        } else {
            List(filteredTasks) { task in
                if taskToDelete?.notificationID == task.notificationID {
                    deleteConfirmationRow(for: task)
                } else {
                    taskRow(for: task)
                }
            }
        }
    }
    
    // MARK: - Private functions

    private func deleteConfirmationRow(for task: DayTask) -> some View {
        HStack {
            Text("Delete this task?")
                .font(.body)
                .foregroundStyle(.secondary)
            Spacer()
            Button("Delete", role: .destructive) {
                NotificationManager.shared.cancel(for: task)
                modelContext.delete(task)
                taskToDelete = nil
            }
            .buttonStyle(.borderless)
            .foregroundStyle(.red)
            Button("Cancel") {
                taskToDelete = nil
            }
            .buttonStyle(.borderless)
        }
        .padding(.vertical, 4)
    }

    private func taskRow(for task: DayTask) -> some View {
        TaskItemView(task: task, editingTaskID: $editingTaskID)
            .contextMenu {
                Button("Edit") {
                    editingTaskID = task.notificationID
                }
                Button("Delete", role: .destructive) {
                    taskToDelete = task
                }
            }
    }
}

#Preview {
    TaskListView()
}
