import SwiftUI
import SafariServices
import SwiftData
import FirebaseAuth
import TipKit

struct TodayNewsView: View {
    @EnvironmentObject var viewModel: NewsViewModel
    @Environment(\.modelContext) private var modelContext
    @Environment(AuthService.self) var authService
    @Query private var userProfiles: [UserProfile]
    @State private var showSummaryView = false
    
    private let summaryTip = SummaryTip()
    
    var body: some View {
        NavigationStack {
            List(viewModel.topHeadlines) { article in
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
            .navigationTitle("Today's News")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        summaryTip.invalidate(reason: .actionPerformed)
                        Task {
                            await viewModel.summarizeHeadlines()
                            if !viewModel.summary.isEmpty {
                                logActivity(type: .summary)
                                showSummaryView = true
                            }
                        }
                    } label: {
                        Image(systemName: "wand.and.stars")
                    }
                    .disabled(viewModel.isSummarizing || viewModel.topHeadlines.isEmpty)
                    .popoverTip(summaryTip, arrowEdge: .top)
                }
            }
            .navigationDestination(isPresented: $showSummaryView) {
                NewsChatView(
                    articles: Array(viewModel.topHeadlines.prefix(10)),
                    initialSummary: viewModel.summary
                )
            }
            .overlay {
                if viewModel.isSummarizing {
                    ProgressView("Summarizing...")
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                }
            }
            .alert("AI Summary Unavailable", isPresented: $viewModel.showAIError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.aiErrorMessage ?? "Unknown error")
            }
        }
        .task {
            await viewModel.loadTopHeadlines()
        }
    }
    
    private func logActivity(type: ActivityType, metadata: String? = nil) {
        guard let userId = authService.user?.uid,
              let userProfile = userProfiles.first(where: { $0.id == userId }) else { return }
        
        let activity = UserActivity(type: type, metadata: metadata)
        userProfile.activities.append(activity)
    }
}
