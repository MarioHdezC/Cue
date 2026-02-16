//
//  AddTaskView.swift
//  Cue
//
//  Created by Mario Hernández Corral on 15/2/26.
//

import SwiftUI
import SwiftData

struct AddTaskView: View {
    @Environment(\.modelContext) private var modelContext
    let selectedDate: Date
    @State private var title = ""
    @State private var selectedTime = Date.now

    var body: some View {
        HStack(spacing: 8) {
            TextField("Nueva tarea...", text: $title)
                .textFieldStyle(.roundedBorder)
                .onSubmit(addTask)

            DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .frame(width: 90)

            Button(action: addTask) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
            }
            .buttonStyle(.borderless)
            .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding()
    }

    private func addTask() {
        let taskTitle = title.trimmingCharacters(in: .whitespaces)
        guard !taskTitle.isEmpty else { return }

        let scheduledTime = Calendar.current.date(
            bySettingHour: Calendar.current.component(.hour, from: selectedTime),
            minute: Calendar.current.component(.minute, from: selectedTime),
            second: 0,
            of: selectedDate
        ) ?? selectedTime

        let task = DayTask(title: taskTitle, scheduledTime: scheduledTime)
        modelContext.insert(task)
        try? modelContext.save()

        Task {
            await NotificationManager.shared.schedule(for: task)
        }

        title = ""
    }
}
