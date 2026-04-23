//
//  CueApp.swift
//  Cue
//
//  Created by Mario Hernández Corral on 15/2/26.
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct CueApp: App {
    static let sharedModelContainer: ModelContainer = {
        do {
            return try ModelContainer(for: DayTask.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()

    init() {
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        NotificationManager.shared.registerCategories()
    }

    var body: some Scene {
        MenuBarExtra("Cue", systemImage: "checklist") {
            TaskListView()
                .modelContainer(Self.sharedModelContainer)
                .task {
                    _ = await NotificationManager.shared.requestAuthorization()
                }
        }
        .menuBarExtraStyle(.window)

        Window("Settings", id: "settings") {
            SettingsView()
                .modelContainer(Self.sharedModelContainer)
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
    }
}
