import SwiftUI

struct MainTabView: View {
    @StateObject private var viewModel = NewsViewModel()
    
    var body: some View {
        TabView {
            TodayNewsView()
                .tabItem {
                    Label("Today", systemImage: "newspaper")
                }
            
            NewsView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            
            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.xaxis")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .environmentObject(viewModel)
    }
}
