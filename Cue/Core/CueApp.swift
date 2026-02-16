//
//  CueApp.swift
//  Cue
//
//  Created by Mario Hernández Corral on 15/2/26.
//

import SwiftUI
import SwiftData

@main
struct CueApp: App {
    var body: some Scene {
        MenuBarExtra("Cue", systemImage: "checklist.checked") {
            TaskListView()
                .modelContainer(for: DayTask.self)
        }
        .menuBarExtraStyle(.window)
    }
}
