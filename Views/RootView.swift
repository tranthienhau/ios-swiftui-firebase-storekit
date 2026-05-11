import SwiftUI

struct RootView: View {
    @EnvironmentObject var auth: AuthViewModel

    var body: some View {
        if auth.isAuthenticated {
            HomeView()
        } else {
            AuthView()
        }
    }
}

struct AuthView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.tint)
                    .padding(.top, 32)

                Text(isSignUp ? "Create account" : "Welcome back")
                    .font(.title.bold())

                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()

                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)

                if let error = auth.errorMessage {
                    Text(error).foregroundStyle(.red).font(.caption)
                }

                Button {
                    Task {
                        if isSignUp {
                            await auth.signUp(email: email, password: password)
                        } else {
                            await auth.signIn(email: email, password: password)
                        }
                    }
                } label: {
                    if auth.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text(isSignUp ? "Sign up" : "Sign in")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(email.isEmpty || password.isEmpty || auth.isLoading)

                Button(isSignUp ? "Have an account? Sign in" : "New here? Create account") {
                    isSignUp.toggle()
                    auth.errorMessage = nil
                }
                .font(.callout)

                if !isSignUp {
                    Button("Forgot password?") {
                        Task { await auth.sendPasswordReset(email: email) }
                    }
                    .font(.caption)
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Firebase Auth")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct HomeView: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var sub: SubscriptionViewModel
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            List {
                Section("Account") {
                    LabeledContent("Email", value: auth.user?.email ?? "-")
                    LabeledContent("Verified",
                                   value: auth.user?.isEmailVerified == true ? "Yes" : "No")
                }

                Section("Subscription") {
                    if sub.hasActiveSubscription {
                        Label("Active: \(sub.activeProductID ?? "")",
                              systemImage: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                    } else {
                        Button("Upgrade to Pro") { showPaywall = true }
                    }
                    Button("Restore purchases") {
                        Task { await sub.restorePurchases() }
                    }
                }

                Section {
                    Button("Sign out", role: .destructive) { auth.signOut() }
                }
            }
            .navigationTitle("Home")
            .sheet(isPresented: $showPaywall) { PaywallView() }
        }
    }
}
