import SwiftUI
import FoundationModels

struct SummaryMessageCardView: View {
    let summary: Summary.PartiallyGenerated
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 16) {
                Rectangle()
                    .fill(LinearGradient(colors: [Color.accentColor, Color.blue.opacity(0.7)], startPoint: .leading, endPoint: .trailing))
                    .frame(height: 6)
                    .clipShape(RoundedRectangle(cornerRadius: 3))
                    .padding(.bottom, 2)
                
                HStack(alignment: .center, spacing: 12) {
                    if let icon = summary.icon {
                        Text(icon)
                            .font(.system(size: 44))
                            .shadow(radius: 2)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        if let headline = summary.headline {
                            Text(headline)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                        }
                        if let summaryText = summary.summaryText {
                            Text(summaryText)
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .padding(.top, 2)
                        }
                    }
                }
                .padding(.bottom, 4)
                
                if let highlights = summary.highlights, !highlights.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("重點摘要")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.accentColor)
                        ForEach(highlights, id: \.self) { point in
                            HStack(alignment: .top, spacing: 8) {
                                Circle()
                                    .fill(Color.accentColor)
                                    .frame(width: 8, height: 8)
                                Text(point)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                if let callToAction = summary.callToAction {
                    HStack {
                        Spacer()
                        Text(callToAction)
                            .font(.footnote)
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 24)
                            .background(LinearGradient(colors: [Color.accentColor, Color.blue.opacity(0.7)], startPoint: .leading, endPoint: .trailing))
                            .clipShape(Capsule())
                            .shadow(radius: 2)
                        Spacer()
                    }
                    .padding(.top, 8)
                }
                
                Spacer(minLength: 0)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
            )
            // Summary 標籤
            Text("SUMMARY")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.accentColor)
                .clipShape(Capsule())
                .offset(x: 16, y: -12)
            // AI 角標
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text("AI 生成")
                        .font(.caption2)
                        .foregroundStyle(.gray)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.gray.opacity(0.08))
                        .clipShape(Capsule())
                        .padding(.trailing, 12)
                        .padding(.bottom, 8)
                }
            }
        }
        .padding(.vertical, 8)
    }
}
