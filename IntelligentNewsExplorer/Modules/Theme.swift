import SwiftUI
import Combine

enum ThemePreference: String, CaseIterable, Identifiable {
    case system, light, dark
    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

@MainActor
final class ThemeManager: ObservableObject {
    @Published var preference: ThemePreference = .system {
        didSet {
            UserDefaults.standard.set(preference.rawValue, forKey: "themePreference")
        }
    }

    init() {
        if let raw = UserDefaults.standard.string(forKey: "themePreference"),
           let theme = ThemePreference(rawValue: raw) {
            self.preference = theme
        }
    }
    
    var isDark: Bool {
        return preference == .dark
    }
    
    func toggle() {
        self.preference = (self.preference == .dark) ? .light : .dark
    }
}
