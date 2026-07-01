import SwiftUI

enum DemoFlowRoute: Hashable {
    case setup
    case join
}

@Observable
@MainActor
final class DemoFlowModel {
    let session = DemoSessionState()
    let callCoordinator = DemoCallCoordinator()
    private var serverClient: HLServerClient {
        HLServerClient(apiKey: session.apiKey)
    }

    var path: [DemoFlowRoute] = []
    var callPhase: DemoCallPhase = .idle
    var callStatusMessage = ""
    var isBusy = false
    var errorMessage: String?

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
            path = [.setup]
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
            path.append(.join)
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
            path.append(.join)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func joinCall() async {
        isBusy = true
        errorMessage = nil
        defer { isBusy = false }
        await callCoordinator.joinCall(using: session)
    }

    func stopCall() async {
        isBusy = true
        defer { isBusy = false }
        await callCoordinator.stopCall()
    }
}
