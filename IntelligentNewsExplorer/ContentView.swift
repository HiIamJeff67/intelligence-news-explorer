import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(AuthService.self) var authService
    @Query private var userProfiles: [UserProfile]
    
    var body: some View {
        if authService.user != nil {
            MainTabView()
        } else {
            AuthView()
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserProfile.self, UserActivity.self, configurations: config)
    
    return ContentView()
        .environment(AuthService())
        .environmentObject(ThemeManager())
        .modelContainer(container)
}
