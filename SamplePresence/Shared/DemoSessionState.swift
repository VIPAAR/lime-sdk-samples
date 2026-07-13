import Foundation
import Observation

@Observable
@MainActor
final class DemoSessionState {
    var serverURL: String = ""
    var userEmail: String = ""
    var contactEmail: String = ""
    var apiKey: String = ""

    var authToken: String = ""
    var sessionID: String = ""
    var sessionToken: String = ""
    var userToken: String = ""
    var gssServerURL: String = ""
    var sessionPIN: String = ""

    var displayName: String = ""
    var avatarURL: String = ""
    var cameraEnabled = true
    var microphoneEnabled = true

    init() {
        applyDemoConfigurationDefaults()
    }

    /// Copies `DemoConfiguration` defaults into this session (Swift UIKit / SwiftUI targets).
    func applyDemoConfigurationDefaults() {
        serverURL = DemoConfiguration.serverURL
        userEmail = DemoConfiguration.userEmail
        contactEmail = DemoConfiguration.contactEmail
        apiKey = DemoConfiguration.apiKey
        displayName = DemoConfiguration.displayName
        avatarURL = DemoConfiguration.avatarURL
    }

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
