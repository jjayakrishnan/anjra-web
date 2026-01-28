# 🚀 Master Deployment Guide for Anjra

**Final Checklist for Release v1.0.0**

## 🟢 Android (Google Play Store)

### 1. Build the App Bundle
Your app needs to be packaged as an `.aab` file.
```bash
flutter build appbundle --release
```
**Artifact Location**: `build/app/outputs/bundle/release/app-release.aab`
*(We have verified this builds successfully)*

### 2. Upload to Google Play Console
1.  Go to [Google Play Console](https://play.google.com/console).
2.  **Create App**: Name it "Anjra".
3.  **App Setup**: Complete the "Dashboard" tasks (Privacy Policy, Content Rating, Target Audience).
    *   **Privacy Policy URL**: `https://jjayakrishnan.github.io/anjra-website/privacy.html`
    *   *(Note: Enable GitHub Pages in your repo settings to make this link live)*
4.  **Store Listing**:
    *   **App Icon**: Upload `assets/store/developer_icon.png` (512x512).
    *   **Feature Graphic**: Upload `assets/store/header_image.png` (1024x500).
    *   **Screenshots**: Upload images from `assets/store/` (Phone screenshots).
5.  **Release**:
    *   Go to **Production** -> **Create new release**.
    *   Upload the `app-release.aab` file.
    *   Review and rollout!

---

## 🍎 iOS (Apple App Store)

### 1. Verify Configuration (One-Time)
We have already configured these settings in your project:
*   **Bundle ID**: `com.jayakrishnan.anjra`
*   **Display Name**: `Anjra`
*   **Signing Team**: `HHL8J2MAGL` (Personal Team)

### 2. Prepare for Upload (Xcode)
Since you are using a Personal Team, you likely cannot upload directly to the App Store without upgrading to a paid ($99/year) Apple Developer Account.
*   **If you HAVE a paid account**: Follow Step 3A.
*   **If you DO NOT have a paid account**: You can only deploy to your own device (Step 3B).

### 3A. Distribute to App Store (Paid Account)
1.  **Open Project**:
    ```bash
    open ios/Runner.xcworkspace
    ```
2.  **Set Deployment Device**:
    Select **Any iOS Device (arm64)** from the device dropdown in the top toolbar.
3.  **Archive**:
    Go to **Product** -> **Archive**. Wait for the build to finish.
4.  **Upload**:
    *   The "Organizer" window will open.
    *   Select your build -> Click **Distribute App**.
    *   Choose **App Store Connect** -> **Upload**.
    *   Follow the prompts (Keep default settings).
5.  **App Store Connect**:
    *   Go to [App Store Connect](https://appstoreconnect.apple.com/).
    *   Create New App -> Bundle ID `com.jayakrishnan.anjra`.
    *   Go to **TestFlight** tab to see your upload.
    *   For the store page, upload screenshots from `assets/store/`.

### 3B. Install on Your Device (Free Account)
1.  Connect your iPhone via USB.
2.  Select your iPhone in the Xcode toolbar.
3.  Click the **Play Button (Run)**.
4.  The app will install on your phone. *Note: It expires after 7 days on free accounts.*

---

## 📂 Asset Cheat Sheet
All your assets are ready in: `assets/store/`

| Asset | Filename | Dimensions |
| :--- | :--- | :--- |
| **App Icon** | `developer_icon.png` | 512x512 |
| **Feature Graphic** | `header_image.png` | 4096x2304 (Auto-scaled) |
| **Screenshots** | `screenshot_*.png` | Mobile Portrait |

> [!TIP]
> **Version Updates**: Before every new upload, increment the version in `pubspec.yaml`:
> `version: 1.0.0+1` -> `1.0.0+2` -> `1.0.0+3`...

## Prerequisites

- **Developer Accounts**:
  - [Google Play Console](https://play.google.com/console) ($25 one-time fee).
  - [Apple Developer Program](https://developer.apple.com/programs/) ($99/year).
- **App Icons**: Ensure you have a high-resolution app icon (1024x1024). Recommended tool: `flutter_launcher_icons`.

---

## 🟢 Android (Google Play Store)

### ✅ Configuration Status (Verified)
- **Keystore**: `android/release.jks` (Generated)
- **Signing Config**: `build.gradle.kts` updated.
- **Build Artifact**: `build/app/outputs/bundle/release/app-release.aab` (Created, ~51MB)

### 1. Sign Your App
You need to generate a keystore file to sign your app release.

1.  **Run command** (Mac/Linux):
    ```bash
    keytool -genkey -v -keystore release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
    ```
    *Store this file safely. If you lose it, you cannot update your app.*

2.  **Configure Gradle**:
    Create `android/key.properties`:
    ```properties
    storePassword=<password>
    keyPassword=<password>
    keyAlias=upload
    storeFile=../release.jks
    ```

3.  **Update `android/app/build.gradle`**:
    Refer to [Flutter Docs on Signing](https://docs.flutter.dev/deployment/android#signing-the-app) to link the `key.properties` file.

### 2. Build Release Bundle
Google Play requires an Android App Bundle (.aab).

```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

### 3. Upload to Console
1.  Go to **Google Play Console**.
2.  Create a **New App**.
3.  Set up the store listing (Title, Description, Screenshots).
4.  Go to **Production** (or Testing) -> **Create new release**.
5.  Upload the `.aab` file.
6.  Complete Content Rating, Privacy Policy, and store settings.
7.  **Review and Rollout**.

---

## 🍎 iOS (Apple App Store)

*Requires a Mac with Xcode installed.*

### ✅ Configuration Status (Verified)
- **Display Name**: `Anjra`
- **Bundle ID**: `com.jayakrishnan.anjra`
- **Signing Team**: `HHL8J2MAGL` (Set)

### 1. Configure in Xcode
1.  Open `ios/Runner.xcworkspace` in Xcode.
2.  **Crucial Step to find settings**:
    -   In the left sidebar (Project Navigator), click the **blue "Runner" icon** at the very top.
    -   Then, in the main middle view, look at the sidebar **within that view**.
    -   Under **TARGETS**, click **Runner** (the black icon). *Do not select the Project.*
    -   Now you will see the **Signing & Capabilities** tab at the top.
3.  **General Tab**:
    In the top toolbar, change the device deployment target (next to "Anjra") from your iPhone/Simulator to **Any iOS Device (arm64)**.
    > *If you don't do this, the "Archive" option might be grayed out.*

### 2. Create Archive (Build)
1.  In the Xcode menu bar, click **Product** -> **Archive**.
2.  Wait for the build to complete. It may take a few minutes.
3.  Once finished, the **Organizer** window will automatically open.

### 3. Validate & Upload
1.  In the **Organizer** window, select your new build (top of the list).
2.  Click the blue **Distribute App** button on the right.
3.  Choose **App Store Connect** -> **Upload** -> **Next**.
4.  Keep clicking **Next** through the options.
    > [!IMPORTANT]
    > **Error "Missing dSYM for objective_c.framework"?**
    > if you see this error, **Uncheck** the box **"Upload your app's symbols to receive symbolicated crash reports..."** in the distribution options.
    > (This is a known issue with some recent Flutter plugins).
5.  Click **Upload**.

### 4. App Store Connect
1.  Log in to [App Store Connect](https://appstoreconnect.apple.com/).
2.  Go to **My Apps** -> Add (+) -> **New App**.
3.  Fill in the details:
    -   **Name**: Anjra
    -   **Bundle ID**: Select `com.jayakrishnan.anjra` from the dropdown.
    -   **SKU**: `anjra_ios_001` (or similar unique string).
4.  Go to the **TestFlight** tab. after ~15-20 minutes, your uploaded build will appear here.
5.  You can then submit it for external testing or release to the App Store.

---

## 🛠 Common Commands

| Platform | Command | Notes |
| :--- | :--- | :--- |
| **Android** | `flutter build appbundle` | Generates `.aab` for Play Store |
| **Android** | `flutter build apk` | Generates `.apk` for direct install |
| **iOS** | `flutter build ipa` | Generates `.ipa` (requires Xcode export) |

> [!TIP]
> **Privacy Policy**: Both stores require a valid privacy policy URL. You can host a simple page on GitHub Pages or use a free generator.

> [!WARNING]
> **Version Codes**: Every time you upload a new binary, you **must** increment the build number (e.g., version: `1.0.0+1` -> `1.0.0+2`) in `pubspec.yaml`.
