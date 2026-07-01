import ReplayKit
import HLSDKScreenSharing

final class SampleHandler: HLScreenSharingBroadcastSampleHandler {
    override func getAppGroupName() -> String {
        "group.com.helplightning.sdk.SampleSwiftUI.ScreenSharingExtension"
    }
}
