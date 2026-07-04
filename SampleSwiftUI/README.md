# SampleSwiftUI

SwiftUI demo app for validating Help Lightning binary Swift Package Manager consumption on iOS and visionOS. The app mirrors the legacy `SampleObjC` demo-server session flow and renders `HLCallView` from `import HLSDK` when a call is active.

## Prerequisites

- Xcode 16 or later
- iOS 17+ / visionOS 2+ simulators or devices
- A local HLSDK checkout with generated binary SPM artifacts
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

The sample depends on these products from the rendered HLSDK binary package:

| Target | SPM product | Swift import |
|--------|-------------|--------------|
| Main app (iOS / visionOS) | `HLSDK` | `import HLSDK` |
| Screen-sharing extension | `HLSDKScreenSharing` | `import HLSDKScreenSharing` |

Main app targets must **not** link `HLSDKScreenSharing`; the extension blob is for ReplayKit only.

### Render local binary artifacts for development

From your HLSDK repository checkout:

```bash
cd <HLSDK repo>
./Scripts/build-binary-hlsdk-xcframeworks.sh   # if artifacts are not already present
python3 ./Scripts/render-binary-spm-template.py \
  --template-dir ./Release/binary-spm/templates/HLSDK \
  --output-dir ./Release/binary-spm/rendered-local/HLSDK \
  --checksums-json ./Release/binary-spm/output/checksums.json \
  --xcframeworks-dir ./Release/binary-spm/output/xcframeworks \
  --package-url-scheme ssh
```

Xcode binary targets only accept `https://` artifact URLs. For local Xcode development, render with `--xcframeworks-dir` so binary targets reference local `.xcframework` folders by path instead of `file://` zip URLs.

Use `--package-url-scheme ssh` for local testing so SwiftPM can reuse your existing `git@github.com` package cache (for example from VisionProApp). Hosted/release renders must keep the default `https` URLs.

If you must resolve an HTTPS-rendered package locally, you can seed HTTPS mirrors from existing SSH cache entries in the HLSDK repo:

```bash
cd <HLSDK repo>
python3 ./Scripts/sync-spm-ssh-cache-to-https.py \
  --package-swift ./Release/binary-spm/templates/HLSDK/Package.swift.template
```

The generated package at `Release/binary-spm/rendered-local/HLSDK` and build artifacts under `Release/binary-spm/output/` are development-only outputs. Do not commit them.

### Point the sample project at the rendered package

`SampleSwiftUI.xcodeproj` references a local Swift package at:

`../../../VisionPro/vp_work/VisionProApp/HLSDK/Release/binary-spm/rendered-local/HLSDK`

Adjust this path in Xcode if your HLSDK checkout location differs, or create a symlink at that relative location.

Regenerate the project file after editing `generate_xcode_project.py`:

```bash
python3 generate_xcode_project.py
```

### Switch to hosted binary package URLs

When DevOps publishes hosted artifacts, replace the local package reference in Xcode with the hosted Swift package URL and checksums rendered from the same HLSDK binary template workflow. No sample source changes are required beyond updating the package dependency location.

## Screen Sharing Setup

Screen sharing requires:

1. Matching app group entitlements on the app and broadcast extension targets
2. The screen-sharing extension embedded in each app target
3. A valid extension bundle identifier returned from `hlCallNeedScreenSharingInfo(_:)`
4. Code signing with a team that supports app groups

On visionOS, camera passthrough and related capabilities may require an appropriate Help Lightning enterprise license in addition to standard signing setup.

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

## Do Not Commit

- Rendered local HLSDK binary packages
- XCFramework zip artifacts
- Real credentials, auth tokens, or API keys
- DerivedData / build output
