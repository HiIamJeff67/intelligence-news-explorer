import SwiftUI
import UIKit
import SwiftData
import FirebaseAuth

struct AuthView: View {
    @Environment(AuthService.self) var authService
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.modelContext) private var modelContext
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    
    var body: some View {
        @Bindable var authService = authService
        
        NavigationStack {
            ZStack {
                Color(red: 186/255, green: 196/255, blue: 215/255)
                    .ignoresSafeArea()

                // Content
                VStack(spacing: 24) {
                    // App Icon
                    if let icon = Bundle.main.icon {
                        Image(uiImage: icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 32))
                    } else {
                        // Fallback if App Icon cannot be loaded
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .foregroundStyle(.primary)
                    }
                    
                    Text(isSignUp ? "Create Account" : "Welcome Back")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    
                    VStack(spacing: 15) {
                        TextField("Email", text: $email)
                            .padding()
                            .background(Color(uiColor: .secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                        
                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color(uiColor: .secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    if let error = authService.errorMessage {
                        Text(error)
                            .foregroundStyle(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }
                    
                    Button {
                        Task {
                            if isSignUp {
                                await authService.signUp(email: email, password: password)
                            } else {
                                await authService.signIn(email: email, password: password)
                            }
                        }
                    } label: {
                        if authService.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text(isSignUp ? "Sign Up" : "Sign In")
                                .fontWeight(.bold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .disabled(authService.isLoading)
                    
                    HStack {
                        Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                            .foregroundStyle(.secondary)
                        
                        Button {
                            withAnimation {
                                isSignUp.toggle()
                            }
                        } label: {
                            Text(isSignUp ? "Sign In" : "Sign Up")
                                .fontWeight(.bold)
                                .foregroundStyle(.blue)
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
            .navigationBarHidden(true)
            .alert("Error", isPresented: Binding(
                get: { authService.errorMessage != nil },
                set: { if !$0 { authService.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(authService.errorMessage ?? "")
            }
            .onChange(of: authService.user) { _, newUser in
                if let newUser = newUser {
                    let userProfile = UserProfile(id: newUser.uid, email: newUser.email ?? "")
                    modelContext.insert(userProfile)
                }
            }
        }
    }
}

// Helper to fetch App Icon
extension Bundle {
    var icon: UIImage? {
        if let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
           let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
           let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
           let lastIcon = iconFiles.last {
            return UIImage(named: lastIcon)
        }
        return nil
    }
}
