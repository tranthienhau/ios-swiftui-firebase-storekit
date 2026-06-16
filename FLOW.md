# Screenshot / demo regeneration flow

This repo ships as a SwiftPM SwiftUI module (no `.xcodeproj`). To run it on a
simulator and capture screenshots, generate a throwaway app target around the
existing sources.

1. Boot the simulator:

   ```bash
   xcrun simctl boot "iPhone 17 Pro"
   ```

2. Generate an app target with xcodegen (sources stay unchanged; an alternate
   `@main` entry is compiled in place of the real one so each screen can be
   routed to via a launch argument). Provide a `GoogleService-Info.plist` so
   `FirebaseApp.configure()` succeeds (the `API_KEY` must be exactly 39
   characters or Firebase 11 aborts at launch), and wire `Products.storekit`
   into both the Run and Test actions of the scheme.

3. Build and install:

   ```bash
   xcodebuild -project StoreKitPOC.xcodeproj -scheme StoreKitPOC \
     -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
     -derivedDataPath ./DerivedData build
   xcrun simctl install booted <built>.app
   ```

4. Capture the real screens. A small XCUITest launches the app, taps/types
   through the auth flow, and saves PNGs into `screenshots/` via
   `XCUIScreen.main.screenshot()`. Routes are selected with launch arguments
   (`-demoHome`, `-demoPaywall`).

   ```bash
   xcodebuild -project StoreKitPOC.xcodeproj -scheme StoreKitPOC \
     -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
     -derivedDataPath ./DerivedData test
   ```

5. Assemble the looping demo GIF:

   ```bash
   ffmpeg -y -framerate 0.8 -pattern_type glob -i 'screenshots/0*.png' \
     -vf "scale=400:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
     -loop 0 screenshots/demo.gif
   ```

Note: under headless `xcodebuild test`, the StoreKit test configuration is not
always activated, so the paywall may show its loading state rather than the
test product price rows. Running the app from Xcode's Run action (which honors
the scheme's StoreKit configuration) loads the Monthly / Yearly / Lifetime
products.
