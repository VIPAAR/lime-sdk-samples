import Foundation
@preconcurrency import HLSDK
import HLSDKSwift

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
        HLClientSwift.shared.delegate = self
        demoLogTidyAfterSDKInit()
    }

    func joinCall(using session: DemoSessionState, presentingViewController: UIViewController) async {
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

        guard let configuration = HLCallConfiguration.uikitConfiguration(
            with: call,
            presenting: presentingViewController
        ) else {
            notifyPhase(.ended(message: "Could not create a UIKit call configuration."))
            return
        }

        do {
            try await HLClientSwift.shared.startCallAsync(configuration: configuration)
            notifyPhase(.active, message: "Call active")
        } catch {
            notifyPhase(.ended(message: error.localizedDescription))
        }
    }

    func stopCall() async {
        do {
            try await HLClientSwift.shared.stopCurrentCallAsync()
            notifyPhase(.idle, message: "Call ended")
        } catch {
            notifyPhase(.ended(message: error.localizedDescription))
        }
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
