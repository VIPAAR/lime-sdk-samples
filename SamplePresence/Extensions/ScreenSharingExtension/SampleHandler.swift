import ReplayKit
import HLSDKScreenSharing

final class SampleHandler: HLScreenSharingBroadcastSampleHandler {
    override func getAppGroupName() -> String {
        DemoConfiguration.screenSharingAppGroup
    }
}
