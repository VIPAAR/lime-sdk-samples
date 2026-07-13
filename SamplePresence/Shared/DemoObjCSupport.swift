import Foundation

/// Swift utilities exposed to the Objective-C UIKit sample target.
@objc(DemoObjCSupport)
final class DemoObjCSupport: NSObject {
    @objc static func setupLogging() {
        demoLogSetup()
    }

    @objc static func tidyLoggingAfterSDKInit() {
        demoLogTidyAfterSDKInit()
    }

    @objc static var defaultServerURL: String { DemoConfiguration.serverURL }
    @objc static var defaultUserEmail: String { DemoConfiguration.userEmail }
    @objc static var defaultContactEmail: String { DemoConfiguration.contactEmail }
    @objc static var defaultAPIKey: String { DemoConfiguration.apiKey }
    @objc static var defaultDisplayName: String { DemoConfiguration.displayName }
    @objc static var defaultAvatarURL: String { DemoConfiguration.avatarURL }

    @objc static var screenSharingAppGroup: String { DemoConfiguration.screenSharingAppGroup }
    @objc static var screenSharingExtensionBundleIdentifier: String {
        DemoConfiguration.screenSharingExtensionBundleIdentifier
    }

    /// Copies `DemoConfiguration` into the ObjC `DemoSession` model.
    @objc(applyDemoConfigurationDefaultsToSession:)
    static func applyDemoConfigurationDefaults(to session: DemoSession) {
        session.serverURL = DemoConfiguration.serverURL
        session.userEmail = DemoConfiguration.userEmail
        session.contactEmail = DemoConfiguration.contactEmail
        session.apiKey = DemoConfiguration.apiKey
        session.displayName = DemoConfiguration.displayName
        session.avatarURL = DemoConfiguration.avatarURL
    }
}
