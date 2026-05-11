import Foundation
import StoreKit

@MainActor
final class SubscriptionViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var activeEntitlement: Product.SubscriptionInfo.RenewalState?
    @Published var activeProductID: String?
    @Published var isPurchasing = false
    @Published var errorMessage: String?

    private let productIDs = [
        "app.poc.subscription.monthly",
        "app.poc.subscription.yearly",
        "app.poc.subscription.lifetime"
    ]

    private var listenerTask: Task<Void, Never>?

    func loadProducts() async {
        do {
            let storeProducts = try await Product.products(for: productIDs)
            self.products = storeProducts.sorted { $0.price < $1.price }
        } catch {
            self.errorMessage = "Failed to load products: \(error.localizedDescription)"
        }
    }

    func purchase(_ product: Product) async {
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await refreshEntitlements()
                await transaction.finish()
            case .userCancelled:
                break
            case .pending:
                errorMessage = "Purchase pending parental approval or SCA."
            @unknown default:
                break
            }
        } catch {
            errorMessage = "Purchase failed: \(error.localizedDescription)"
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await refreshEntitlements()
        } catch {
            errorMessage = "Restore failed: \(error.localizedDescription)"
        }
    }

    /// Walk Transaction.currentEntitlements to derive active subscription.
    /// In production also verify with App Store Server API on the backend.
    func refreshEntitlements() async {
        var activeID: String?
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            if transaction.revocationDate == nil {
                activeID = transaction.productID
            }
        }
        self.activeProductID = activeID

        if let activeID,
           let product = products.first(where: { $0.id == activeID }),
           let status = try? await product.subscription?.status.first {
            self.activeEntitlement = status.state
        } else {
            self.activeEntitlement = nil
        }
    }

    /// Background listener for transactions outside the purchase flow
    /// (renewals, Family Sharing, refunds, ask-to-buy approvals).
    func listenForTransactions() {
        listenerTask?.cancel()
        listenerTask = Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard case .verified(let transaction) = result else { continue }
                await self?.refreshEntitlements()
                await transaction.finish()
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified: throw StoreError.failedVerification
        case .verified(let safe): return safe
        }
    }

    enum StoreError: Error { case failedVerification }

    var hasActiveSubscription: Bool { activeProductID != nil }
}
