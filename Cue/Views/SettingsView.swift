//
//  SettingsView.swift
//  Cue
//
//  Created by Mario Hernández Corral on 16/2/26.
//

import SwiftUI
import ServiceManagement
import UserNotifications

struct SettingsView: View {
    @AppStorage("reminderOffset") private var reminderOffset = 15
    @State private var launchAtLogin = false
    @State private var notificationsDisabled = false

    private let offsetOptions = [5, 10, 15, 30]

    var body: some View {
        Form {
            Picker("Notification", selection: $reminderOffset) {
                ForEach(offsetOptions, id: \.self) { minutes in
                    Text("\(minutes) minutes before")
                        .tag(minutes)
                }
            }

            if notificationsDisabled {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.yellow)
                    Text("Notifications are disabled.")
                        .font(.caption)
                    Spacer()
                    Button("Open Settings") {
                        if let bundleId = Bundle.main.bundleIdentifier,
                           let url = URL(string: "x-apple.systempreferences:com.apple.Notifications-Settings?id=\(bundleId)") {
                            NSWorkspace.shared.open(url)
                        }
                    }
                    .font(.caption)
                    .buttonStyle(.borderless)
                }
            }

            Toggle("Launch at login", isOn: $launchAtLogin)
                .onChange(of: launchAtLogin) { _, newValue in
                    do {
                        if newValue {
                            try SMAppService.mainApp.register()
                        } else {
                            try SMAppService.mainApp.unregister()
                        }
                    } catch {
                        launchAtLogin = !newValue
                    }
                }
        }
        .formStyle(.grouped)
        .frame(width: 320, height: notificationsDisabled ? 170 : 120)
        .onAppear {
            launchAtLogin = SMAppService.mainApp.status == .enabled
        }
        .task {
            await checkNotificationStatus()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            Task { await checkNotificationStatus() }
        }
    }
    
    // MARK: - Private functions
    
    private func checkNotificationStatus() async {
        let status = await NotificationManager.shared.authorizationStatus()
        notificationsDisabled = status == .denied
    }
}

#Preview {
    SettingsView()
}
