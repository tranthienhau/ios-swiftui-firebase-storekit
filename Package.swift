// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SwiftUIFirebaseStoreKit",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "SwiftUIFirebaseStoreKit", targets: ["SwiftUIFirebaseStoreKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "11.0.0")
    ],
    targets: [
        .target(
            name: "SwiftUIFirebaseStoreKit",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk")
            ],
            path: ".",
            sources: ["App", "Auth", "Subscription", "Views"]
        )
    ]
)
