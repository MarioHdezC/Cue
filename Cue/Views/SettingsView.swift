//
//  SettingsView.swift
//  Cue
//
//  Created by Mario Hernández Corral on 16/2/26.
//

import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @AppStorage("reminderOffset") private var reminderOffset = 15
    @State private var launchAtLogin = false

    private let offsetOptions = [5, 10, 15, 30]

    var body: some View {
        Form {
            Picker("Notification", selection: $reminderOffset) {
                ForEach(offsetOptions, id: \.self) { minutes in
                    Text("\(minutes) minutes before")
                        .tag(minutes)
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
        .frame(width: 320, height: 120)
        .onAppear {
            launchAtLogin = SMAppService.mainApp.status == .enabled
        }
    }
}

#Preview {
    SettingsView()
}
