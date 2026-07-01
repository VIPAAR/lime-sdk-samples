import Foundation
import HLSDK

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
        HLClient.sharedInstance().delegate = self
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

        call.dataCenterID = kHLDataCenterID_US1

        do {
            let promise = HLFullClient.sharedInstance().startCall(call)
            _ = try await promise.asyncValue()
            notifyPhase(.active, message: "Call active")
        } catch {
            notifyPhase(.ended(message: error.localizedDescription))
        }
    }

    func stopCall() async {
        do {
            let promise = HLFullClient.sharedInstance().stopCurrentCall()
            _ = try await promise.asyncValue()
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

extension DemoCallCoordinator: HLClientDelegate {
    func hlCall(_ call: HLCall, didEndWithReason reason: String) {
        notifyPhase(.ended(message: reason), message: reason)
    }

    func hlCallNeedScreenSharingInfo(_ call: any HLGenericCall) -> [String: Any] {
        [
            kHLCallPluginScreenSharingAppGroupName: DemoConfiguration.screenSharingAppGroup,
            kHLCallPluginScreenSharingBroadcastExtensionBundleId: DemoConfiguration.screenSharingExtensionBundleIdentifier
        ]
    }
}
