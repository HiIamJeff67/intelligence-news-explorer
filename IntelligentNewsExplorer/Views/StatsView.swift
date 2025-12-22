import SwiftUI
import SwiftData
import Charts
import FirebaseAuth

struct StatsView: View {
    @Environment(AuthService.self) var authService
    @Query private var userProfiles: [UserProfile]
    
    var currentUserProfile: UserProfile? {
        guard let userId = authService.user?.uid else { return nil }
        return userProfiles.first { $0.id == userId }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if let profile = currentUserProfile {
                    let activities = profile.activities
                    let summaryCount = activities.filter { $0.type == .summary }.count
                    let viewCount = activities.filter { $0.type == .articleView }.count
                    
                    List {
                        Section("Overview") {
                            HStack {
                                Text("Total Summaries")
                                Spacer()
                                Text("\(summaryCount)")
                                    .bold()
                            }
                            HStack {
                                Text("Articles Read")
                                Spacer()
                                Text("\(viewCount)")
                                    .bold()
                            }
                        }
                        
                        Section("Activity Chart") {
                            if activities.isEmpty {
                                Text("No activity recorded yet.")
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding()
                            } else {
                                Chart {
                                    BarMark(
                                        x: .value("Type", "Summaries"),
                                        y: .value("Count", summaryCount)
                                    )
                                    .foregroundStyle(.purple)
                                    .annotation(position: .top) {
                                        Text("\(summaryCount)")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    BarMark(
                                        x: .value("Type", "Articles"),
                                        y: .value("Count", viewCount)
                                    )
                                    .foregroundStyle(.blue)
                                    .annotation(position: .top) {
                                        Text("\(viewCount)")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .frame(height: 200)
                                .padding(.vertical)
                            }
                        }
                        
                        Section("Recent Activity") {
                            if activities.isEmpty {
                                Text("No recent activity.")
                                    .foregroundStyle(.secondary)
                            } else {
                                ForEach(activities.sorted(by: { $0.timestamp > $1.timestamp }).prefix(20)) { activity in
                                    HStack {
                                        Image(systemName: activity.type == .summary ? "wand.and.stars" : "newspaper")
                                            .foregroundStyle(activity.type == .summary ? .purple : .blue)
                                            .frame(width: 24)
                                        
                                        VStack(alignment: .leading) {
                                            Text(activity.type == .summary ? "Generated Summary" : "Read Article")
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                            
                                            if let meta = activity.metadata {
                                                Text(meta)
                                                    .font(.caption)
                                                    .lineLimit(1)
                                                    .foregroundStyle(.secondary)
                                            }
                                            
                                            Text(activity.timestamp.formatted(date: .abbreviated, time: .shortened))
                                                .font(.caption2)
                                                .foregroundStyle(.tertiary)
                                        }
                                    }
                                }
                            }
                        }
                    }
                } else {
                    ContentUnavailableView("No Data", systemImage: "chart.bar", description: Text("Log in to see your stats."))
                }
            }
            .navigationTitle("Statistics")
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserProfile.self, UserActivity.self, configurations: config)
    
    return StatsView()
        .environment(AuthService())
        .modelContainer(container)
}
