# ios-swiftui-firebase-storekit

Native iOS SwiftUI POC bringing together the three pieces a production subscription app needs: **Firebase Auth** (email/password), **StoreKit 2** subscriptions with proper transaction verification and entitlement management, and a clean architecture you can ship.

## What it shows

- SwiftUI app structure with `@StateObject` view-models and `@EnvironmentObject` injection.
- Firebase email auth: sign-in, sign-up, email verification, password reset, auth-state listener.
- StoreKit 2:
  - Product loading via `Product.products(for:)`
  - Purchase with `VerificationResult` checked (`.verified` only)
  - `Transaction.currentEntitlements` walk to derive active subscription
  - `Transaction.updates` listener for renewals, refunds, Family Sharing
  - `AppStore.sync()` for restore purchases
- Subscription group with monthly + yearly + non-renewing lifetime in `Products.storekit` for offline testing.
- Paywall UI with auto-dismiss when entitlement becomes active.

## Stack

- SwiftUI, iOS 17+
- Swift Concurrency (`async/await`, `Task.detached`, `AsyncSequence`)
- Firebase Auth + Firebase Messaging (Swift Package Manager)
- StoreKit 2

## Run

1. Open in Xcode 15+ (create a new SwiftUI app and drop these sources in, or wrap with Package.swift).
2. Add `GoogleService-Info.plist` from your Firebase console.
3. Enable Email/Password sign-in in the Firebase console.
4. In Xcode scheme → Options → StoreKit Configuration, select `Products.storekit` for local subscription testing.
5. Build & run.

## Production checklist

- App Store Server Notifications v2 webhook for renewals + refunds.
- Backend verification of `JWSTransaction` with App Store Server API.
- App Tracking Transparency prompt before any 3rd-party analytics.
- Sign in with Apple alongside email per App Store guideline 4.8.

## Author

Built by Hau (`tranthienhau`).
