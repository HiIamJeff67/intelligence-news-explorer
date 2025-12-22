import SwiftUI
import SafariServices
import FoundationModels
import SwiftData
import FirebaseAuth

struct TodayNewsView: View {
    @EnvironmentObject var viewModel: NewsViewModel
    @Environment(\.modelContext) private var modelContext
    @Environment(AuthService.self) var authService
    @Query private var userProfiles: [UserProfile]
    
    @State private var summary: String = ""
    @State private var isSummarizing = false
    @State private var errorMessage: String?
    @State private var showError = false
    
    private var model = SystemLanguageModel.default
    
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
                    Button("Summary") {
                        summarizeNews()
                    }
                    .disabled(isSummarizing || viewModel.topHeadlines.isEmpty)
                }
            }
            .overlay {
                if isSummarizing {
                    ProgressView("Summarizing...")
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                }
            }
            .sheet(isPresented: Binding(get: { !summary.isEmpty }, set: { if !$0 { summary = "" } })) {
                ScrollView {
                    Text(summary)
                        .padding()
                }
                .presentationDetents([.medium, .large])
            }
            .alert("AI Summary Unavailable", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "Unknown error")
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
    
    func summarizeNews() {
        print("Checking model availability: \(model.availability)")
        
        // Check availability first
        switch model.availability {
        case .available:
            print("Model is available. Starting session...")
            break // Continue
        case .unavailable(let reason):
            var reasonMsg = "Unknown reason"
            switch reason {
            case .deviceNotEligible:
                reasonMsg = "Device not eligible (裝置不支援)"
            case .appleIntelligenceNotEnabled:
                reasonMsg = "Apple Intelligence not enabled (未啟用 Apple Intelligence)。\n請注意：目前 Apple Intelligence 僅支援 English (United States)。請檢查模擬器的 Settings > Apple Intelligence & Siri > Language 是否設為 English (United States)。"
            case .modelNotReady:
                reasonMsg = "Model not ready (模型正在下載或準備中)"
            @unknown default:
                reasonMsg = "Unavailable (無法使用)"
            }
            self.errorMessage = "Local AI Unavailable: \(reasonMsg)"
            self.showError = true
            return
        @unknown default:
            self.errorMessage = "Local AI status unknown (狀態未知)"
            self.showError = true
            return
        }

        isSummarizing = true
        Task {
            do {
                let headlines = viewModel.topHeadlines.prefix(10).map { $0.title }.joined(separator: "\n- ")
                let prompt = "Summarize the following news headlines into key points:\n- \(headlines)"
                
                let session = LanguageModelSession()
                let response = try await session.respond(to: prompt)
                
                await MainActor.run {
                    self.summary = response.content
                    self.isSummarizing = false
                    self.logActivity(type: .summary)
                }
            } catch {
                print("Error summarizing: \(error)")
                await MainActor.run {
                    // Check for specific asset error
                    if error.localizedDescription.contains("assetsUnavailable") {
                        self.errorMessage = "Model assets are missing. The system is likely still downloading the model. Please wait and try again later.\n(模型資源缺失，系統可能仍在下載模型，請稍後再試)"
                    } else {
                        self.errorMessage = "Failed to generate summary: \(error.localizedDescription)"
                    }
                    self.showError = true
                    self.isSummarizing = false
                }
            }
        }
    }
}
