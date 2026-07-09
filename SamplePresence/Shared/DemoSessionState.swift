import Foundation
import Observation

@Observable
@MainActor
final class DemoSessionState {
    var serverURL: String = DemoConfiguration.serverURL
    var userEmail: String = DemoConfiguration.userEmail
    var contactEmail: String = DemoConfiguration.contactEmail
    var apiKey: String = DemoConfiguration.apiKey

    var authToken: String = ""
    var sessionID: String = ""
    var sessionToken: String = ""
    var userToken: String = ""
    var gssServerURL: String = ""
    var sessionPIN: String = ""

    var displayName: String = DemoConfiguration.displayName
    var avatarURL: String = DemoConfiguration.avatarURL
    var cameraEnabled = true
    var microphoneEnabled = true

    func applyCreateSessionResponse(_ response: DemoServerSessionResponse) {
        sessionID = response.sessionID
        sessionToken = response.sessionToken
        userToken = response.userToken
        gssServerURL = response.gssURL
        sessionPIN = response.pin
    }

    func applyRetrieveSessionResponse(_ response: DemoServerSessionResponse) {
        sessionID = response.sessionID
        sessionToken = response.sessionToken
        userToken = response.userToken
        gssServerURL = response.gssURL
    }

    func clearSessionFields() {
        sessionID = ""
        sessionToken = ""
        userToken = ""
        gssServerURL = ""
        sessionPIN = ""
    }
}
