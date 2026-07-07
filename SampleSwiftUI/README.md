# SampleSwiftUI

SwiftUI demo app for validating Help Lightning binary Swift Package Manager consumption on iOS and visionOS. The app mirrors the legacy `SampleObjC` demo-server session flow and renders `HLCallView` from `import HLSDKSwift` when a call is active.

## Prerequisites

- Xcode 16 or later
- iOS 17+ / visionOS 2+ simulators or devices
- Access to the Help Lightning HLSDK binary Swift package (URL and version provided by Help Lightning)
- Optional: the `hlserver` demo server from the `lime-sdk-samples` repository

## Replace Placeholder Values

Before running the sample, replace the placeholder defaults in `Shared/DemoConfiguration.swift` and/or the in-app forms:

| Placeholder | Purpose |
|-------------|---------|
| `[YOUR_SERVER_URL]` | Demo server base URL (for example `http://127.0.0.1:8777`) |
| `[YOUR_USER_EMAIL]` | Email passed to `GET /auth?email=` |
| `[YOUR_CONTACT_EMAIL]` | Contact email for `POST /session` |
| `[YOUR_HL_API_KEY]` | Help Lightning API key used by the SDK call object and demo-server requests |

Also replace the placeholder bundle identifiers and app group if your signing setup requires different values:

- App bundle id: `com.helplightning.sdk.sample.PresenceSwiftUI`
- Screen-sharing extension bundle id: `com.helplightning.sdk.sample.PresenceSwiftUI.ScreenSharingExtension`
- App group: `group.com.helplightning.sdk.sample.PresenceSwiftUI.ScreenSharingExtension`

Set your Apple development team in the Xcode project before running on device.

## Demo Server (`hlserver`)

The local demo server lives at `lime-sdk-samples/hlserver` (sibling of this sample directory in the samples repository) and listens on port `8777`.

Endpoints used by the sample:

- `GET /auth?email=<email>`
- `POST /session` with `Authorization: <auth-token>` and `{ "contact_email": "<email>" }`
- `GET /session?sid=<pin>` with `Authorization: <auth-token>`

Configure the sample app server URL field to your running demo server, for example `http://127.0.0.1:8777`.

## Binary SPM Dependencies

The sample depends on these products from the Help Lightning HLSDK binary Swift package:

| Target | SPM product | Swift import |
|--------|-------------|--------------|
| Main app (iOS / visionOS) | `HLSDKSwift` | `import HLSDKSwift` |
| Screen-sharing extension | `HLSDKScreenSharing` | `import HLSDKScreenSharing` |

Main app targets must **not** link `HLSDKScreenSharing`; that product is for ReplayKit extension targets only.

In Xcode, add the HLSDK package dependency using the URL and version supplied by Help Lightning, then link:

- `HLSDKSwift` → `SampleSwiftUI-iOS` and `SampleSwiftUI-visionOS`
- `HLSDKScreenSharing` → `ScreenSharingExtension-iOS` and `ScreenSharingExtension-visionOS`

Objective-C integrations can use product `HLSDK` (`import HLSDK`) instead of `HLSDKSwift`.

## Build Targets

Open `SampleSwiftUI.xcodeproj` and build:

- `SampleSwiftUI-iOS`
- `SampleSwiftUI-visionOS`

Each app target embeds its platform screen-sharing extension.

## Flow Overview

1. Authenticate against the demo server
2. Create or retrieve a session
3. Review/edit session fields on the join screen
4. Start the SDK call lifecycle without UIKit-presented call UI
5. Render `HLCallView()` while the call is active

---

## visionOS: Main Camera and Camera Passthrough

Vision Pro **main camera** (in-call passthrough video from the device camera) and **camera passthrough in screen sharing** (ReplayKit captures the user's real-world background instead of black) use Apple's **enterprise APIs for visionOS**. These capabilities are not available with a standard consumer App Store distribution profile alone.

This public sample documents the integration pattern. It does **not** ship Apple's `Enterprise.license` file. That license is a private asset your organization obtains from Apple after entitlement approval.

### Apply for Apple enterprise APIs

1. Enroll in the [Apple Developer Program](https://developer.apple.com/programs/) as an **organization** (individual / sole-proprietor accounts do not qualify for enterprise APIs).
2. Request the visionOS enterprise entitlements your app needs. Apple documents the process here:
   - [Building spatial experiences for business apps with enterprise APIs for visionOS](https://developer.apple.com/documentation/visionos/building-spatial-experiences-for-business-apps-with-enterprise-apis)
   - [Accessing the main camera](https://developer.apple.com/documentation/visionos/accessing-the-main-camera)
   - [Introducing enterprise APIs for visionOS (WWDC24)](https://developer.apple.com/videos/play/wwdc2024/10139/)
3. Request at least:
   - **Main Camera Access** (`com.apple.developer.arkit.main-camera-access.allow`) for in-call Vision Pro main camera
   - **Passthrough in screen capture** (`com.apple.developer.screen-capture.include-passthrough`) for screen-sharing extension passthrough
4. After approval, Apple provides an **`Enterprise.license`** file for your approved bundle identifiers. Add this file to your local checkout only. **Do not commit it to source control.**

Enterprise APIs are intended for proprietary in-house or custom apps distributed through Apple Business Manager or equivalent enterprise distribution. Confirm distribution requirements with Apple before shipping.

### Add `Enterprise.license` to your app targets

Apple's license file must be present in the built app bundle for enterprise APIs to work on device.

Add `Enterprise.license` to **Copy Bundle Resources** for **both**:

| Target | Purpose |
|--------|---------|
| `SampleSwiftUI-visionOS` (main app) | Main camera access during calls |
| `ScreenSharingExtension-visionOS` | Passthrough background in ReplayKit screen capture |

Steps in Xcode:

1. Place your Apple-issued `Enterprise.license` in the project (for example under `visionOS/`).
2. Select the file in the Project navigator.
3. In the File inspector, enable target membership for **both** visionOS targets above.
4. Confirm the file appears under **Build Phases → Copy Bundle Resources** for each target.

The sample project references `Enterprise.license` for the main app target as a placeholder. You must supply the real file locally after Apple approves your entitlements.

### Entitlements (included in this sample)

The sample ships entitlement plists your provisioning profiles must match after Apple approval.

**Main app** — `visionOS/SampleSwiftUI-visionOS.entitlements`

| Key | Purpose |
|-----|---------|
| `com.apple.developer.arkit.main-camera-access.allow` | Vision Pro main camera during calls |
| `com.apple.security.application-groups` | App group shared with the screen-sharing extension |

**Screen-sharing extension** — `Extensions/ScreenSharingExtension/ScreenSharingExtension-visionOS.entitlements`

| Key | Purpose |
|-----|---------|
| `com.apple.developer.screen-capture.include-passthrough` | ReplayKit captures passthrough video instead of a black background |
| `com.apple.security.application-groups` | Same app group as the main app |

Enable matching capabilities on the App IDs for the main app and extension in the Apple Developer portal, then regenerate provisioning profiles.

### Usage descriptions (`visionOS/Info.plist`)

Apple shows authorization prompts using the keys below. The sample includes starter strings in `visionOS/Info.plist`. Replace them with text appropriate for your product before shipping.

#### Main camera (in-call video)

| Info.plist key | Required for | Sample string |
|----------------|--------------|---------------|
| `NSMainCameraUsageDescription` | User-facing main camera permission prompt | Enable main camera access to capture video for your calls. |
| `NSEnterpriseMCAMUsageDescription` | Enterprise main camera (MCAM) authorization | Enable main camera access to capture video for your calls. |

These keys are required together with `com.apple.developer.arkit.main-camera-access.allow` and a valid `Enterprise.license` in the main app bundle.

#### Camera passthrough (screen sharing)

Passthrough screen capture is controlled by the extension entitlement `com.apple.developer.screen-capture.include-passthrough` and a valid `Enterprise.license` in the **extension** bundle. Apple does not define a separate passthrough-only usage-description key; the system applies passthrough when the entitlement and license are configured correctly on the broadcast upload extension.

Keep `NSCameraUsageDescription` on the main app (via generated Info.plist keys) for standard camera access used by other call features.

#### Related ARKit / spatial keys in the sample

The sample also includes usage descriptions for world sensing, hand tracking, and accessory tracking used by annotation and measurement features during calls:

| Info.plist key | Sample string |
|----------------|---------------|
| `NSWorldSensingUsageDescription` | Enable world sensing to enhance your calls with 3D annotations. |
| `NSHandsTrackingUsageDescription` | Enable hand tracking to enhance your experience in immersive environments on Vision Pro. |
| `NSAccessoryTrackingUsageDescription` | Tracking accessory movements for precise annotation during video calls. |

### SDK integration checklist (visionOS)

In addition to signing, license, entitlements, and Info.plist keys:

1. **Register the immersive scene** in your `App` body:

   ```swift
   #if os(visionOS)
   HLCallImmersiveSpace()
   #endif
   ```

   See `Shared/SampleSwiftUIApp.swift`.

2. **Opt in to main camera** from your `HLClientDelegate`:

   ```swift
   func hlCallCanSupportVisionOSMainCamera(_ call: any HLGenericCall) -> Bool {
       true
   }
   ```

   See `Shared/DemoCallCoordinator.swift`. When using `HLClient`, the SDK forwards this to the session manager only if your HLSDK build includes the `HLClient` main-camera delegate bridge.

3. **Configure screen sharing** via `hlCallNeedScreenSharingInfo(_:)` with matching app group and extension bundle identifier (see `Shared/DemoConfiguration.swift`).

4. **Embed** `ScreenSharingExtension-visionOS` in the main app target.

Without the Apple enterprise license and approved entitlements, main camera and passthrough screen sharing will fail or fall back to limited behavior (for example black background in screen capture).

---

## Screen Sharing Setup (iOS and visionOS)

Screen sharing requires:

1. Matching app group entitlements on the app and broadcast extension targets
2. The screen-sharing extension embedded in each app target
3. A valid extension bundle identifier returned from `hlCallNeedScreenSharingInfo(_:)`
4. Code signing with a team that supports app groups

Platform-specific entitlements:

| Platform | Main app entitlements | Extension entitlements |
|----------|----------------------|------------------------|
| iOS | `iOS/SampleSwiftUI-iOS.entitlements` | `Extensions/ScreenSharingExtension/ScreenSharingExtension-iOS.entitlements` |
| visionOS | `visionOS/SampleSwiftUI-visionOS.entitlements` | `Extensions/ScreenSharingExtension/ScreenSharingExtension-visionOS.entitlements` |

On visionOS, passthrough screen sharing additionally requires the enterprise setup described in [visionOS: Main Camera and Camera Passthrough](#visionos-main-camera-and-camera-passthrough).

## Do Not Commit

- Real credentials, auth tokens, or API keys
- **`Enterprise.license`** or any other Apple-issued enterprise license files
- DerivedData / build output
