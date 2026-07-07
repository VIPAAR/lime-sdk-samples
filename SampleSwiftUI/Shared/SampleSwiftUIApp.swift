import SwiftUI
import HLSDKSwift

@main
struct SampleSwiftUIApp: App {
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
