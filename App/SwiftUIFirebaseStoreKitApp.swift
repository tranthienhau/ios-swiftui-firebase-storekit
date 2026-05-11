import SwiftUI
import FirebaseCore

@main
struct SwiftUIFirebaseStoreKitApp: App {
    @StateObject private var authVM = AuthViewModel()
    @StateObject private var subscriptionVM = SubscriptionViewModel()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authVM)
                .environmentObject(subscriptionVM)
                .task {
                    await subscriptionVM.loadProducts()
                    await subscriptionVM.refreshEntitlements()
                    subscriptionVM.listenForTransactions()
                }
        }
    }
}
