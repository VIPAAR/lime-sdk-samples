import Foundation

struct DemoServerSessionResponse: Decodable, Sendable {
    let sessionID: String
    let sessionToken: String
    let userToken: String
    let gssURL: String
    let pin: String

    enum CodingKeys: String, CodingKey {
        case sessionID = "session_id"
        case sessionToken = "session_token"
        case userToken = "user_token"
        case gssURL = "url"
        case pin = "sid"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        sessionID = try container.decodeIfPresent(String.self, forKey: .sessionID) ?? ""
        sessionToken = try container.decodeIfPresent(String.self, forKey: .sessionToken) ?? ""
        userToken = try container.decodeIfPresent(String.self, forKey: .userToken) ?? ""
        gssURL = try container.decodeIfPresent(String.self, forKey: .gssURL) ?? ""
        pin = try container.decodeIfPresent(String.self, forKey: .pin) ?? ""
    }
}

enum DemoServerError: LocalizedError {
    case invalidServerURL
    case invalidResponse
    case httpStatus(Int)

    var errorDescription: String? {
        switch self {
        case .invalidServerURL:
            return "The demo server URL is invalid. Replace [YOUR_SERVER_URL] with a reachable server URL."
        case .invalidResponse:
            return "The demo server returned an unexpected response."
        case .httpStatus(let code):
            return "The demo server request failed with HTTP status \(code)."
        }
    }
}

actor HLServerClient {
    private let apiKey: String
    private let session: URLSession

    init(apiKey: String) {
        self.apiKey = apiKey
        let configuration = URLSessionConfiguration.ephemeral
        configuration.httpAdditionalHeaders = [
            "x-helplightning-api-key": apiKey,
            "content-type": "application/json"
        ]
        session = URLSession(configuration: configuration)
    }

    func authenticate(serverURL: String, email: String) async throws -> String {
        let url = try makeURL(serverURL: serverURL, path: "/auth", queryItems: [
            URLQueryItem(name: "email", value: email)
        ])
        let data = try await send(request: URLRequest(url: url))
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let token = json["token"] as? String,
              !token.isEmpty else {
            throw DemoServerError.invalidResponse
        }
        return token
    }

    func createSession(serverURL: String, authToken: String, contactEmail: String) async throws -> DemoServerSessionResponse {
        let url = try makeURL(serverURL: serverURL, path: "/session")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(authToken, forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: ["contact_email": contactEmail])
        let data = try await send(request: request)
        return try JSONDecoder().decode(DemoServerSessionResponse.self, from: data)
    }

    func retrieveSession(serverURL: String, authToken: String, pin: String) async throws -> DemoServerSessionResponse {
        let url = try makeURL(serverURL: serverURL, path: "/session", queryItems: [
            URLQueryItem(name: "sid", value: pin)
        ])
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(authToken, forHTTPHeaderField: "Authorization")
        let data = try await send(request: request)
        return try JSONDecoder().decode(DemoServerSessionResponse.self, from: data)
    }

    private func makeURL(serverURL: String, path: String, queryItems: [URLQueryItem] = []) throws -> URL {
        guard var components = URLComponents(string: serverURL) else {
            throw DemoServerError.invalidServerURL
        }
        components.path = path
        if !queryItems.isEmpty {
            // URLQueryItem encoding leaves '+' unescaped, but form-style query parsers
            // treat '+' as space. Encode '+' as %2B for values such as plus-address emails.
            components.percentEncodedQueryItems = queryItems.map { item in
                URLQueryItem(
                    name: percentEncodedQueryComponent(item.name),
                    value: item.value.map(percentEncodedQueryComponent)
                )
            }
        }
        guard let url = components.url else {
            throw DemoServerError.invalidServerURL
        }
        return url
    }

    private func percentEncodedQueryComponent(_ value: String) -> String {
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "+")
        return value.addingPercentEncoding(withAllowedCharacters: allowed) ?? value
    }

    private func send(request: URLRequest) async throws -> Data {
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw DemoServerError.invalidResponse
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw DemoServerError.httpStatus(httpResponse.statusCode)
        }
        return data
    }
}
