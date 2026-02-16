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

    private var filteredTasks: [DayTask] {
        allTasks.filter { Calendar.current.isDate($0.scheduledTime, inSameDayAs: selectedDate) }
    }

    private var headerTitle: String {
        if Calendar.current.isDateInToday(selectedDate) { return "Today" }
        if Calendar.current.isDateInYesterday(selectedDate) { return "Yesterday" }
        if Calendar.current.isDateInTomorrow(selectedDate) { return "Tomorrow" }
        let systemLocale = Locale(identifier: Locale.preferredLanguages.first ?? "en")
        return selectedDate.formatted(.dateTime.day().month(.wide).locale(systemLocale))
    }

    private var isToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate)!
                } label: {
                    Image(systemName: "chevron.left")
                }
                .buttonStyle(.borderless)

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
            }
            .padding()

            if !isToday {
                Button("Go to Today") {
                    selectedDate = .now
                }
                .buttonStyle(.borderless)
                .font(.caption)
                .padding(.bottom, 4)
            }

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
                    TaskItemView(task: task)
                        .contextMenu {
                            Button("Delete", role: .destructive) {
                                NotificationManager.shared.cancel(for: task)
                                modelContext.delete(task)
                            }
                        }
                }
            }
            AddTaskView(selectedDate: selectedDate)
        }
        .frame(width: 350, height: 400)
    }
}

#Preview {
    TaskListView()
}
