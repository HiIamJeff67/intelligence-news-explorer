import SwiftUI

struct MessageView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if message.role == .assistant {
                Image(systemName: "sparkles")
                    .foregroundStyle(.indigo)
                    .font(.title3)
                    .padding(.top, 4)
            } else {
                Spacer()
            }
            
            VStack(alignment: message.role == .user ? .trailing : .leading) {
                if message.role == .assistant {
                    Text(LocalizedStringKey(message.content))
                        .textSelection(.enabled)
                } else {
                    Text(message.content)
                        .padding(12)
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
            
            if message.role == .user {
                Image(systemName: "person.circle.fill")
                    .foregroundStyle(.gray)
                    .font(.title3)
                    .padding(.top, 4)
            } else {
                Spacer()
            }
        }
    }
}
