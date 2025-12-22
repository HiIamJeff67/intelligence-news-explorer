import SwiftUI
import UIKit
import FirebaseAuth

struct SettingsView: View {
    @Environment(AuthService.self) var authService
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Account") {
                    if let email = authService.user?.email {
                        Text(email)
                            .foregroundStyle(.secondary)
                    }
                    
                    Button("Sign Out", role: .destructive) {
                        authService.signOut()
                    }
                }

                Section("Appearance") {
                    Picker("Theme", selection: $themeManager.preference) {
                        ForEach(ThemePreference.allCases) { theme in
                            Text(theme.displayName).tag(theme)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("About") {
                    Text("IntelligentNewsExplorer v1.0")
                }
            }
            .navigationTitle("Settings")
        }
    }
}
