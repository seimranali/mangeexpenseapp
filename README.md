# Household Ledger

A modern, elegant Flutter app (iOS + Android) for tracking household spending:
Household, Water, Gas, Internet, Fuel, Electricity, Mobile, Education, Local
Traveling, Charity, Gifts, and Cash to Person. Data is synced per-account via
Firebase (Firestore + Auth), with monthly budgets and spend charts.

## Tech stack

- **Flutter** (Material 3, Google Fonts "Manrope", light/dark themes)
- **Firebase**: Auth (email/password + Google Sign-In) and Cloud Firestore
- **Riverpod** for state management
- **go_router** for navigation, with an auth-aware redirect guard
- **fl_chart** for the dashboard pie chart and reports trend chart

## Project structure

```
lib/
  core/           theme, category constants, formatters, router
  data/
    models/       Entry, Budget, UserProfile (Firestore <-> Dart)
    repositories/ Firestore/Auth access (AuthRepository, EntryRepository, BudgetRepository)
  providers/       Riverpod providers wiring repositories to streams
  features/
    auth/          sign in / sign up
    dashboard/      monthly overview, pie chart, category list
    entries/        add/edit entry, per-category entry list
    budgets/        monthly budget per category with progress bars
    reports/        6-month trend + this month's category breakdown
    settings/        theme toggle, sign out
  widgets/          shared UI (category avatar, section card, nav shell)
firestore.rules      security rules restricting each user to their own data
```

Every category lives in `lib/core/constants/categories.dart` — add or rename
a category there and it automatically appears in the picker, dashboard,
budgets, and reports.

## 1. Set up Firebase (one-time)

1. Go to the [Firebase console](https://console.firebase.google.com/) and
   create a new project (Google Analytics is optional).
2. In **Build → Authentication → Sign-in method**, enable:
   - **Email/Password**
   - **Google**
3. In **Build → Firestore Database**, click **Create database** and start in
   **production mode** (the rules below lock it down).
4. Install the FlutterFire CLI if you don't have it, then log in:
   ```
   dart pub global activate flutterfire_cli
   firebase login
   ```
5. From this project's root directory, run:
   ```
   flutterfire configure
   ```
   Select the Firebase project you just created, and choose **android** and
   **ios** as platforms. This overwrites the placeholder
   `lib/firebase_options.dart` with your real project credentials, registers
   the Android app (writes `android/app/google-services.json`) and the iOS
   app (writes `ios/Runner/GoogleService-Info.plist`), and wires up the
   necessary Gradle plugin.
6. Deploy the security rules so users can only read/write their own data:
   ```
   firebase deploy --only firestore:rules
   ```
   (or paste the contents of `firestore.rules` into the Firestore console's
   Rules tab and publish).

### Google Sign-In on iOS

After running `flutterfire configure`, open `ios/Runner/GoogleService-Info.plist`
and copy the `REVERSED_CLIENT_ID` value. Add it as a URL scheme in
`ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>PASTE_REVERSED_CLIENT_ID_HERE</string>
    </array>
  </dict>
</array>
```

## 2. Run the app (Android)

```
flutter pub get
flutter run
```

An emulator or a device with USB debugging works out of the box.

## 3. Build for iOS via Codemagic

iOS apps can only be compiled and signed with Xcode, which only runs on
macOS. If you don't have a Mac, [Codemagic](https://codemagic.io) builds it
for you on their macOS machines from this repo — nothing needs to be
installed locally. This repo already includes `codemagic.yaml` with two
workflows:

- **`ios-simulator-debug`** — unsigned build, good for a quick sanity check
  that the app compiles. No Apple Developer account needed.
- **`ios-release`** — signed release build, auto-published to TestFlight.
  Requires an Apple Developer Program account.

### One-time Codemagic setup

1. Push this repo to GitHub (or GitLab/Bitbucket).
2. Sign up at [codemagic.io](https://codemagic.io) and connect that git
   provider, then add this repository as an app — Codemagic will detect
   `codemagic.yaml` automatically.
3. In **App Store Connect** (under your Apple Developer account):
   - **Users and Access → Integrations → App Store Connect API** → generate
     a new API key with the **App Manager** role. Note the Issuer ID, Key ID,
     and download the `.p8` file (you only get one download).
   - Create the app record itself (**My Apps → +**) using bundle ID
     `com.householdledger.household_ledger`, if it doesn't already exist.
4. In Codemagic, go to **Team settings → Integrations → App Store Connect**
   and add a new integration using the Issuer ID, Key ID, and `.p8` file from
   step 3. This lets `ios-release` fetch signing certificates/profiles and
   publish to TestFlight automatically — no manual certificate management.
5. Push to your `main` branch (or trigger a build manually in the Codemagic
   dashboard) to start a build.

Change `BUNDLE_ID` in `codemagic.yaml` first if you rename the app's bundle
identifier (see the note below).

## 4. Install the build on your iPhone (TestFlight)

`ios-release` uploads every build straight to TestFlight, which is the
normal way to run your own signed builds on a real device without a Mac or
a USB cable.

1. In **App Store Connect → your app → TestFlight**, create an **Internal
   Testing** group named exactly `Internal Testers` (matching
   `beta_groups` in `codemagic.yaml`), and add your own Apple ID to it.
   Internal testing needs no Apple review and testers see new builds within
   minutes of upload.
2. Trigger the `ios-release` workflow in Codemagic (push to `main`, or run
   it manually from the dashboard). It builds, signs, and uploads to
   TestFlight — watch the build log for the upload step to confirm success.
3. Processing in App Store Connect usually takes 5–15 minutes after upload
   (shows as "Processing" on the TestFlight tab, then flips to ready).
4. On your iPhone, install **TestFlight** from the App Store, sign in with
   the same Apple ID you added as a tester, and open it — Household Ledger
   should appear there. Tap **Install**.
5. Every future push to `main` produces a new build number automatically
   (via `app-store-connect get-latest-testflight-build-number` in the
   build script) and lands in the same TestFlight group, so reinstalling is
   just opening TestFlight and tapping **Update**.

TestFlight builds expire after 90 days, so you'll need a fresh build/upload
periodically even without code changes — pushing an empty commit to `main`
is enough to trigger one.

## Notes

- `android/app/build.gradle.kts` sets `minSdk = 23` and
  `ios/Runner.xcodeproj` sets `IPHONEOS_DEPLOYMENT_TARGET = 13.0` — both are
  required by current Firebase SDKs.
- The app package/bundle id is `com.householdledger.household_ledger`. Change
  it via `flutter pub run change_app_package_name:main <new.id>` (or manually
  in Gradle/Xcode) before publishing, and re-run `flutterfire configure` so
  Firebase's app registration matches.
- Until `flutterfire configure` is run, `lib/firebase_options.dart` contains
  placeholder values and the app will fail to connect to Firebase — this is
  expected on a fresh clone.
