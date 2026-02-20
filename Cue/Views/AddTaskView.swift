//
//  AddTaskView.swift
//  Cue
//
//  Created by Mario Hernández Corral on 15/2/26.
//

import os
import SwiftUI
import SwiftData

private let logger = Logger(subsystem: "com.mariohernandez.Cue", category: "Persistence")

struct AddTaskView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openWindow) private var openWindow
    @AppStorage("reminderOffset") private var reminderOffset = 15
    let selectedDate: Date
    @State private var title = ""
    @State private var selectedTime = Date.now

    var body: some View {
        HStack(spacing: 8) {
            TextField("New task...", text: $title)
                .textFieldStyle(.roundedBorder)
                .onSubmit(addTask)

            DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .frame(width: 80)

            Button(action: addTask) {
                Image(systemName: "plus.circle.fill")
                    .font(.title)
            }
            .buttonStyle(.borderless)
            .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
            
            Menu {
                Button("Settings...") {
                    openWindow(id: "settings")
                }
                Divider()
                Button("Quit Cue") {
                    NSApplication.shared.terminate(nil)
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.title3)
            }
            .menuStyle(.borderlessButton)
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

        let task = DayTask(title: taskTitle, scheduledTime: scheduledTime, reminderOffset: reminderOffset)
        modelContext.insert(task)
        do {
            try modelContext.save()
        } catch {
            logger.error("Failed to save task '\(taskTitle)': \(error.localizedDescription)")
        }

        Task {
            await NotificationManager.shared.schedule(for: task)
        }

        title = ""
    }
}
