import Foundation

enum DemoConfiguration {
    static let serverURL = "http://192.168.1.40:8777"
    static let userEmail = "hale.xie+02@helplightning.com"
    static let contactEmail = "hale.xie+01@helplightning.com"
    static let apiKey = "zw9rak9tc3fgegppdwq3ywc5wk9ndz09"
    static let displayName = "hale.xie+02"
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
