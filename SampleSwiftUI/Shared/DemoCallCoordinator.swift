import Foundation
@preconcurrency import HLSDK
import Promises

enum DemoCallPhase: Equatable {
    case idle
    case starting
    case active
    case ended(message: String)
}

enum DemoCallNotification {
    static let pipChanged = Notification.Name("DemoCallNotification.PiPChanged")
    static let pipEnabledKey = "pipEnabled"
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
            let promise = HLClient.sharedInstance.start(
                call,
                dataCenter: kHLDataCenterID_US1
            )
            _ = try await asyncValue(from: Promise(promise))
            notifyPhase(.active, message: "Call active")
        } catch {
            notifyPhase(.ended(message: error.localizedDescription))
        }
    }

    func stopCall() async {
        do {
            let promise = HLClient.sharedInstance.stopCurrentCall()
            _ = try await asyncValue(from: Promise(promise))
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
        switch phase {
        case .idle, .ended:
            postPiPChanged(false)
        case .starting, .active:
            break
        }
        onPhaseChanged?(phase, message)
    }

    private nonisolated func postPiPChanged(_ enabled: Bool) {
        let post = {
            NotificationCenter.default.post(
                name: DemoCallNotification.pipChanged,
                object: nil,
                userInfo: [DemoCallNotification.pipEnabledKey: enabled]
            )
        }
        if Thread.isMainThread {
            post()
        } else {
            DispatchQueue.main.sync(execute: post)
        }
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

    nonisolated func hlCallCanSupportVisionOSMainCamera(_ call: any HLGenericCall) -> Bool {
        true
    }

    nonisolated func hlCall(_ call: any HLGenericCall, canMinimizeCallViewWithCallInfo callInfo: [String: Any]?) -> FBLPromise<AnyObject>? {
#if os(iOS)
        resolvedPromise(true).asObjCPromise()
#else
        resolvedPromise(false).asObjCPromise()
#endif
    }

    nonisolated func hlCall(_ call: any HLGenericCall, didMinimizeCallViewWithCallInfo callInfo: [String: Any]?) -> FBLPromise<AnyObject>? {
        postPiPChanged(true)
        return resolvedPromise(true).asObjCPromise()
    }

    nonisolated func hlCall(_ call: any HLGenericCall, didRestoreCallViewWithCallInfo callInfo: [String: Any]?) {
        postPiPChanged(false)
    }
}
