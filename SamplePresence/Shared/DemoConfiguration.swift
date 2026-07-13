import Foundation

enum DemoConfiguration {
    static let serverURL = "http://127.0.0.1:8777"
    static let userEmail = "user@example.com"
    static let contactEmail = "contact@example.com"
    static let apiKey = "your-api-key"
    static let displayName = "Demo User"
    static let avatarURL = ""

    static var appBundleIdentifier: String {
        guard let bundleID = Bundle.main.bundleIdentifier else {
            return "com.helplightning.sdk.sample.Presence"
        }
        if bundleID.hasSuffix(".ScreenSharingExtension") {
            return String(bundleID.dropLast(".ScreenSharingExtension".count))
        }
        return bundleID
    }

    static var screenSharingExtensionBundleIdentifier: String {
        "\(appBundleIdentifier).ScreenSharingExtension"
    }

    static var screenSharingAppGroup: String {
        "group.\(screenSharingExtensionBundleIdentifier)"
    }
}
