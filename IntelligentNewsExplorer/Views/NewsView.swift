import SwiftUI
import SwiftData
import FirebaseAuth

struct NewsView: View {
    @EnvironmentObject var viewModel: NewsViewModel
    @Environment(\.modelContext) private var modelContext
    @Environment(AuthService.self) var authService
    @Query private var userProfiles: [UserProfile]
    
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            List(viewModel.searchResults) { article in
                Button {
                    logActivity(type: .articleView, metadata: article.title)
                    if let url = URL(string: article.url) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    ArticleRowView(article: article)
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
            .listStyle(.plain)
            .navigationTitle("News")
            .searchable(text: $searchText, prompt: "Search news")
            .onSubmit(of: .search) {
                Task {
                    await viewModel.searchArticles(query: searchText)
                }
            }
            .task {
                if viewModel.searchResults.isEmpty {
                    await viewModel.searchArticles(query: "")
                }
            }
        }
    }
    
    private func logActivity(type: ActivityType, metadata: String? = nil) {
        guard let userId = authService.user?.uid,
              let userProfile = userProfiles.first(where: { $0.id == userId }) else { return }
        
        let activity = UserActivity(type: type, metadata: metadata)
        userProfile.activities.append(activity)
    }
}
