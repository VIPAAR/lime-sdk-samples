import SwiftUI
import HLSDKSwift

@main
struct SamplePresenceApp: App {
    init() {
        demoLogSetup()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        
#if os(visionOS)
        HLCallImmersiveSpace()
#endif
    }
}
