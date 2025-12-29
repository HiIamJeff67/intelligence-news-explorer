import SwiftUI
import FoundationModels
import Combine
import Observation
import SwiftData

struct NewsChatView: View {
    @StateObject private var viewModel: ChatViewModel
    @FocusState private var isInputFocused: Bool
    
    init(articles: [Article], initialSummary: String) {
        _viewModel = StateObject(wrappedValue: ChatViewModel(articles: articles, initialSummary: initialSummary))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        ForEach(viewModel.messages) { message in
                            MessageView(message: message)
                                .id(message.id)
                        }
                        
                        if viewModel.isLoading {
                            TypingIndicator()
                                .padding(.leading, 12)
                                .padding(.vertical, 8)
                                .id("typingIndicator")
                        }
                        
                        if let error = viewModel.errorMessage {
                            Text("Error: \(error)")
                                .foregroundStyle(.red)
                                .font(.caption)
                                .padding()
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.messages) { _, messages in
                    if let lastId = messages.last?.id {
                        withAnimation {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                }
            }
            
            VStack(spacing: 0) {
                Divider()
                HStack(alignment: .bottom, spacing: 12) {
                    TextField("Ask about the news...", text: $viewModel.input, axis: .vertical)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color(uiColor: .secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .focused($isInputFocused)
                        .lineLimit(1...5)
                    
                    Button {
                        Task {
                            await viewModel.sendMessage()
                        }
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(viewModel.input.isEmpty ? Color.gray.opacity(0.5) : Color.blue)
                    }
                    .disabled(viewModel.input.isEmpty || viewModel.isLoading)
                    .padding(.bottom, 4)
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(.bar)
            }
        }
        .navigationTitle("AI Summary & Chat")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TypingIndicator: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .frame(width: 6, height: 6)
                    .foregroundStyle(.secondary)
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .opacity(isAnimating ? 1.0 : 0.5)
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever()
                        .delay(Double(index) * 0.2),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}
