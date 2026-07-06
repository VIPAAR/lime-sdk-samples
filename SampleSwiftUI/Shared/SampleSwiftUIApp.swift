import SwiftUI

@main
struct SampleSwiftUIApp: App {
    init() {
        demoLogSetup()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
