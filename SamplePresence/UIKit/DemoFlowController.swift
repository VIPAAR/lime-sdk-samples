import UIKit

@MainActor
final class DemoFlowController {
    var session = DemoSessionState()
    let callCoordinator = DemoCallCoordinator()

    var isBusy = false {
        didSet { onBusyChanged?(isBusy) }
    }
    var errorMessage: String? {
        didSet { onErrorChanged?(errorMessage) }
    }
    var callPhase: DemoCallPhase = .idle {
        didSet { onCallPhaseChanged?(callPhase) }
    }
    var callStatusMessage = "" {
        didSet { onCallStatusChanged?(callStatusMessage) }
    }

    var onBusyChanged: ((Bool) -> Void)?
    var onErrorChanged: ((String?) -> Void)?
    var onCallPhaseChanged: ((DemoCallPhase) -> Void)?
    var onCallStatusChanged: ((String) -> Void)?

    weak var navigationController: UINavigationController?

    private var serverClient: HLServerClient {
        HLServerClient(apiKey: session.apiKey)
    }

    init() {
        callCoordinator.onPhaseChanged = { [weak self] phase, message in
            self?.callPhase = phase
            self?.callStatusMessage = message
        }
    }

    func authenticate() async {
        isBusy = true
        errorMessage = nil
        defer { isBusy = false }

        do {
            session.authToken = try await serverClient.authenticate(
                serverURL: session.serverURL,
                email: session.userEmail
            )
            pushSetup()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func createSession() async {
        isBusy = true
        errorMessage = nil
        defer { isBusy = false }

        session.clearSessionFields()
        do {
            let response = try await serverClient.createSession(
                serverURL: session.serverURL,
                authToken: session.authToken,
                contactEmail: session.contactEmail
            )
            session.applyCreateSessionResponse(response)
            pushJoin()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func retrieveSession(pin: String) async {
        isBusy = true
        errorMessage = nil
        defer { isBusy = false }

        session.clearSessionFields()
        session.sessionPIN = pin
        do {
            let response = try await serverClient.retrieveSession(
                serverURL: session.serverURL,
                authToken: session.authToken,
                pin: pin
            )
            session.applyRetrieveSessionResponse(response)
            pushJoin()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func joinCall(from presentingViewController: UIViewController) async {
        isBusy = true
        errorMessage = nil
        defer { isBusy = false }
        await callCoordinator.joinCall(using: session, presentingViewController: presentingViewController)
    }

    func stopCall() async {
        isBusy = true
        defer { isBusy = false }
        await callCoordinator.stopCall()
    }

    private func pushSetup() {
        guard let navigationController else { return }
        let setup = SetupViewController(flowController: self)
        navigationController.pushViewController(setup, animated: true)
    }

    private func pushJoin() {
        guard let navigationController else { return }
        let join = JoinViewController(flowController: self)
        navigationController.pushViewController(join, animated: true)
    }
}
