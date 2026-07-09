# SamplePresence

Unified Help Lightning SDK sample project with four runnable app targets that mirror the legacy `SampleObjC` demo-server session flow.

| Xcode scheme | Platform | UI stack | Call integration |
|--------------|----------|----------|------------------|
| `SamplePresence-iOS-SwiftUI` | iOS 17+ | SwiftUI | `HLCallConfiguration.swiftUIConfiguration` + embedded `HLCallView` |
| `SamplePresence-iOS-UIKit` | iOS 17+ | UIKit (Swift) | `HLCallConfiguration.uikitConfiguration(presenting:)` via `HLClientSwift` |
| `SamplePresence-iOS-UIKit-ObjC` | iOS 17+ | UIKit (ObjC) | `[HLCallConfiguration uikitConfigurationWithCall:presentingViewController:]` via `HLClient` |
| `SamplePresence-visionOS-SwiftUI` | visionOS 2+ | SwiftUI | Same as iOS SwiftUI + `HLCallImmersiveSpace()` |

Each app target embeds its own ReplayKit screen-sharing extension. The Swift and ObjC UIKit targets **share the same bundle identifier** and embed the same `ScreenSharingExtension-iOS-UIKit` target — only one UIKit flavor can be installed at a time.

## Which Target Should I Run?

- **SwiftUI on iPhone or iPad** → `SamplePresence-iOS-SwiftUI`
- **UIKit (Swift) on iPhone or iPad** → `SamplePresence-iOS-UIKit`
- **UIKit (Objective-C) on iPhone or iPad** → `SamplePresence-iOS-UIKit-ObjC`
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

Edit `Shared/DemoConfiguration.swift` with your demo-server and API credentials. Every app target reads those defaults into its session model on launch.

```swift
enum DemoConfiguration {
    static let serverURL = "http://192.168.1.40:8777"
    static let userEmail = "hale.xie+02@helplightning.com"
    static let contactEmail = "hale.xie+01@helplightning.com"
    static let apiKey = "zw9rak9tc3fgegppdwq3ywc5wk9ndz09"
    static let displayName = "hale.xie+02"
    static let avatarURL = ""
}
```

**Swift targets** (`DemoSessionState`) — defaults are applied in `init()`:

```swift
var session = DemoSessionState() // copies DemoConfiguration on init

// Re-apply after editing DemoConfiguration, or to reset form fields:
session.applyDemoConfigurationDefaults()

// Or set fields directly:
session.serverURL = "http://192.168.1.40:8777"
session.userEmail = "hale.xie+02@helplightning.com"
session.contactEmail = "hale.xie+01@helplightning.com"
session.apiKey = "zw9rak9tc3fgegppdwq3ywc5wk9ndz09"
session.displayName = "hale.xie+02"
```

**ObjC UIKit target** (`DemoSession`) — defaults are applied in `-init`:

```objc
DemoSession *session = [[DemoSession alloc] init]; // copies DemoConfiguration on init

// Re-apply after editing DemoConfiguration.swift:
[session applyDemoConfigurationDefaults];

// Or set fields directly:
session.serverURL = @"http://192.168.1.40:8777";
session.userEmail = @"hale.xie+02@helplightning.com";
session.contactEmail = @"hale.xie+01@helplightning.com";
session.apiKey = @"zw9rak9tc3fgegppdwq3ywc5wk9ndz09";
session.displayName = @"hale.xie+02";
```

You can also change values in the in-app auth/setup/join forms; those update the same session object.

| Field | Purpose |
|-------|---------|
| `serverURL` | Demo server base URL (for example `http://127.0.0.1:8777`) |
| `userEmail` | Email passed to `GET /auth?email=` |
| `contactEmail` | Contact email for `POST /session` |
| `apiKey` | Help Lightning API key used by the SDK call object and demo-server requests |
| `displayName` | Local display name shown on the join screen |

Bundle identifiers and app groups are derived at runtime from each target's signing identity (see `DemoConfiguration`). Default bundle IDs:

| Target | App bundle id |
|--------|---------------|
| iOS SwiftUI | `com.helplightning.sdk.sample.PresenceSwiftUI` |
| iOS UIKit (Swift) | `com.helplightning.sdk.sample.PresenceUIKit` |
| iOS UIKit (ObjC) | `com.helplightning.sdk.sample.PresenceUIKit` *(same as Swift UIKit)* |
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

| Target | SPM products | Import |
|--------|--------------|--------|
| iOS / visionOS SwiftUI apps | `HLSDKSwift` | `import HLSDKSwift` |
| iOS UIKit (Swift) app | `HLSDK`, `HLSDKSwift` | `import HLSDK`, `import HLSDKSwift` |
| iOS UIKit (ObjC) app | `HLSDK` only | `#import <HLSDK/HLSDK.h>` |
| Screen-sharing extensions | `HLSDKScreenSharing` | `import HLSDKScreenSharing` |

Main app targets must **not** link `HLSDKScreenSharing`; that product is for ReplayKit extension targets only.

In Xcode, add the HLSDK package dependency using the URL and version supplied by Help Lightning, then link the products above to the matching targets.

## Flow Overview

1. Authenticate against the demo server
2. Create or retrieve a session
3. Review/edit session fields on the join screen
4. Start the SDK call (SwiftUI/Swift UIKit use `HLClientSwift`; ObjC UIKit uses `HLClient`)
5. SwiftUI targets render `HLCallView()` while active; UIKit targets let the SDK present `HLCallHostingController`

### Primary API (SwiftUI-owned call UI)

```swift
import HLSDKSwift

call.dataCenterID = kHLDataCenterID_US1

guard let configuration = HLCallConfiguration.swiftUIConfiguration(with: call) else {
    return
}

try await HLClientSwift.shared.startCallAsync(configuration: configuration)
```

### Primary API (SDK-managed UIKit — Swift)

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

### Primary API (SDK-managed UIKit — Objective-C)

```objc
#import <HLSDK/HLSDK.h>

call.dataCenterID = kHLDataCenterID_US1;

HLCallConfiguration *configuration =
    [HLCallConfiguration uikitConfigurationWithCall:call
                         presentingViewController:joinViewController];
[[HLClient sharedInstance] startCallWithConfiguration:configuration];
```

Implement `HLClientDelegate` (including `hlCallNeedScreenSharingInfo:`) on your call coordinator. The ObjC target links **`HLSDK` only** — no `HLSDKSwift` product.

Do **not** import `HLSDKSwiftUI` or embed `HLCallView` in the UIKit samples. Use SDK-managed UIKit integration; the SDK presents `HLCallHostingController` automatically.

#### ObjC-only: test legacy `startCall:withPresentingViewController:`

The Swift UIKit target always uses `HLCallConfiguration`. The ObjC target defaults to the same configuration API, but you can switch to the legacy ObjC facade to verify backward compatibility.

In `UIKit-ObjC/DemoCallOptions.h`, set:

```objc
#define SAMPLE_PRESENCE_USE_LEGACY_UIKIT_START_CALL 1
```

Or add to the **`SamplePresence-iOS-UIKit-ObjC`** target build setting `GCC_PREPROCESSOR_DEFINITIONS`:

```
SAMPLE_PRESENCE_USE_LEGACY_UIKIT_START_CALL=1
```

| Macro value | API used |
|-------------|----------|
| `0` (default) | `-[HLCallConfiguration uikitConfigurationWithCall:presentingViewController:]` + `-[HLClient startCallWithConfiguration:]` |
| `1` | `-[HLClient startCall:withPresentingViewController:]` |

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
| iOS UIKit (Swift or ObjC) | `iOS/UIKit/SamplePresence-iOS-UIKit.entitlements` | `Extensions/ScreenSharingExtension/ScreenSharingExtension-iOS-UIKit.entitlements` |
| visionOS SwiftUI | `visionOS/SwiftUI/SamplePresence-visionOS-SwiftUI.entitlements` | `Extensions/ScreenSharingExtension/ScreenSharingExtension-visionOS.entitlements` |

On visionOS, passthrough screen sharing additionally requires the enterprise setup described above.

## Do Not Commit

- Real credentials, auth tokens, or API keys
- **`Enterprise.license`** or any other Apple-issued enterprise license files
- DerivedData / build output
