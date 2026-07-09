# SamplePresence

Unified Help Lightning SDK sample project with three runnable app targets that mirror the legacy `SampleObjC` demo-server session flow.

| Xcode scheme | Platform | UI stack | Call integration |
|--------------|----------|----------|------------------|
| `SamplePresence-iOS-SwiftUI` | iOS 17+ | SwiftUI | `HLCallConfiguration.swiftUIConfiguration` + embedded `HLCallView` |
| `SamplePresence-iOS-UIKit` | iOS 17+ | UIKit | `HLCallConfiguration.uikitConfiguration(presenting:)` + SDK `HLCallHostingController` |
| `SamplePresence-visionOS-SwiftUI` | visionOS 2+ | SwiftUI | Same as iOS SwiftUI + `HLCallImmersiveSpace()` |

Each app target embeds its own ReplayKit screen-sharing extension.

## Which Target Should I Run?

- **SwiftUI on iPhone or iPad** → `SamplePresence-iOS-SwiftUI`
- **UIKit on iPhone or iPad** → `SamplePresence-iOS-UIKit`
- **visionOS** → `SamplePresence-visionOS-SwiftUI`

### UIKit is iOS only (no visionOS)

Vision Pro calls require registering `HLCallImmersiveSpace()` as a SwiftUI `Scene` (for main camera passthrough and measurement). A pure UIKit `@main` `AppDelegate` cannot add that scene without adopting a SwiftUI `App` shell, which would change the purpose of the UIKit sample.

For visionOS, use **`SamplePresence-visionOS-SwiftUI`** instead.

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

Bundle identifiers and app groups are derived at runtime from each target's signing identity (see `DemoConfiguration`). Default bundle IDs:

| Target | App bundle id |
|--------|---------------|
| iOS SwiftUI | `com.helplightning.sdk.sample.PresenceSwiftUI` |
| iOS UIKit | `com.helplightning.sdk.sample.PresenceUIKit` |
| visionOS SwiftUI | `com.helplightning.sdk.sample.PresenceSwiftUI` |

Extension bundle id: `<app-bundle-id>.ScreenSharingExtension`  
App group: `group.<extension-bundle-id>`

Set your Apple development team in the Xcode project before running on device.

## Demo Server (`hlserver`)

The local demo server lives at `lime-sdk-samples/hlserver` (sibling of this sample directory in the samples repository) and listens on port `8777`.

Endpoints used by the sample:

- `GET /auth?email=<email>`
- `POST /session` with `Authorization: <auth-token>` and `{ "contact_email": "<email>" }`
- `GET /session?sid=<pin>` with `Authorization: <auth-token>`

Configure the sample app server URL field to your running demo server, for example `http://127.0.0.1:8777`.

## Binary SPM Dependencies

| Target | SPM products | Swift import |
|--------|--------------|--------------|
| iOS / visionOS SwiftUI apps | `HLSDKSwift` | `import HLSDKSwift` |
| iOS UIKit app | `HLSDK`, `HLSDKSwift` | `import HLSDK`, `import HLSDKSwift` |
| Screen-sharing extensions | `HLSDKScreenSharing` | `import HLSDKScreenSharing` |

Main app targets must **not** link `HLSDKScreenSharing`; that product is for ReplayKit extension targets only.

In Xcode, add the HLSDK package dependency using the URL and version supplied by Help Lightning, then link the products above to the matching targets.

## Flow Overview

1. Authenticate against the demo server
2. Create or retrieve a session
3. Review/edit session fields on the join screen
4. Start the SDK call with `HLClientSwift.shared.startCallAsync(configuration:)`
5. SwiftUI targets render `HLCallView()` while active; the UIKit target lets the SDK present `HLCallHostingController`

### Primary API (SwiftUI-owned call UI)

```swift
import HLSDKSwift

call.dataCenterID = kHLDataCenterID_US1

guard let configuration = HLCallConfiguration.swiftUIConfiguration(with: call) else {
    return
}

try await HLClientSwift.shared.startCallAsync(configuration: configuration)
```

### Primary API (SDK-managed UIKit)

```swift
import HLSDK
import HLSDKSwift

call.dataCenterID = kHLDataCenterID_US1

guard let configuration = HLCallConfiguration.uikitConfiguration(
    with: call,
    presenting: joinViewController
) else {
    return
}

try await HLClientSwift.shared.startCallAsync(configuration: configuration)
```

Do **not** import `HLSDKSwiftUI` or embed `HLCallView` in the UIKit sample. Use `HLCallHostingController` from `import HLSDK`.

---

## visionOS: Main Camera and Camera Passthrough

Vision Pro **main camera** and **camera passthrough in screen sharing** use Apple's **enterprise APIs for visionOS**. These capabilities are not available with a standard consumer App Store distribution profile alone.

This public sample documents the integration pattern. It does **not** ship Apple's `Enterprise.license` file. That license is a private asset your organization obtains from Apple after entitlement approval.

### Apply for Apple enterprise APIs

1. Enroll in the [Apple Developer Program](https://developer.apple.com/programs/) as an **organization**.
2. Request the visionOS enterprise entitlements your app needs:
   - [Building spatial experiences for business apps with enterprise APIs for visionOS](https://developer.apple.com/documentation/visionos/building-spatial-experiences-for-business-apps-with-enterprise-apis)
   - [Accessing the main camera](https://developer.apple.com/documentation/visionos/accessing-the-main-camera)
3. Request at least:
   - **Main Camera Access** (`com.apple.developer.arkit.main-camera-access.allow`)
   - **Passthrough in screen capture** (`com.apple.developer.screen-capture.include-passthrough`)
4. After approval, add Apple-issued **`Enterprise.license`** to your local checkout only. **Do not commit it.**

### Add `Enterprise.license` to visionOS targets

Add `Enterprise.license` to **Copy Bundle Resources** for:

| Target | Purpose |
|--------|---------|
| `SamplePresence-visionOS-SwiftUI` | Main camera access during calls |
| `ScreenSharingExtension-visionOS` | Passthrough background in ReplayKit screen capture |

### SDK integration checklist (visionOS)

1. Register the immersive scene in your `App` body (`SwiftUI/SamplePresenceApp.swift`):

   ```swift
   #if os(visionOS)
   HLCallImmersiveSpace()
   #endif
   ```

2. Opt in to main camera from `HLClientDelegate` (`SwiftUI/DemoCallCoordinator.swift`).

3. Configure screen sharing via `hlCallNeedScreenSharingInfo(_:)` with matching app group and extension bundle identifier.

4. Embed `ScreenSharingExtension-visionOS` in the main app target.

---

## Screen Sharing Setup

Screen sharing requires:

1. Matching app group entitlements on the app and broadcast extension targets
2. The screen-sharing extension embedded in each app target
3. A valid extension bundle identifier returned from `hlCallNeedScreenSharingInfo(_:)`
4. Code signing with a team that supports app groups

| Platform / flavor | Main app entitlements | Extension entitlements |
|-------------------|----------------------|------------------------|
| iOS SwiftUI | `iOS/SwiftUI/SamplePresence-iOS-SwiftUI.entitlements` | `Extensions/ScreenSharingExtension/ScreenSharingExtension-iOS-SwiftUI.entitlements` |
| iOS UIKit | `iOS/UIKit/SamplePresence-iOS-UIKit.entitlements` | `Extensions/ScreenSharingExtension/ScreenSharingExtension-iOS-UIKit.entitlements` |
| visionOS SwiftUI | `visionOS/SwiftUI/SamplePresence-visionOS-SwiftUI.entitlements` | `Extensions/ScreenSharingExtension/ScreenSharingExtension-visionOS.entitlements` |

On visionOS, passthrough screen sharing additionally requires the enterprise setup described above.

## Do Not Commit

- Real credentials, auth tokens, or API keys
- **`Enterprise.license`** or any other Apple-issued enterprise license files
- DerivedData / build output
