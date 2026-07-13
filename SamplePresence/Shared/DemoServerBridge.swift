import Foundation

@objc(DemoServerBridge)
@MainActor
final class DemoServerBridge: NSObject {
    @objc static let shared = DemoServerBridge()

    @objc func authenticate(
        serverURL: String,
        email: String,
        apiKey: String,
        completion: @escaping (NSString?, NSError?) -> Void
    ) {
        Task {
            do {
                let client = HLServerClient(apiKey: apiKey)
                let token = try await client.authenticate(serverURL: serverURL, email: email)
                completion(token as NSString, nil)
            } catch {
                completion(nil, error as NSError)
            }
        }
    }

    @objc func createSession(
        serverURL: String,
        authToken: String,
        contactEmail: String,
        apiKey: String,
        completion: @escaping (NSDictionary?, NSError?) -> Void
    ) {
        Task {
            do {
                let client = HLServerClient(apiKey: apiKey)
                let response = try await client.createSession(
                    serverURL: serverURL,
                    authToken: authToken,
                    contactEmail: contactEmail
                )
                completion(Self.dictionary(from: response), nil)
            } catch {
                completion(nil, error as NSError)
            }
        }
    }

    @objc func retrieveSession(
        serverURL: String,
        authToken: String,
        pin: String,
        apiKey: String,
        completion: @escaping (NSDictionary?, NSError?) -> Void
    ) {
        Task {
            do {
                let client = HLServerClient(apiKey: apiKey)
                let response = try await client.retrieveSession(
                    serverURL: serverURL,
                    authToken: authToken,
                    pin: pin
                )
                completion(Self.dictionary(from: response), nil)
            } catch {
                completion(nil, error as NSError)
            }
        }
    }

    private static func dictionary(from response: DemoServerSessionResponse) -> NSDictionary {
        [
            "sessionID": response.sessionID,
            "sessionToken": response.sessionToken,
            "userToken": response.userToken,
            "gssURL": response.gssURL,
            "pin": response.pin
        ] as NSDictionary
    }
}
