import Foundation
@preconcurrency import HLSDK

enum DemoCallPhase: Equatable {
    case idle
    case starting
    case active
    case ended(message: String)
}

@MainActor
final class DemoCallCoordinator: NSObject {
    var onPhaseChanged: ((DemoCallPhase, String) -> Void)?

    override init() {
        super.init()
        HLClient.sharedInstance.delegate = self
        demoLogTidyAfterSDKInit()
    }

    func joinCall(using session: DemoSessionState) async {
        guard canStartCall(with: session) else {
            notifyPhase(.ended(message: "Replace placeholder session values and API key before joining a call."))
            return
        }

        notifyPhase(.starting, message: "Starting call…")

        guard let call = HLCall(
            sessionId: session.sessionID,
            sessionToken: session.sessionToken,
            userToken: session.userToken,
            gssUrl: session.gssServerURL,
            helplightningAPIKey: session.apiKey,
            localUserDisplayName: session.displayName,
            localUserAvatarUrl: session.avatarURL,
            autoEnableCamera: session.cameraEnabled,
            autoEnableMicrophone: session.microphoneEnabled
        ) else {
            notifyPhase(.ended(message: "Could not create an SDK call object from the current session fields."))
            return
        }

        do {
            let promise = HLClient.sharedInstance.startCall(
                call,
                dataCenter: kHLDataCenterID_US1
            )
            _ = try await asyncValue(from: promise)
            notifyPhase(.active, message: "Call active")
        } catch {
            notifyPhase(.ended(message: error.localizedDescription))
        }
    }

    func stopCall() async {
        do {
            let promise = HLClient.sharedInstance.stopCurrentCall()
            _ = try await asyncValue(from: promise)
            notifyPhase(.idle, message: "Call ended")
        } catch {
            notifyPhase(.ended(message: error.localizedDescription))
        }
    }

    func resetToIdle() {
        notifyPhase(.idle, message: "")
    }

    private func canStartCall(with session: DemoSessionState) -> Bool {
        !session.sessionID.isEmpty
            && !session.sessionToken.isEmpty
            && !session.userToken.isEmpty
            && !session.gssServerURL.isEmpty
            && !session.apiKey.isEmpty
            && !session.apiKey.contains("[YOUR_")
    }

    private func notifyPhase(_ phase: DemoCallPhase, message: String = "") {
        onPhaseChanged?(phase, message)
    }
}

extension DemoCallCoordinator: @preconcurrency HLClientDelegate {
    nonisolated func hlCall(_ call: HLCall, didEndWithReason reason: String) {
        Task { @MainActor in
            notifyPhase(.ended(message: reason), message: reason)
        }
    }

    nonisolated func hlCallNeedScreenSharingInfo(_ call: any HLGenericCall) -> [String: Any] {
        [
            kHLCallPluginScreenSharingAppGroupName: DemoConfiguration.screenSharingAppGroup,
            kHLCallPluginScreenSharingBroadcastExtensionBundleId: DemoConfiguration.screenSharingExtensionBundleIdentifier
        ]
    }
}
