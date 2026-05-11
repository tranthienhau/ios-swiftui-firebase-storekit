import SwiftUI
import StoreKit

struct PaywallView: View {
    @EnvironmentObject var sub: SubscriptionViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(.yellow)
                Text("Unlock Pro")
                    .font(.largeTitle.bold())
                Text("Full access. Cancel anytime.")
                    .foregroundStyle(.secondary)

                if sub.products.isEmpty {
                    ProgressView().padding(.vertical, 20)
                } else {
                    ForEach(sub.products) { product in
                        ProductRow(product: product)
                    }
                }

                if let error = sub.errorMessage {
                    Text(error).foregroundStyle(.red).font(.caption)
                }

                Button("Restore purchases") {
                    Task { await sub.restorePurchases() }
                }
                .font(.footnote)
                Spacer()
            }
            .padding()
            .navigationTitle("Subscribe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .onChange(of: sub.hasActiveSubscription) { _, active in
                if active { dismiss() }
            }
        }
    }
}

struct ProductRow: View {
    let product: Product
    @EnvironmentObject var sub: SubscriptionViewModel

    var body: some View {
        Button {
            Task { await sub.purchase(product) }
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(product.displayName).font(.headline)
                    Text(product.description).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Text(product.displayPrice).font(.headline)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .disabled(sub.isPurchasing)
    }
}
